from fastapi import APIRouter

from app.models import FoodLog, NutritionSummary

router = APIRouter()


@router.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok", "service": "nutrition-service"}


@router.get("/summary", response_model=NutritionSummary)
def daily_summary() -> NutritionSummary:
    return NutritionSummary(calories=1840, protein_g=132, carbs_g=180, fat_g=58)


@router.get("/logs", response_model=list[FoodLog])
def list_logs() -> list[FoodLog]:
    return [
        FoodLog(id="n1", name="Grilled chicken bowl", calories=620, meal="lunch"),
    ]
