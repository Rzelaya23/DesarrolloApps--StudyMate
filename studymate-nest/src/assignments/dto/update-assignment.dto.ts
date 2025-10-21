import { IsOptional, IsString, IsISO8601, IsInt } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';

export class UpdateAssignmentDto {
  @ApiPropertyOptional({
    example: 'Nueva versión del proyecto final',
    description: 'Título actualizado de la asignación (opcional).',
  })
  @IsOptional()
  @IsString()
  title?: string;

  @ApiPropertyOptional({
    example: 'Actualizar el ensayo con un análisis adicional sobre la jurisprudencia reciente.',
    description: 'Descripción revisada o extendida de la tarea (opcional).',
  })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiPropertyOptional({
    example: '2025-11-20T23:59:59Z',
    description: 'Nueva fecha límite de entrega en formato ISO 8601 (opcional).',
  })
  @IsOptional()
  @IsISO8601()
  dueDate?: string;

  @ApiPropertyOptional({
    example: 2,
    description: 'Prioridad de la tarea (1 = alta, 2 = media, 3 = baja).',
  })
  @IsOptional()
  @IsInt()
  priority?: number;

  @ApiPropertyOptional({
    example: 'completed',
    description: 'Estado actualizado de la asignación (por ejemplo: pending, completed, overdue).',
  })
  @IsOptional()
  @IsString()
  status?: string;

  @ApiPropertyOptional({
    example: 'course-789',
    description: 'ID del curso al que está asociada la asignación (opcional).',
  })
  @IsOptional()
  @IsString()
  courseId?: string;
}
