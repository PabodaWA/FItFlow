import { UsersService } from './users.service';

describe('UsersService', () => {
  it('returns seeded users', () => {
    const service = new UsersService();
    expect(service.findAll()).toHaveLength(1);
  });
});
