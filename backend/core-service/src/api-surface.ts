/**
 * FitFlow REST boundaries.
 *
 * Authentication is implemented on core-service. The other resources match
 * the Flutter models and stay on the service that ADR-001 already assigns
 * them. Those routes are not implemented yet.
 */
export const fitFlowApi = {
  coreService: {
    authentication: {
      status: 'implemented',
      routes: [
        'POST /auth/register',
        'POST /auth/login',
        'POST /auth/logout',
        'GET /auth/me',
      ],
    },
    profiles: {
      status: 'planned',
      routes: ['GET /profiles/me', 'PATCH /profiles/me'],
    },
    workouts: {
      status: 'planned',
      routes: ['GET /workouts', 'GET /workouts/:id', 'POST /workouts'],
    },
    exercises: {
      status: 'planned',
      routes: ['GET /exercises', 'GET /exercises/:id'],
    },
    posts: {
      status: 'planned',
      routes: ['GET /posts', 'POST /posts', 'GET /posts/:id'],
    },
    likes: {
      status: 'planned',
      routes: ['POST /posts/:id/likes', 'DELETE /posts/:id/likes'],
    },
    comments: {
      status: 'planned',
      routes: ['GET /posts/:id/comments', 'POST /posts/:id/comments'],
    },
    progress: {
      status: 'planned',
      routes: ['GET /progress', 'POST /progress/weight'],
    },
  },
  nutritionService: {
    nutrition: {
      status: 'planned',
      routes: ['GET /summary', 'GET /logs', 'POST /logs'],
    },
    meals: {
      status: 'planned',
      routes: ['GET /meals', 'POST /meals'],
    },
  },
} as const;
