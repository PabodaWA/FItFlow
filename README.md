# FitFlow

Fitness planning, nutrition tracking, and social accountability — rebuilt as a Flutter client with focused backend services.

## Project structure

```
fitflow/
├── frontend/                 # Flutter app (iOS, Android, Web)
├── backend/
│   ├── core-service/         # NestJS: users, plans, social
│   └── nutrition-service/    # FastAPI: nutrition tracking
├── ai-service/               # FastAPI + PyTorch: recommendations
├── docs/                     # Architecture notes and ADRs
└── .github/workflows/        # CI
```

## Prerequisites

- Flutter 3.44+
- Node.js 20+
- Python 3.12+

## Run locally

### Frontend

```bash
cd frontend
flutter pub get
flutter run
```

### Core service (NestJS)

```bash
cd backend/core-service
npm install
npm run start:dev
```

Listens on `http://localhost:3000`.

### Nutrition service (FastAPI)

```bash
cd backend/nutrition-service
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8001
```

### AI service (FastAPI + PyTorch)

```bash
cd ai-service
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8002
```

## Documentation

- [Tech stack summary](docs/tech-stack-summary.md)
- [Architecture ADR](docs/adr/ADR-001-architecture.md)
- [Android release signing](docs/android-release.md)
- [Google Play Console](docs/play-console.md)
- [Privacy policy](docs/privacy-policy.md) — also published at https://cdn.jsdelivr.net/gh/PabodaWA/FItFlow@main/docs/site/privacy/index.html
- [Release notes](docs/release-notes.md) — also published at https://cdn.jsdelivr.net/gh/PabodaWA/FItFlow@main/docs/site/release-notes/index.html
- [Comparison matrix](docs/comparison-matrix.xlsx)

