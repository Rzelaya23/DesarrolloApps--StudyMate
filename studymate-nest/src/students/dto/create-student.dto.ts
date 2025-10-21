import { IsEmail, IsOptional, IsString, MinLength } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateStudentDto {
  @ApiProperty({
    example: 'Laura Martínez',
    description: 'Nombre completo del estudiante.',
  })
  @IsString()
  name!: string;

  @ApiProperty({
    example: 'laura.martinez@dominio.com',
    description: 'Correo electrónico del estudiante (único en el sistema).',
  })
  @IsEmail()
  email!: string;

  @ApiProperty({
    example: 'contraseñaSegura2025',
    description: 'Contraseña de acceso. Debe tener al menos 8 caracteres.',
    minLength: 8,
  })
  @IsString()
  @MinLength(8)
  password!: string;

  @ApiPropertyOptional({
    example: 'https://cdn.ejemplo.com/avatars/laura.png',
    description: 'URL del avatar o imagen de perfil del estudiante (opcional).',
  })
  @IsOptional()
  @IsString()
  avatarUrl?: string;

  @ApiPropertyOptional({
    example: 'America/El_Salvador',
    description: 'Zona horaria del estudiante. Por defecto: America/El_Salvador (opcional).',
  })
  @IsOptional()
  @IsString()
  timezone?: string;
}
