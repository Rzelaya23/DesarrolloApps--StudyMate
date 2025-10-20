import { IsString } from 'class-validator';
export class SubmitDto { @IsString() studentId: string; @IsString() content: string; }