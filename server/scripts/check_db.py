import sys

from sqlalchemy import create_engine, text

from app.core.config import settings

try:
    # Use sync engine for simple check (psycopg v3 driver, same as LangGraph checkpointer)
    url = f"postgresql+psycopg://{settings.POSTGRES_USER}:{settings.POSTGRES_PASSWORD}@{settings.POSTGRES_HOST}:{settings.POSTGRES_PORT}/{settings.POSTGRES_DB}"

    print(
        f"Connecting to Database at {settings.POSTGRES_HOST}:{settings.POSTGRES_PORT} (DB: {settings.POSTGRES_DB})..."
    )

    engine = create_engine(url, connect_args={"connect_timeout": 5})

    with engine.connect() as conn:
        conn.execute(text("SELECT 1"))

    print("Database connection successful!")
    sys.exit(0)
except Exception as e:
    error_msg = str(e)
    if "password authentication failed" in error_msg:
        print(
            f"\033[91mError: Database authentication failed for user '{settings.POSTGRES_USER}'. Check your POSTGRES_PASSWORD.\033[0m"
        )
    elif "does not exist" in error_msg:
        print(f"\033[91mError: Database '{settings.POSTGRES_DB}' does not exist.\033[0m")
    elif "Is the server running" in error_msg or "Connection refused" in error_msg:
        print(
            f"\033[91mError: Could not connect to Postgres server at {settings.POSTGRES_HOST}:{settings.POSTGRES_PORT}. Is it running?\033[0m"
        )
    else:
        print(f"\033[91mError: {error_msg}\033[0m")
    sys.exit(1)
