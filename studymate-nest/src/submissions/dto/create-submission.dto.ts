// src/submissions/dto/create-submission.dto.ts
import { IsString } from 'class-validator';

export class CreateSubmissionDto {
  @IsString() assignmentId!: string;
  @IsString() textBody!: string;
  @IsString() studentId!: string; // si lo tomas del token, quítalo y rellénalo en el controller
}
