from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_health() -> None:
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_topics_return_usable_catalog() -> None:
    response = client.get("/v1/topics")
    assert response.status_code == 200
    catalog = response.json()
    assert catalog["schemaVersion"] == 1
    assert all(len(topic["items"]) >= 3 for topic in catalog["topics"])


def test_topic_vocabulary_and_missing_topic() -> None:
    response = client.get("/v1/topics/household-a1/vocabulary")
    assert response.status_code == 200
    assert response.json()["topics"][0]["id"] == "household-a1"
    assert client.get("/v1/topics/missing/vocabulary").status_code == 404