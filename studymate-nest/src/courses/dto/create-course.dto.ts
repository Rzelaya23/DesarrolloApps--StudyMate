import { IsString, IsOptional } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateCourseDto {
  @ApiProperty({
    example: 'Derecho Constitucional I',
    description: 'Nombre oficial del curso.',
  })
  @IsString()
  title!: string;

  @ApiProperty({
    example: 'DCON101',
    description: 'Código único del curso dentro del sistema académico.',
  })
  @IsString()
  code!: string;

  @ApiPropertyOptional({
    example: 'Curso introductorio a los principios del derecho constitucional.',
    description: 'Descripción detallada del contenido y objetivos del curso (opcional).',
  })
  @IsOptional()
  @IsString()
  description?: string;
}
