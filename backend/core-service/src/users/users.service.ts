import { Injectable } from '@nestjs/common';

@Injectable()
export class UsersService {
  findAll() {
    return [
      { id: 'u1', name: 'Alex Rivera', goal: 'strength' },
    ];
  }
}
