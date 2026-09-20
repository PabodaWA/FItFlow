# ADR-001: Multi-service architecture

- Status: Accepted
- Date: 2026-09-20

## Context

FitFlow combines account management, workout planning, social features, nutrition tracking, and ML recommendations. Those concerns have different languages, release cadences, and scaling profiles.

## Decision

Use a Flutter frontend with three backend services:

1. **core-service** (NestJS) — users, plans, social
2. **nutrition-service** (FastAPI) — nutrition tracking
3. **ai-service** (FastAPI + PyTorch) — recommendations

The client talks to each service over HTTP. Services do not share a database.

## Consequences

**Positive**

- Nutrition and ML can iterate in Python without affecting the NestJS domain.
- Each service can be deployed and scaled on its own.
- Failures in recommendations do not take down plans or food logging.

**Negative**

- Cross-service workflows need explicit API contracts.
- Local development requires more running processes.
- Auth and user identity must be consistent across services.

## Alternatives considered

See [comparison-matrix.xlsx](../comparison-matrix.xlsx).
