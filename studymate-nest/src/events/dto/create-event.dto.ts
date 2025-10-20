import { IsISO8601, IsOptional, IsString } from 'class-validator';
export class CreateEventDto {
  @IsString() title!: string;
  @IsOptional() @IsString() description?: string;
  @IsISO8601() startsAt!: string;
  @IsISO8601() endsAt!: string;
  @IsOptional() @IsString() location?: string;
}
