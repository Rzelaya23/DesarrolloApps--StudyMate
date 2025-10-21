import { IsOptional, IsString, IsObject } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';

export class UpdatePreferencesDto {
  @ApiPropertyOptional({
    example: 'dark',
    description: 'Tema visual de la plataforma. Puede ser "light" o "dark".',
  })
  @IsOptional()
  @IsString()
  theme?: string;

  @ApiPropertyOptional({
    example: { email: true, push: false },
    description: 'Configuración por defecto de recordatorios y notificaciones.',
  })
  @IsOptional()
  @IsObject()
  reminderDefaults?: Record<string, any>;

  @ApiPropertyOptional({
    example: 'monday',
    description: 'Día con el que inicia la semana en el calendario. Ej.: monday o sunday.',
  })
  @IsOptional()
  @IsString()
  weekStartsOn?: string;

  @ApiPropertyOptional({
    example: 'month',
    description: 'Vista predeterminada del calendario. Ej.: day, week o month.',
  })
  @IsOptional()
  @IsString()
  calendarView?: string;
}
