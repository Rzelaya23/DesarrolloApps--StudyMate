import { IsDateString, IsEnum, IsInt, IsNotEmpty, IsPositive, IsString } from 'class-validator';

export class CreatePlannerActivityDto {
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

  @IsDateString()
  date: string;
}
