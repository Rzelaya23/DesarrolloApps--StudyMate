import { IsOptional, IsString, IsISO8601, IsInt } from 'class-validator';
export class UpdateAssignmentDto {
  @IsOptional() @IsString() title?: string;
  @IsOptional() @IsString() description?: string;
  @IsOptional() @IsISO8601() dueDate?: string;
  @IsOptional() @IsInt() priority?: number;
  @IsOptional() @IsString() status?: string;
  @IsOptional() @IsString() courseId?: string;
}
