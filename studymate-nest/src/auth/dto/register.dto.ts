import { IsEmail, IsString, MinLength } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class RegisterDto {
  @ApiProperty({
    example: 'Juan Pérez',
    description: 'Nombre completo del usuario a registrar.',
  })
  @IsString()
  name!: string;

  @ApiProperty({
    example: 'juan.perez@dominio.com',
    description: 'Correo electrónico único asociado a la nueva cuenta.',
  })
  @IsEmail()
  email!: string;

  @ApiProperty({
    example: 'contraseñaSegura2025',
    description: 'Contraseña de acceso. Debe tener al menos 6 caracteres.',
    minLength: 6,
  })
  @IsString()
  @MinLength(6)
  password!: string;
}
