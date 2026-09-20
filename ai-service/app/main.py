from fastapi import FastAPI
from pydantic import BaseModel

from app.recommender import recommend

app = FastAPI(title="FitFlow AI Service", version="0.1.0")


class RecommendRequest(BaseModel):
    goal: str = "strength"


class RecommendItem(BaseModel):
    kind: str
    title: str
    reason: str


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok", "service": "ai-service"}


@app.post("/recommend", response_model=list[RecommendItem])
def create_recommendations(body: RecommendRequest) -> list[RecommendItem]:
    return [
        RecommendItem(kind=item.kind, title=item.title, reason=item.reason)
        for item in recommend(body.goal)
    ]
