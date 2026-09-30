import * as fs from 'fs';
import * as path from 'path';
import { SessionRecord, UserRecord } from './auth.types';

export const AUTH_DATABASE = Symbol('AUTH_DATABASE');

export class DuplicateEmailError extends Error {
  constructor() {
    super('An account with this email already exists');
    this.name = 'DuplicateEmailError';
  }
}

export interface AuthDatabase {
  findUserByEmail(email: string): UserRecord | undefined;
  findUserById(id: string): UserRecord | undefined;
  insertUser(user: UserRecord): void;
  saveSession(session: SessionRecord): void;
  findSession(jti: string): SessionRecord | undefined;
  deleteSession(jti: string): void;
}

interface AuthSnapshot {
  users: UserRecord[];
  sessions: SessionRecord[];
}

export class MemoryAuthDatabase implements AuthDatabase {
  private readonly usersByEmail = new Map<string, UserRecord>();
  private readonly usersById = new Map<string, UserRecord>();
  private readonly sessions = new Map<string, SessionRecord>();

  findUserByEmail(email: string): UserRecord | undefined {
    return this.usersByEmail.get(email);
  }

  findUserById(id: string): UserRecord | undefined {
    return this.usersById.get(id);
  }

  insertUser(user: UserRecord): void {
    if (this.usersByEmail.has(user.email)) {
      throw new DuplicateEmailError();
    }
    this.usersByEmail.set(user.email, user);
    this.usersById.set(user.id, user);
  }

  saveSession(session: SessionRecord): void {
    this.sessions.set(session.jti, session);
  }

  findSession(jti: string): SessionRecord | undefined {
    const session = this.sessions.get(jti);
    if (!session) return undefined;
    if (session.expiresAt <= Date.now()) {
      this.sessions.delete(jti);
      return undefined;
    }
    return session;
  }

  deleteSession(jti: string): void {
    this.sessions.delete(jti);
  }

  snapshot(): AuthSnapshot {
    return {
      users: [...this.usersById.values()],
      sessions: [...this.sessions.values()],
    };
  }

  hydrate(state: AuthSnapshot): void {
    this.usersByEmail.clear();
    this.usersById.clear();
    this.sessions.clear();
    for (const user of state.users ?? []) {
      this.usersByEmail.set(user.email, user);
      this.usersById.set(user.id, user);
    }
    for (const session of state.sessions ?? []) {
      this.sessions.set(session.jti, session);
    }
  }
}

export class FileAuthDatabase implements AuthDatabase {
  private readonly memory = new MemoryAuthDatabase();

  constructor(private readonly filePath: string) {
    this.load();
  }

  findUserByEmail(email: string): UserRecord | undefined {
    return this.memory.findUserByEmail(email);
  }

  findUserById(id: string): UserRecord | undefined {
    return this.memory.findUserById(id);
  }

  insertUser(user: UserRecord): void {
    this.memory.insertUser(user);
    this.persist();
  }

  saveSession(session: SessionRecord): void {
    this.memory.saveSession(session);
    this.persist();
  }

  findSession(jti: string): SessionRecord | undefined {
    const before = this.memory.snapshot().sessions.length;
    const session = this.memory.findSession(jti);
    if (this.memory.snapshot().sessions.length !== before) {
      this.persist();
    }
    return session;
  }

  deleteSession(jti: string): void {
    this.memory.deleteSession(jti);
    this.persist();
  }

  private load(): void {
    if (!fs.existsSync(this.filePath)) return;
    const raw = fs.readFileSync(this.filePath, 'utf8');
    const parsed = JSON.parse(raw) as AuthSnapshot;
    this.memory.hydrate({
      users: Array.isArray(parsed.users) ? parsed.users : [],
      sessions: Array.isArray(parsed.sessions) ? parsed.sessions : [],
    });
  }

  private persist(): void {
    fs.mkdirSync(path.dirname(this.filePath), { recursive: true });
    const tempPath = `${this.filePath}.tmp`;
    fs.writeFileSync(tempPath, JSON.stringify(this.memory.snapshot()));
    fs.rmSync(this.filePath, { force: true });
    fs.renameSync(tempPath, this.filePath);
  }
}

export function createAuthDatabase(): AuthDatabase {
  if (
    process.env.NODE_ENV === 'test' ||
    process.env.AUTH_STORE_PATH === ':memory:'
  ) {
    return new MemoryAuthDatabase();
  }

  const filePath =
    process.env.AUTH_STORE_PATH ??
    path.join(process.cwd(), 'data', 'auth-store.json');
  return new FileAuthDatabase(filePath);
}
