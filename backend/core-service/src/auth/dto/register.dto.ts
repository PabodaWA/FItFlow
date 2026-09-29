import { Transform } from 'class-transformer';
import {
  IsNotEmpty,
  IsString,
  Matches,
  MaxLength,
  MinLength,
} from 'class-validator';

const emailPattern = /^[^@\s]+@[^@\s]+\.[^@\s]+$/;

export class RegisterDto {
  @Transform(({ value }) => (typeof value === 'string' ? value.trim() : value))
  @IsString()
  @IsNotEmpty({ message: 'Enter your full name' })
  @MaxLength(80)
  name!: string;

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
