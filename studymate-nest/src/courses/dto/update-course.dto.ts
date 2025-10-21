import { IsOptional, IsString } from 'class-validator';

export class UpdateCourseDto {
  @IsOptional() @IsString() title?: string;
  @IsOptional() @IsString() code?: string;
  @IsOptional() @IsString() description?: string;
}
