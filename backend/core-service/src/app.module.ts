import { Module } from '@nestjs/common';
import { UsersModule } from './users/users.module';
import { PlansModule } from './plans/plans.module';
import { SocialModule } from './social/social.module';

@Module({
  imports: [UsersModule, PlansModule, SocialModule],
})
export class AppModule {}
