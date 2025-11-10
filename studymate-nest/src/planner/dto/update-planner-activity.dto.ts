import { IsDateString, IsEnum, IsInt, IsOptional, IsPositive, IsString } from 'class-validator';

export class UpdatePlannerActivityDto {
  @IsString()
  @IsOptional()
  title?: string;

  @IsInt()
  @IsPositive()
  @IsOptional()
  durationMin?: number;

  @IsEnum(['BAJA','MEDIA','ALTA'], { each: false } as any)
  @IsOptional()
  priority?: 'BAJA' | 'MEDIA' | 'ALTA';

  @IsEnum(['FACIL','INTERMEDIA','DIFICIL'], { each: false } as any)
  @IsOptional()
  difficulty?: 'FACIL' | 'INTERMEDIA' | 'DIFICIL';

  @IsDateString()
  @IsOptional()
  date?: string;
}
