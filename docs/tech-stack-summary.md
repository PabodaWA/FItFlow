# Tech stack summary

FitFlow is split into a Flutter client and three backend services so each domain can scale and deploy independently.

| Layer | Technology | Role |
| --- | --- | --- |
| Client | Flutter 3 (Dart) | iOS, Android, and Web UI |
| Core API | NestJS (TypeScript) | Users, workout plans, social features |
| Nutrition API | FastAPI (Python) | Food logging and macro tracking |
| Recommendations | FastAPI + PyTorch | Personalized workout and meal suggestions |
| CI | GitHub Actions | Analyze, test, and lint on every PR |

## Why this split

- **Flutter** gives one codebase for mobile and web.
- **NestJS** fits user, plan, and social modules with typed controllers and DI.
- **FastAPI** is a natural fit for nutrition and ML inference endpoints.
- **PyTorch** stays isolated in `ai-service` so model dependencies do not leak into the other APIs.

See [ADR-001](adr/ADR-001-architecture.md) for the architecture decision and [comparison-matrix.xlsx](comparison-matrix.xlsx) for alternatives considered.
