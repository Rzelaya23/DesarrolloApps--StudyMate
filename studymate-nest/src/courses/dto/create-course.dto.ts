import { IsString, IsOptional } from 'class-validator';

export class CreateCourseDto {
  @IsString()
  title!: string;

  @IsString()           
  code!: string;

  @IsOptional()
  @IsString()
  description?: string;
}
