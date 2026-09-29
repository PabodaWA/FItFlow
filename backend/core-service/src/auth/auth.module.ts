import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { AUTH_DATABASE, createAuthDatabase } from './auth-database';
import { AuthController } from './auth.controller';
import { AuthGuard } from './auth.guard';
import { AuthService } from './auth.service';
import { ACCESS_TOKEN_TTL_SECONDS, jwtSecret } from './jwt-secret';

@Module({
  imports: [
    JwtModule.registerAsync({
      useFactory: () => ({
        secret: jwtSecret(),
        signOptions: { expiresIn: ACCESS_TOKEN_TTL_SECONDS },
      }),
    }),
  ],
  controllers: [AuthController],
  exports: [AUTH_DATABASE],
  providers: [
    AuthService,
    AuthGuard,
    {
      provide: AUTH_DATABASE,
      useFactory: createAuthDatabase,
    },
  ],
})
export class AuthModule {}
