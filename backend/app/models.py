from pydantic import BaseModel, Field


class VocabularyItem(BaseModel):
    id: str
    word: str
    article: str
    plural: str
    translations: list[str]


class VocabularyTopic(BaseModel):
    id: str
    name: str
    source_language_code: str = Field(alias="sourceLanguageCode")
    target_language_code: str = Field(alias="targetLanguageCode")
    items: list[VocabularyItem]


class VocabularyCatalog(BaseModel):
    schema_version: int = Field(alias="schemaVersion")
    topics: list[VocabularyTopic]


class HealthResponse(BaseModel):
    status: str