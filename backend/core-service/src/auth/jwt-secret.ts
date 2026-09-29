const DEV_SECRET = 'fitflow-local-dev-secret-do-not-use-in-prod';

export function jwtSecret(): string {
  const configured = process.env.JWT_SECRET?.trim();
  if (!configured) {
    if (process.env.NODE_ENV === 'production') {
      throw new Error('JWT_SECRET is required in production');
    }
    return DEV_SECRET;
  }
  if (configured.length < 32) {
    throw new Error('JWT_SECRET must be at least 32 characters');
  }
  return configured;
}

export function bcryptRounds(): number {
  const parsed = Number(process.env.BCRYPT_ROUNDS ?? 12);
  if (!Number.isInteger(parsed) || parsed < 4 || parsed > 15) {
    return 12;
  }
  return parsed;
}

export const ACCESS_TOKEN_TTL_SECONDS = 60 * 60 * 24 * 7;
