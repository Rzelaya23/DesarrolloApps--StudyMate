import { IsOptional, IsString } from 'class-validator';

export class CreateCourseDto {
  @IsString()
  code!: string;

  @IsString()
  title!: string;

  @IsOptional() @IsString()
  description?: string;

  @IsOptional() @IsString()
  teacher?: string;
}
