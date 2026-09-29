import { Module } from '@nestjs/common';
import { fitFlowApi } from './api-surface';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { PlansModule } from './plans/plans.module';
import { SocialModule } from './social/social.module';

@Module({
  imports: [AuthModule, UsersModule, PlansModule, SocialModule],
})
export class AppModule {
  /** Auth is live. Profiles, workouts, community, and progress stay planned. */
  readonly api = fitFlowApi;
}
