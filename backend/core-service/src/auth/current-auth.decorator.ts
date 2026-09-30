import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import { AuthedRequest } from './auth.guard';
import { AuthContext } from './auth.types';

export const CurrentAuth = createParamDecorator(
  (_data: unknown, context: ExecutionContext): AuthContext => {
    const request = context.switchToHttp().getRequest<AuthedRequest>();
    if (!request.auth) {
      throw new Error('CurrentAuth requires AuthGuard');
    }
    return request.auth;
  },
);
