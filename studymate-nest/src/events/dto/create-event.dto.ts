import { IsISO8601, IsOptional, IsString } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateEventDto {
  @ApiProperty({
    example: 'Examen Final de Derecho Civil',
    description: 'Título descriptivo del evento.',
  })
  @IsString()
  title!: string;

  @ApiPropertyOptional({
    example: 'Examen presencial en el aula magna. Duración: 2 horas.',
    description: 'Descripción detallada del evento (opcional).',
  })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiProperty({
    example: '2025-12-01T08:00:00Z',
    description: 'Fecha y hora de inicio del evento en formato ISO 8601.',
  })
  @IsISO8601()
  startsAt!: string;

  @ApiProperty({
    example: '2025-12-01T10:00:00Z',
    description: 'Fecha y hora de finalización del evento en formato ISO 8601.',
  })
  @IsISO8601()
  endsAt!: string;

  @ApiPropertyOptional({
    example: 'Aula Magna, Edificio Central, ESEN',
    description: 'Ubicación física o virtual del evento (opcional).',
  })
  @IsOptional()
  @IsString()
  location?: string;
}
