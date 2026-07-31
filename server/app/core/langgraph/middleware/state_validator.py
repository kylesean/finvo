"""State Validator

Defensive state validator verifying client state mutations prior to graph execution.
Implements the "Trust, but Verify" principle.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any

from app.core.logging import logger
from app.schemas.client_state import ClientStateMutation


@dataclass
class ValidationResult:
    """Validation result container."""

    valid: bool
    errors: list[str] = field(default_factory=list)

    def __bool__(self) -> bool:
        """Return True if the validation is successful, False otherwise."""
        return self.valid


class StateValidator:
    """State Validator.

    Validates whether ClientStateMutation submitted by client is valid.
    Returns ValidationResult on failure to let caller determine fallback strategy.
    """

    def validate(self, client_state: ClientStateMutation | None) -> ValidationResult:
        """Validate client state mutation."""
        if client_state is None:
            return ValidationResult(valid=True)

        errors = []

        # Validate direct_execute mode
        if client_state.ui_mode == "direct_execute":
            if not client_state.tool_name:
                errors.append("ui_mode=direct_execute requires tool_name")
            if not client_state.tool_params:
                errors.append("ui_mode=direct_execute requires tool_params")
            else:
                params_result = self._validate_tool_params(client_state.tool_name, client_state.tool_params)
                errors.extend(params_result.errors)

        if errors:
            logger.warning(
                "client_state_validation_failed",
                errors=errors,
                ui_mode=client_state.ui_mode,
                tool_name=client_state.tool_name,
            )
            return ValidationResult(valid=False, errors=errors)

        logger.debug(
            "client_state_validation_passed",
            ui_mode=client_state.ui_mode,
            tool_name=client_state.tool_name,
        )
        return ValidationResult(valid=True)

    def _validate_tool_params(self, tool_name: str | None, params: dict[str, Any]) -> ValidationResult:
        """Validate parameters according to tool name.

        Extensible: apply specific validation rules for different tools.
        """
        errors = []

        if tool_name == "execute_transfer":
            if not params.get("source_account_id"):
                errors.append("Missing source_account_id")
            if not params.get("target_account_id"):
                errors.append("Missing target_account_id")
            if params.get("source_account_id") == params.get("target_account_id"):
                errors.append("source_account_id cannot equal target_account_id")
            amount = params.get("amount")
            if not amount or (isinstance(amount, (int, float)) and amount <= 0):
                errors.append("Amount must be greater than 0")

        return ValidationResult(valid=len(errors) == 0, errors=errors)


# Global singleton
state_validator = StateValidator()
