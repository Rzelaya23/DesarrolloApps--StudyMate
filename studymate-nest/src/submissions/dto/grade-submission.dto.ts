import { IsNumber, IsOptional, IsString } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class GradeSubmissionDto {
  @ApiProperty({
    example: 9.5,
    description: 'Calificación numérica otorgada a la entrega.',
  })
  @IsNumber()
  grade!: number;

  @ApiPropertyOptional({
    example: 'Excelente trabajo. La argumentación es sólida y bien fundamentada.',
    description: 'Comentarios o retroalimentación adicional para el estudiante (opcional).',
  })
  @IsOptional()
  @IsString()
  feedback?: string;
}
