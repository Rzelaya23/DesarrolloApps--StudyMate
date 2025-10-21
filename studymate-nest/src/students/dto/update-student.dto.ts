import { IsOptional, IsString } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';

export class UpdateStudentDto {
  @ApiPropertyOptional({
    example: 'Laura G. Martínez',
    description: 'Nombre actualizado del estudiante (opcional).',
  })
  @IsOptional()
  @IsString()
  name?: string;

  @ApiPropertyOptional({
    example: 'https://cdn.ejemplo.com/avatars/laura_new.png',
    description: 'Nueva URL del avatar del estudiante (opcional).',
  })
  @IsOptional()
  @IsString()
  avatarUrl?: string;

  @ApiPropertyOptional({
    example: 'America/Mexico_City',
    description: 'Nueva zona horaria del estudiante (opcional). Por defecto: America/El_Salvador.',
  })
  @IsOptional()
  @IsString()
  timezone?: string;
}
