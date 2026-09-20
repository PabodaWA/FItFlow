import { Injectable } from '@nestjs/common';

@Injectable()
export class SocialService {
  feed() {
    return [
      { id: 's1', user: 'Alex', message: 'Finished week 2 of the strength plan' },
    ];
  }
}
