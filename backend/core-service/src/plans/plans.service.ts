import { Injectable } from '@nestjs/common';

@Injectable()
export class PlansService {
  findAll() {
    return [
      { id: 'p1', title: '4-day upper/lower', weeks: 8 },
    ];
  }
}
