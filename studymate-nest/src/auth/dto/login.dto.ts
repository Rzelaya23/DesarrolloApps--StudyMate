import { IsEmail, IsString, MinLength } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class LoginDto {
  @ApiProperty({
    example: 'usuario@dominio.com',
    description: 'Correo electrónico asociado a la cuenta del usuario.',
  })
  @IsEmail()
  email!: string;

  @ApiProperty({
    example: 'password123',
    description: 'Contraseña del usuario. Debe tener al menos 6 caracteres.',
    minLength: 6,
  })
  @IsString()
  @MinLength(6)
  password!: string;
}
