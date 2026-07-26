import json
from pathlib import Path

from fastapi import FastAPI, HTTPException

from app.models import HealthResponse, VocabularyCatalog

app = FastAPI(title="fastVocab Vocabulary API", version="1.0.0")
VOCABULARY_PATH = Path(__file__).with_name("vocabulary.json")


def load_catalog() -> VocabularyCatalog:
    with VOCABULARY_PATH.open(encoding="utf-8") as vocabulary_file:
        return VocabularyCatalog.model_validate(json.load(vocabulary_file))


@app.get("/health", response_model=HealthResponse)
def health() -> HealthResponse:
    return HealthResponse(status="ok")


@app.get("/v1/topics", response_model=VocabularyCatalog)
def topics() -> VocabularyCatalog:
    return load_catalog()


@app.get("/v1/topics/{topic_id}/vocabulary", response_model=VocabularyCatalog)
def topic_vocabulary(topic_id: str) -> VocabularyCatalog:
    catalog = load_catalog()
    topic = next((item for item in catalog.topics if item.id == topic_id), None)
    if topic is None:
        raise HTTPException(status_code=404, detail="Topic not found")
    return VocabularyCatalog(schemaVersion=catalog.schema_version, topics=[topic])