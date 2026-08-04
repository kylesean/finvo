from unittest.mock import MagicMock, patch

import pytest

from app.core.dependencies import get_redis_client


@pytest.mark.asyncio
async def test_get_redis_client_exception_propagation():
    """Verify that exceptions thrown during downstream execution propagate cleanly.

    FastAPI's AsyncExitStack calls generator.athrow(exc) on generator dependencies.
    If get_redis_client catches Exception around yield and yields again, Python
    raises `RuntimeError: generator didn't stop after athrow()`.
    """
    mock_client = MagicMock()
    with patch("app.core.cache.cache_manager.get_client", return_value=mock_client):
        gen = get_redis_client()
        client = await gen.asend(None)
        assert client == mock_client

        # Simulate FastAPI throwing a downstream exception (e.g. NotFoundError)
        with pytest.raises(ValueError, match="downstream error"):
            await gen.athrow(ValueError("downstream error"))
