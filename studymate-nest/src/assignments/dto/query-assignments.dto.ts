import { IsOptional, IsString, IsISO8601, IsInt, Min } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiPropertyOptional } from '@nestjs/swagger';

export class QueryAssignmentsDto {
  @ApiPropertyOptional({
    example: 'pending',
    description: 'Estado de la tarea para filtrar (por ejemplo: pending, completed, overdue).',
  })
  @IsOptional()
  @IsString()
  status?: string;

  @ApiPropertyOptional({
    example: '2025-10-01T00:00:00Z',
    description: 'Filtra tareas con fecha de entrega posterior o igual a esta fecha.',
  })
  @IsOptional()
  @IsISO8601()
  due_from?: string;

  @ApiPropertyOptional({
    example: '2025-12-31T23:59:59Z',
    description: 'Filtra tareas con fecha de entrega anterior o igual a esta fecha.',
  })
  @IsOptional()
  @IsISO8601()
  due_to?: string;

  @ApiPropertyOptional({
    example: 'abc123',
    description: 'Identificador del curso para filtrar asignaciones específicas.',
  })
  @IsOptional()
  @IsString()
  courseId?: string;

  @ApiPropertyOptional({
    example: 2,
    description: 'Prioridad mínima de la tarea (por ejemplo, 1 = alta, 2 = media, 3 = baja).',
  })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  priority?: number;

  @ApiPropertyOptional({
    example: 1,
    description: 'Número de página para la paginación de resultados (por defecto: 1).',
  })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number = 1;

  @ApiPropertyOptional({
    example: 10,
    description: 'Cantidad de resultados por página (por defecto: 10).',
  })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  limit?: number = 10;
}
