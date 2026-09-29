import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { AuthService } from './auth.service';
import { AuthContext } from './auth.types';

export type AuthedRequest = {
  headers: { authorization?: string | string[] };
  auth?: AuthContext;
};

@Injectable()
export class AuthGuard implements CanActivate {
  constructor(private readonly authService: AuthService) {}

  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest<AuthedRequest>();
    const header = request.headers.authorization;
    if (!header || Array.isArray(header)) {
      throw new UnauthorizedException('Unauthorized');
    }

    const [scheme, token] = header.split(' ');
    if (scheme !== 'Bearer' || !token) {
      throw new UnauthorizedException('Unauthorized');
    }

    request.auth = this.authService.authenticate(token);
    return true;
  }
}
