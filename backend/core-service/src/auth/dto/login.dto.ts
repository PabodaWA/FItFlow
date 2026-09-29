import { Transform } from 'class-transformer';
import { IsString, Matches, MaxLength, MinLength } from 'class-validator';

const emailPattern = /^[^@\s]+@[^@\s]+\.[^@\s]+$/;

export class LoginDto {
  @Transform(({ value }) =>
    typeof value === 'string' ? value.trim().toLowerCase() : value,
  )
  @IsString()
  @Matches(emailPattern, { message: 'Enter a valid email' })
  @MaxLength(254)
  email!: string;

  @IsString()
  @MinLength(8, { message: 'Use at least 8 characters' })
  @MaxLength(128)
  password!: string;
}
