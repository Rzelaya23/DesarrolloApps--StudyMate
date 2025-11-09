import { IsString, MaxLength, MinLength } from 'class-validator';

export class ChatDto {
  @IsString()
  @MinLength(1)
  @MaxLength(16000)
  message: string;
}
