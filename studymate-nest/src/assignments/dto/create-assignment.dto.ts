import { IsISO8601, IsOptional, IsString } from 'class-validator';
export class CreateAssignmentDto {
  @IsString() courseId: string;
  @IsString() title: string;
  @IsOptional() @IsString() description?: string;
  @IsOptional() @IsISO8601() dueDate?: string;
}