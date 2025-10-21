import { IsEmail } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class ForgotPasswordDto {
  @ApiProperty({
    example: 'usuario@dominio.com',
    description: 'Correo electrónico registrado del usuario que solicita el restablecimiento de contraseña.',
  })
  @IsEmail()
  email!: string;
}
