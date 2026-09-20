from pydantic import BaseModel


class FoodLog(BaseModel):
    id: str
    name: str
    calories: int
    meal: str


class NutritionSummary(BaseModel):
    calories: int
    protein_g: int
    carbs_g: int
    fat_g: int
