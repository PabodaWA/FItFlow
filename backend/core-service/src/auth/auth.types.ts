export interface UserRecord {
  id: string;
  name: string;
  email: string;
  passwordHash: string;
  createdAt: string;
}

export interface PublicUser {
  id: string;
  name: string;
  email: string;
}

export interface SessionRecord {
  jti: string;
  userId: string;
  expiresAt: number;
}

export interface AuthContext {
  jti: string;
  user: PublicUser;
}

export function toPublicUser(user: UserRecord): PublicUser {
  return { id: user.id, name: user.name, email: user.email };
}
