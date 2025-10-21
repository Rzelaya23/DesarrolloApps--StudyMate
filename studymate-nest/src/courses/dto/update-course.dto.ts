import { IsOptional, IsString } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';

export class UpdateCourseDto {
  @ApiPropertyOptional({
    example: 'Derecho Constitucional II',
    description: 'Nuevo título del curso (opcional).',
  })
  @IsOptional()
  @IsString()
  title?: string;

  @ApiPropertyOptional({
    example: 'DCON102',
    description: 'Nuevo código del curso (opcional).',
  })
  @IsOptional()
  @IsString()
  code?: string;

  @ApiPropertyOptional({
    example: 'Curso avanzado que profundiza en el estudio de la Constitución.',
    description: 'Descripción actualizada del curso (opcional).',
  })
  @IsOptional()
  @IsString()
  description?: string;
}
