"""Alembic environment configuration.

This module configures Alembic for database migrations with SQLAlchemy 2.0
models. It enables autogenerate functionality by connecting to the
application's model metadata.

Best Practices Implemented:
1. Dynamic database URL from environment variables
2. SQLAlchemy Declarative metadata integration for autogenerate
3. Type comparison for detecting column type changes
4. Server default comparison for detecting default value changes
"""

import os
import sys
from logging.config import fileConfig

from alembic import context
from sqlalchemy import engine_from_config, pool

# Add the project root to Python path for imports
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# Import all models to register them with the Declarative metadata.
# This MUST happen before accessing Base.metadata.
import app.models  # noqa: F401
from app.models.base import Base

from app.core.config import settings

# Alembic Config object
config = context.config

# Override sqlalchemy.url with environment-based URL
# This allows the same alembic.ini to work across environments
config.set_main_option("sqlalchemy.url", settings.database_url_sync)

# Setup Python logging from alembic.ini
if config.config_file_name is not None:
    fileConfig(config.config_file_name)

# Target metadata for autogenerate support.
# Models use the SQLAlchemy 2.0 Declarative ``Base`` (not SQLModel), so
# ``Base.metadata`` is the registry alembic must compare against. Using
# ``SQLModel.metadata`` here would be empty and make ``alembic check``
# report every table as removed.
target_metadata = Base.metadata


def include_object(object, name, type_, reflected, compare_to):
    """Filter objects for migration autogenerate.

    Excludes:
    - LangGraph checkpoint tables (managed by LangGraph itself)
    - Mem0 internal tables (managed by Mem0)
    - PostGIS/pgvector extension tables
    - Other externally managed tables

    Args:
        object: The SQLAlchemy schema object
        name: Object name
        type_: Object type (table, column, index, etc.)
        reflected: Whether object was reflected from database
        compare_to: The object being compared to

    Returns:
        bool: True to include in autogenerate, False to skip
    """
    # Skip LangGraph checkpoint tables
    langgraph_tables = {
        "checkpoints",
        "checkpoint_blobs",
        "checkpoint_writes",
        "checkpoint_migrations",
    }
    if type_ == "table" and name in langgraph_tables:
        return False

    # Skip Mem0 internal tables
    mem0_tables = {
        "longterm_memory",
        "mem0migrations",
    }
    if type_ == "table" and name in mem0_tables:
        return False

    # Skip tables prefixed with mem0_
    if type_ == "table" and name.startswith("mem0_"):
        return False

    # Skip message_branches (if not in models, it's legacy)
    legacy_tables = {
        "message_branches",
        "pg_vector_index_stat",
    }
    if type_ == "table" and name in legacy_tables:
        return False

    return True


def run_migrations_offline() -> None:
    """Run migrations in 'offline' mode.

    This configures the context with just a URL and not an Engine,
    which is useful for generating SQL scripts without database access.

    Calls to context.execute() here emit the given string to the
    script output.
    """
    url = config.get_main_option("sqlalchemy.url")
    context.configure(
        url=url,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
        compare_type=True,
        compare_server_default=True,
        include_object=include_object,
        # Render as batch operations for SQLite compatibility (optional)
        # render_as_batch=True,
    )

    with context.begin_transaction():
        context.run_migrations()


def run_migrations_online() -> None:
    """Run migrations in 'online' mode.

    In this scenario we need to create an Engine and associate
    a connection with the context.
    """
    connectable = engine_from_config(
        config.get_section(config.config_ini_section, {}),
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
    )

    with connectable.connect() as connection:
        context.configure(
            connection=connection,
            target_metadata=target_metadata,
            compare_type=True,
            compare_server_default=True,
            include_object=include_object,
        )

        with context.begin_transaction():
            context.run_migrations()


if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
