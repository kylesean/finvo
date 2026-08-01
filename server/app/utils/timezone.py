"""Timezone processing utilities.

Best practices for multi-timezone applications:
1. Database always stores UTC (naive datetime)
2. Convert user input from user timezone to UTC
3. Convert UTC to user timezone when returning data to user
"""

from datetime import datetime
from typing import cast
from zoneinfo import ZoneInfo

# Default timezone
DEFAULT_TIMEZONE = "UTC"


class TimezoneHelper:
    """Timezone conversion helper class."""

    @staticmethod
    def user_to_utc(dt: datetime, user_timezone: str = DEFAULT_TIMEZONE) -> datetime:
        """Convert datetime from user timezone to UTC (for DB storage).

        Args:
            dt: Datetime in user timezone (can be naive or aware)
            user_timezone: User timezone string, e.g. "Asia/Shanghai"

        Returns:
            UTC datetime (naive datetime, for database storage)

        Example:
            >>> # User creates record at 21:00 Beijing time
            >>> beijing_time = datetime(2025, 12, 2, 21, 0)
            >>> utc_time = TimezoneHelper.user_to_utc(beijing_time, "Asia/Shanghai")
            >>> print(utc_time)
            2025-12-02 13:00:00  # UTC time stored in database
        """
        # If aware, convert to user timezone first
        if dt.tzinfo is not None:
            user_tz = ZoneInfo(user_timezone)
            dt_in_user_tz = dt.astimezone(user_tz)
        else:
            # If naive, assume it represents time in user timezone
            user_tz = ZoneInfo(user_timezone)
            dt_in_user_tz = dt.replace(tzinfo=user_tz)

        # Convert to UTC aware
        utc_aware = dt_in_user_tz.astimezone(ZoneInfo("UTC"))

        # Remove tzinfo and return naive datetime
        return utc_aware.replace(tzinfo=None)

    @staticmethod
    def utc_to_user(dt: datetime, user_timezone: str = DEFAULT_TIMEZONE, as_string: bool = False) -> datetime | str:
        """Convert UTC datetime to user timezone (for display).

        Args:
            dt: UTC datetime (naive datetime, read from database)
            user_timezone: User timezone string, e.g. "Asia/Shanghai"
            as_string: Whether to return ISO format string

        Returns:
            Datetime in user timezone (aware datetime or ISO string)

        Example:
            >>> utc_time = datetime(2025, 12, 2, 13, 0)
            >>> beijing_time = TimezoneHelper.utc_to_user(utc_time, "Asia/Shanghai")
            >>> print(beijing_time)
            2025-12-02 21:00:00+08:00
        """
        # Mark as UTC aware
        if dt.tzinfo is None:
            utc_aware = dt.replace(tzinfo=ZoneInfo("UTC"))
        else:
            utc_aware = dt.astimezone(ZoneInfo("UTC"))

        # Convert to user timezone
        user_tz = ZoneInfo(user_timezone)
        user_time = utc_aware.astimezone(user_tz)

        if as_string:
            return user_time.isoformat()

        return user_time

    @staticmethod
    def now_utc() -> datetime:
        """Get current UTC time (naive, for database storage).

        Returns:
            Current UTC time (naive datetime)
        """
        return datetime.now(ZoneInfo("UTC")).replace(tzinfo=None)

    @staticmethod
    def now_in_timezone(timezone: str = DEFAULT_TIMEZONE) -> datetime:
        """Get current time in specified timezone (aware).

        Args:
            timezone: Timezone string, e.g. "Asia/Shanghai"

        Returns:
            Current time in specified timezone (aware datetime)
        """
        tz = ZoneInfo(timezone)
        return datetime.now(tz)

    @staticmethod
    def parse_user_datetime(datetime_str: str, user_timezone: str = DEFAULT_TIMEZONE) -> datetime:
        """Parse datetime string input by user and convert to UTC for storage.

        Args:
            datetime_str: Time string, e.g. "2025-12-02T21:00:00" or "2025-12-02 21:00:00"
            user_timezone: User timezone string

        Returns:
            UTC datetime (naive datetime, for database storage)
        """
        dt_str = datetime_str.replace("T", " ").strip()
        try:
            dt = datetime.fromisoformat(dt_str)
        except ValueError:
            # Surface a clear message instead of a bare parser exception so the
            # caller can respond with a user-friendly validation error.
            raise ValueError(f"Invalid datetime format: {datetime_str!r}. Expected e.g. '2025-12-02 21:00:00'.")

        return TimezoneHelper.user_to_utc(dt, user_timezone)

    @staticmethod
    def format_for_user(
        dt: datetime, user_timezone: str = DEFAULT_TIMEZONE, format_str: str = "%Y-%m-%d %H:%M:%S"
    ) -> str:
        """Format datetime as string in user timezone.

        Args:
            dt: UTC time (naive datetime)
            user_timezone: User timezone string
            format_str: Format template string

        Returns:
            Formatted time string
        """
        user_time = cast(datetime, TimezoneHelper.utc_to_user(dt, user_timezone))
        return user_time.strftime(format_str)


# Convenience functions
def to_utc(dt: datetime, user_timezone: str = DEFAULT_TIMEZONE) -> datetime:
    """Shortcut: user timezone -> UTC"""
    return TimezoneHelper.user_to_utc(dt, user_timezone)


def from_utc(dt: datetime, user_timezone: str = DEFAULT_TIMEZONE) -> datetime:
    """Shortcut: UTC -> user timezone"""
    return cast(datetime, TimezoneHelper.utc_to_user(dt, user_timezone))


def now_utc() -> datetime:
    """Shortcut: current UTC time"""
    return TimezoneHelper.now_utc()


def parse_with_zone(datetime_str: str, user_timezone: str = DEFAULT_TIMEZONE) -> tuple[datetime, str]:
    """Shortcut: parse datetime and return UTC datetime along with original timezone.

    Useful for transaction recording where original timezone is needed.

    Args:
        datetime_str: Datetime string
        user_timezone: User timezone string

    Returns:
        Tuple of (UTC datetime, original timezone string)
    """
    utc_time = TimezoneHelper.parse_user_datetime(datetime_str, user_timezone)
    return utc_time, user_timezone
