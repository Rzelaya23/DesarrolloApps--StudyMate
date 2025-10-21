import { IsString } from 'class-validator';

export class CreateSubmissionDto {
  @IsString() assignmentId!: string;
  @IsString() textBody!: string;
  @IsString() studentId!: string; 
}
