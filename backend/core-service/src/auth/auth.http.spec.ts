import { INestApplication } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import request = require('supertest');
import { configureApp } from '../app-config';
import { AppModule } from '../app.module';
import { AUTH_DATABASE, MemoryAuthDatabase } from './auth-database';

process.env.BCRYPT_ROUNDS = '4';
process.env.JWT_SECRET = 'test-secret-must-be-at-least-32-characters';

describe('Authentication API', () => {
  let app: INestApplication;
  let database: MemoryAuthDatabase;

  beforeAll(async () => {
    database = new MemoryAuthDatabase();
    const moduleRef = await Test.createTestingModule({
      imports: [AppModule],
    })
      .overrideProvider(AUTH_DATABASE)
      .useValue(database)
      .compile();
    app = moduleRef.createNestApplication();
    configureApp(app);
    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  it('registers, returns the current user, then rejects the token after logout', async () => {
    const created = await request(app.getHttpServer())
      .post('/auth/register')
      .send({
        name: '  Ada Lovelace  ',
        email: 'Ada@FitFlow.app',
        password: 'password1',
      })
      .expect(201);

    expect(created.body.tokenType).toBe('Bearer');
    expect(created.body.accessToken).toEqual(expect.any(String));
    expect(created.body.user).toEqual({
      id: expect.any(String),
      name: 'Ada Lovelace',
      email: 'ada@fitflow.app',
    });
    expect(JSON.stringify(created.body)).not.toContain('password');

    const stored = database.findUserByEmail('ada@fitflow.app');
    expect(stored?.passwordHash.startsWith('$2')).toBe(true);
    expect(stored?.passwordHash).not.toBe('password1');

    const token = created.body.accessToken as string;
    const me = await request(app.getHttpServer())
      .get('/auth/me')
      .set('Authorization', `Bearer ${token}`)
      .expect(200);

    expect(me.body).toEqual(created.body.user);

    await request(app.getHttpServer())
      .post('/auth/logout')
      .set('Authorization', `Bearer ${token}`)
      .expect(204);

    await request(app.getHttpServer())
      .get('/auth/me')
      .set('Authorization', `Bearer ${token}`)
      .expect(401);

    await request(app.getHttpServer())
      .post('/auth/logout')
      .set('Authorization', `Bearer ${token}`)
      .expect(401);
  });

  it('logs in with the registered password and rejects a wrong one', async () => {
    const loggedIn = await request(app.getHttpServer())
      .post('/auth/login')
      .send({ email: 'ada@fitflow.app', password: 'password1' })
      .expect(200);

    expect(loggedIn.body.user.email).toBe('ada@fitflow.app');
    expect(loggedIn.body.accessToken).toEqual(expect.any(String));

    const rejected = await request(app.getHttpServer())
      .post('/auth/login')
      .send({ email: 'ada@fitflow.app', password: 'password2' })
      .expect(401);

    expect(rejected.body.message).toBe('Invalid email or password');

    const unknown = await request(app.getHttpServer())
      .post('/auth/login')
      .send({ email: 'missing@fitflow.app', password: 'password1' })
      .expect(401);

    expect(unknown.body.message).toBe('Invalid email or password');
  });

  it('rejects a duplicate email and invalid registration input', async () => {
    const duplicate = await request(app.getHttpServer())
      .post('/auth/register')
      .send({
        name: 'Ada Lovelace',
        email: 'ada@fitflow.app',
        password: 'password1',
      })
      .expect(409);

    expect(duplicate.body.message).toBe(
      'An account with this email already exists',
    );

    await request(app.getHttpServer())
      .post('/auth/register')
      .send({ name: 'Ada', email: 'not-an-email', password: 'short' })
      .expect(400);

    await request(app.getHttpServer()).get('/auth/me').expect(401);
  });
});
