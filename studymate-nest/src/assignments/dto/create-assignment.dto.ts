import { IsISO8601, IsOptional, IsString } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateAssignmentDto {
  @ApiProperty({
    example: 'abc123',
    description: 'Identificador único del curso al que pertenece la asignación.',
  })
  @IsString()
  courseId: string;

  @ApiProperty({
    example: 'Ensayo sobre Derecho Mercantil',
    description: 'Título descriptivo de la asignación o tarea.',
  })
  @IsString()
  title: string;

  @ApiPropertyOptional({
    example: 'Redactar un ensayo de mínimo 1000 palabras sobre la evolución del Derecho Mercantil.',
    description: 'Descripción detallada de la tarea (opcional).',
  })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiPropertyOptional({
    example: '2025-11-15T23:59:59Z',
    description: 'Fecha límite de entrega en formato ISO 8601 (opcional).',
  })
  @IsOptional()
  @IsISO8601()
  dueDate?: string;
}
