import { IsISO8601, IsOptional, IsString } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';

export class UpdateEventDto {
  @ApiPropertyOptional({
    example: 'Examen Final de Derecho Mercantil',
    description: 'Nuevo título del evento (opcional).',
  })
  @IsOptional()
  @IsString()
  title?: string;

  @ApiPropertyOptional({
    example: 'Actualización: el examen incluirá un caso práctico adicional.',
    description: 'Descripción actualizada del evento (opcional).',
  })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiPropertyOptional({
    example: '2025-12-01T09:00:00Z',
    description: 'Nueva fecha y hora de inicio (opcional, formato ISO 8601).',
  })
  @IsOptional()
  @IsISO8601()
  startsAt?: string;

  @ApiPropertyOptional({
    example: '2025-12-01T11:00:00Z',
    description: 'Nueva fecha y hora de finalización (opcional, formato ISO 8601).',
  })
  @IsOptional()
  @IsISO8601()
  endsAt?: string;

  @ApiPropertyOptional({
    example: 'Sala de Juicios Orales, Piso 3',
    description: 'Nueva ubicación del evento (opcional).',
  })
  @IsOptional()
  @IsString()
  location?: string;
}
