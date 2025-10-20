// src/submissions/dto/grade-submission.dto.ts
import { IsNumber, IsOptional, IsString } from 'class-validator';
export class GradeSubmissionDto {
  @IsNumber() grade!: number;
  @IsOptional() @IsString() feedback?: string;
}
