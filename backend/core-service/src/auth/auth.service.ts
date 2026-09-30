import {
  ConflictException,
  Inject,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { compare, hash } from 'bcryptjs';
import { randomUUID } from 'crypto';
import {
  AUTH_DATABASE,
  AuthDatabase,
  DuplicateEmailError,
} from './auth-database';
import {
  ACCESS_TOKEN_TTL_SECONDS,
  bcryptRounds,
} from './jwt-secret';
import {
  AuthContext,
  PublicUser,
  toPublicUser,
  UserRecord,
} from './auth.types';
export interface AuthResponse {
  accessToken: string;
  tokenType: 'Bearer';
  user: PublicUser;
}

interface TokenPayload {
  sub: string;
  jti: string;
}

@Injectable()
export class AuthService {
  private dummyHash: Promise<string> | undefined;

  constructor(
    @Inject(AUTH_DATABASE) private readonly database: AuthDatabase,
    private readonly jwtService: JwtService,
  ) {}

  async register(input: {
    name: string;
    email: string;
    password: string;
  }): Promise<AuthResponse> {
    const passwordHash = await hash(input.password, bcryptRounds());
    const user: UserRecord = {
      id: randomUUID(),
      name: input.name,
      email: input.email,
      passwordHash,
      createdAt: new Date().toISOString(),
    };

    try {
      this.database.insertUser(user);
    } catch (error) {
      if (error instanceof DuplicateEmailError) {
        throw new ConflictException(
          'An account with this email already exists',
        );
      }
      throw error;
    }

    return this.issue(user);
  }

  async login(input: { email: string; password: string }): Promise<AuthResponse> {
    const user = this.database.findUserByEmail(input.email);
    const passwordHash = user?.passwordHash ?? (await this.placeholderHash());
    const matches = await compare(input.password, passwordHash);
    if (!user || !matches) {
      throw new UnauthorizedException('Invalid email or password');
    }
    return this.issue(user);
  }

  logout(jti: string): void {
    this.database.deleteSession(jti);
  }

  authenticate(token: string): AuthContext {
    let payload: TokenPayload;
    try {
      const decoded = this.jwtService.verify<TokenPayload>(token);
      if (!decoded?.sub || !decoded.jti) {
        throw new UnauthorizedException('Unauthorized');
      }
      payload = decoded;
    } catch (error) {
      if (error instanceof UnauthorizedException) throw error;
      throw new UnauthorizedException('Unauthorized');
    }

    const session = this.database.findSession(payload.jti);
    if (!session || session.userId !== payload.sub) {
      throw new UnauthorizedException('Unauthorized');
    }

    const user = this.database.findUserById(session.userId);
    if (!user) {
      throw new UnauthorizedException('Unauthorized');
    }

    return { jti: payload.jti, user: toPublicUser(user) };
  }

  private async issue(user: UserRecord): Promise<AuthResponse> {
    const jti = randomUUID();
    const accessToken = await this.jwtService.signAsync(
      { sub: user.id },
      { jwtid: jti, expiresIn: ACCESS_TOKEN_TTL_SECONDS },
    );
    this.database.saveSession({
      jti,
      userId: user.id,
      expiresAt: Date.now() + ACCESS_TOKEN_TTL_SECONDS * 1000,
    });
    return {
      accessToken,
      tokenType: 'Bearer',
      user: toPublicUser(user),
    };
  }

  private placeholderHash(): Promise<string> {
    this.dummyHash ??= hash('fitflow-placeholder-password', bcryptRounds());
    return this.dummyHash;
  }
}
