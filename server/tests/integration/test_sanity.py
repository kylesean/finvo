def test_health_check_strict(client):
    """Integration test to verify that the health endpoint returns 200 OK
    and indicates that the database is healthy.
    This test runs in an environment where the database MUST be available (e.g. CI).
    """
    response = client.get("/health")

    # In integration test, we expect the system to be fully healthy
    assert response.status_code == 200

    data = response.json()
    assert data["code"] == 0
    assert data["data"]["status"] == "healthy"

    # Strict component contract (see main.py health_check): required
    # components must report healthy — a conditional check here used to test
    # a phantom "db" key and silently assert nothing.
    components = data["data"]["components"]
    assert components["database"] == "healthy"
    assert components["checkpointer"] == "healthy"
    assert components["scheduler"] == "running"
