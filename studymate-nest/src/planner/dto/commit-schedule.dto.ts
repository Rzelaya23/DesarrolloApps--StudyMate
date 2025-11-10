import { IsArray, IsDateString, IsNotEmpty, IsString, Matches } from 'class-validator';

class BlockInput {
  @IsString()
  @IsNotEmpty()
  title: string;

  @Matches(/^\d{2}:\d{2}$/)
  start: string;

  @Matches(/^\d{2}:\d{2}$/)
  end: string;
}

export class CommitScheduleDto {
  @IsDateString()
  date: string;

  @IsString()
  @IsNotEmpty()
  version: string;

  @IsArray()
  blocks: BlockInput[];
}
