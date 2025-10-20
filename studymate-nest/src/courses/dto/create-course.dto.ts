// src/courses/dto/create-course.dto.ts
import { IsString, IsOptional } from 'class-validator';

export class CreateCourseDto {
  @IsString()
  title!: string;

  @IsString()           // ← OBLIGATORIO para alinear con schema
  code!: string;

  @IsOptional()
  @IsString()
  description?: string;
}
