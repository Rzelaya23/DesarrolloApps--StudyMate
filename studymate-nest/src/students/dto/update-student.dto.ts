import { IsOptional, IsString } from 'class-validator';
export class UpdateStudentDto {
  @IsOptional() @IsString() name?: string;
  @IsOptional() @IsString() avatarUrl?: string;
  @IsOptional() @IsString() timezone?: string; 
}
