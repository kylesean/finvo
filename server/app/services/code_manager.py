"""Verification code management service.

Provides code generation, sending, verification, and rate-limiting.
"""

import hmac
import secrets
from abc import ABC, abstractmethod

from app.core.cache import cache_manager
from app.core.config import settings
from app.core.exceptions import AuthErrorCode, BusinessError
from app.core.logging import logger


class CodeSenderInterface(ABC):
    """Interface for verification code senders."""

    @abstractmethod
    def supports(self, code_type: str) -> bool:
        """Check whether this sender supports the given code type."""
        pass

    @abstractmethod
    async def send(self, account: str, code: str) -> bool:
        """Send the verification code to the given account."""
        pass


class EmailCodeSender(CodeSenderInterface):
    """Email verification code sender."""

    def supports(self, code_type: str) -> bool:
        """Check if this sender supports the specified code type (email)."""
        return code_type == "email"

    async def send(self, account: str, code: str) -> bool:
        """Send a verification code via email.

        # Integration with actual email service (e.g., SendGrid, AWS SES) should be implemented here
        """
        # Never log the verification code — it is a secret.
        logger.info(
            "sending_email_verification_code",
            email=account,
        )

        # TODO: Integration with actual email service (e.g., SendGrid, AWS SES)

        # Dev environment: print the code directly
        if settings.DEBUG:
            logger.debug(
                "email_verification_code_debug", email=account, code=code, message="verification_code_generated_dev"
            )

        return True


class SMSCodeSender(CodeSenderInterface):
    """SMS verification code sender."""

    def supports(self, code_type: str) -> bool:
        """Check if this sender supports the specified code type (mobile)."""
        return code_type == "mobile"

    async def send(self, account: str, code: str) -> bool:
        """Send a verification code via SMS.

        # Integration with actual SMS service (e.g., Twilio, Aliyun) should be implemented here
        """
        logger.info(
            "sending_sms_verification_code",
            mobile=account,
            # Do NOT log the code in production!
        )

        # Dev environment: print the code directly
        if settings.DEBUG:
            logger.debug(
                "sms_verification_code_debug", mobile=account, code=code, message="verification_code_generated_dev"
            )

        return True


class CodeManager:
    """Verification code manager.

    Responsible for code generation, storage, verification, and rate-limiting.
    """

    def __init__(self) -> None:
        # Configuration
        self.code_length = 6
        self.expire_seconds = 300  # 5 minutes
        self.rate_limit_seconds = 60  # Only one send per 60 seconds
        self.redis_code_key_prefix = "verification_code:"
        self.redis_rate_limit_key_prefix = "code_rate_limit:"

        # Register senders
        self.senders = [
            EmailCodeSender(),
            SMSCodeSender(),
        ]

    async def send_code(self, code_type: str, account: str) -> bool:
        """Send a verification code.

        Args:
            code_type: Code type (email/mobile)
            account: Recipient account

        Returns:
            Whether the code was sent successfully

        Raises:
            BusinessError: If sent too frequently or the type is unsupported
        """
        # Find the corresponding sender
        sender = self._find_sender(code_type)
        if not sender:
            raise BusinessError(
                message=f"Unsupported verification code type: {code_type}",
                error_code=AuthErrorCode.UNSUPPORTED_CODE_TYPE,
            )

        # Check and lock sending rate limit atomically
        if not await self._acquire_rate_limit_lock(account):
            raise BusinessError(
                message="Verification code sent too frequently, please try again later",
                error_code=AuthErrorCode.CODE_SEND_TOO_FREQUENTLY,
            )

        # Generate a cryptographically secure code
        code = self._generate_code()

        # Send the verification code
        try:
            success = await sender.send(account, code)

            if success:
                # Store the code; if the store fails (e.g. Redis unavailable) the
                # code is unusable — do NOT report success to the user.
                if not await self._store_code(account, code):
                    await self._release_rate_limit_lock(account)
                    logger.error("verification_code_store_failed", type=code_type, account=account)
                    raise BusinessError(
                        message="Failed to send verification code",
                        error_code=AuthErrorCode.SEND_CODE_FAILED,
                    )

                logger.info(
                    "verification_code_sent",
                    type=code_type,
                    account=account,
                )
            else:
                # Release the rate-limit lock on send failure
                await self._release_rate_limit_lock(account)

            return success

        except Exception as e:
            # Release the rate-limit lock on send exception
            await self._release_rate_limit_lock(account)
            logger.error(
                "verification_code_send_failed",
                type=code_type,
                account=account,
                error=str(e),
            )
            raise BusinessError(
                message="Failed to send verification code",
                error_code=AuthErrorCode.SEND_CODE_FAILED,
            )

    async def verify_code(self, account: str, code: str) -> bool:
        """Verify a verification code.

        Args:
            account: Account identifier
            code: Verification code to check

        Returns:
            Whether verification succeeded
        """
        key = self._get_code_key(account)

        # Fetch the stored code from Redis (no deserialization — stored as raw string)
        stored_code = await cache_manager.get(key, deserialize=False)

        # Convert bytes to str if needed
        if isinstance(stored_code, bytes):
            stored_code = stored_code.decode("utf-8")

        logger.debug(
            "verifying_code",
            account=account,
            key=key,
            has_stored_code=stored_code is not None,
            stored_code=stored_code if settings.DEBUG else "***",
            provided_code=code if settings.DEBUG else "***",
        )

        # Constant-time comparison via hmac.compare_digest to mitigate timing attacks
        if not stored_code or not hmac.compare_digest(stored_code, code):
            logger.warning(
                "verification_code_invalid",
                account=account,
                provided_code=code if settings.DEBUG else "***",
                stored_code=stored_code if settings.DEBUG else "***",
            )
            return False

        # Delete the code immediately after successful verification to prevent reuse
        await cache_manager.delete(key)

        logger.info(
            "verification_code_verified",
            account=account,
        )

        return True

    def _generate_code(self) -> str:
        """Generate a cryptographically secure random code (CSPRNG)."""
        val = secrets.randbelow(10**self.code_length)
        return f"{val:0{self.code_length}d}"

    def _find_sender(self, code_type: str) -> CodeSenderInterface | None:
        """Find the sender matching the given code type."""
        for sender in self.senders:
            if sender.supports(code_type):
                return sender
        return None

    async def _store_code(self, account: str, code: str) -> bool:
        """Store the verification code in Redis.

        Returns:
            bool: True when the code was persisted (verifiable), False otherwise
        """
        key = self._get_code_key(account)
        # Note: use the ttl parameter, not expire
        return await cache_manager.set(key, code, ttl=self.expire_seconds, serialize=False)

    async def _acquire_rate_limit_lock(self, account: str) -> bool:
        """Atomically check and acquire the send rate-limit lock (SETNX)."""
        key = self._get_rate_limit_key(account)
        return await cache_manager.set_nx(key, "1", ttl=self.rate_limit_seconds, serialize=False)

    async def _release_rate_limit_lock(self, account: str) -> None:
        """Release the send rate-limit lock."""
        key = self._get_rate_limit_key(account)
        await cache_manager.delete(key)

    def _get_code_key(self, account: str) -> str:
        """Build the Redis storage key for a verification code."""
        return f"{self.redis_code_key_prefix}{account}"

    def _get_rate_limit_key(self, account: str) -> str:
        """Build the Redis storage key for the rate-limit lock."""
        return f"{self.redis_rate_limit_key_prefix}{account}"


# Global singleton
code_manager = CodeManager()
