from fastapi.testclient import TestClient

from app import app

client = TestClient(app)


def test_health() -> None:
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_version_defaults() -> None:
    response = client.get("/version")
    assert response.status_code == 200
    assert response.json() == {"version": "0.0.0-dev", "commit": "local"}
