import * as fs from 'fs';
import * as os from 'os';
import * as path from 'path';
import { FileAuthDatabase } from './auth-database';
import { UserRecord } from './auth.types';

describe('FileAuthDatabase', () => {
  it('reloads accounts from disk', () => {
    const filePath = path.join(
      os.tmpdir(),
      `fitflow-auth-${Date.now()}-${Math.random()}.json`,
    );
    const user: UserRecord = {
      id: 'u1',
      name: 'Ada Lovelace',
      email: 'ada@fitflow.app',
      passwordHash: '$2a$04$hash',
      createdAt: '2026-09-30T00:00:00.000Z',
    };

    try {
      const created = new FileAuthDatabase(filePath);
      created.insertUser(user);
      created.saveSession({
        jti: 'session-1',
        userId: 'u1',
        expiresAt: Date.now() + 60_000,
      });

      const reloaded = new FileAuthDatabase(filePath);
      expect(reloaded.findUserByEmail('ada@fitflow.app')).toEqual(user);
      expect(reloaded.findSession('session-1')?.userId).toBe('u1');

      reloaded.deleteSession('session-1');
      const afterLogout = new FileAuthDatabase(filePath);
      expect(afterLogout.findSession('session-1')).toBeUndefined();
    } finally {
      fs.rmSync(filePath, { force: true });
      fs.rmSync(`${filePath}.tmp`, { force: true });
    }
  });
});
