from dataclasses import dataclass


@dataclass(frozen=True)
class Recommendation:
    kind: str
    title: str
    reason: str


def recommend(goal: str) -> list[Recommendation]:
    """Return starter recommendations. Replace with a trained PyTorch model later."""
    catalog = {
        "strength": [
            Recommendation("workout", "Upper/lower split", "Balances volume for compound lifts"),
            Recommendation("meal", "High-protein dinner", "Supports recovery after heavy sessions"),
        ],
        "endurance": [
            Recommendation("workout", "Zone 2 + intervals", "Builds aerobic base without overreach"),
            Recommendation("meal", "Carb-focused lunch", "Fuels longer sessions"),
        ],
    }
    return catalog.get(goal, catalog["strength"])
