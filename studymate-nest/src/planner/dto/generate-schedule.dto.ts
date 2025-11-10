import { ArrayMinSize, IsArray, IsBoolean, IsDateString, IsEnum, IsInt, IsNotEmpty, IsOptional, IsPositive, IsString, Matches } from 'class-validator';

class GenActivityInput {
  @IsString()
  @IsNotEmpty()
  title: string;

  @IsInt()
  @IsPositive()
  durationMin: number;

  @IsEnum(['BAJA','MEDIA','ALTA'], { each: false } as any)
  priority: 'BAJA' | 'MEDIA' | 'ALTA';

  @IsEnum(['FACIL','INTERMEDIA','DIFICIL'], { each: false } as any)
  difficulty: 'FACIL' | 'INTERMEDIA' | 'DIFICIL';
}

export class GenerateScheduleDto {
  @IsDateString()
  date: string;

  @Matches(/^\d{2}:\d{2}$/)
  start: string;

  @Matches(/^\d{2}:\d{2}$/)
  end: string;

  @IsInt()
  @IsPositive()
  focusMin: number;

  @IsInt()
  @IsPositive()
  restMin: number;

  @IsArray()
  @ArrayMinSize(1)
  activities: GenActivityInput[];

  @IsBoolean()
  @IsOptional()
  persist?: boolean;
}
