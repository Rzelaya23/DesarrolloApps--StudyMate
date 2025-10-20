import { IsISO8601, IsOptional, IsString } from 'class-validator';
export class UpdateEventDto {
  @IsOptional() @IsString() title?: string;
  @IsOptional() @IsString() description?: string;
  @IsOptional() @IsISO8601() startsAt?: string;
  @IsOptional() @IsISO8601() endsAt?: string;
  @IsOptional() @IsString() location?: string;
}