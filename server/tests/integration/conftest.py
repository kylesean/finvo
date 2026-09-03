"""Opt this subtree into database tests.

Re-exporting the shared Postgres fixtures registers them for every test under
this directory (fixture visibility = directory scope). See tests/db_fixtures.py.
"""

from tests.db_fixtures import (  # noqa: F401
    _clean_tables,
    async_db_engine,
    client,
    client_with_auth,
    db_session,
    test_user,
)
