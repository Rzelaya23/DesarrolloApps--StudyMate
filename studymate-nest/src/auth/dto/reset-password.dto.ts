import { IsString, MinLength } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class ResetPasswordDto {
  @ApiProperty({
    example: '1a2b3c4d5e6f7g8h9i',
    description: 'Token de restablecimiento enviado al correo del usuario.',
  })
  @IsString()
  token!: string;

  @ApiProperty({
    example: 'nuevaContraseña2025!',
    description: 'Nueva contraseña del usuario. Debe tener al menos 8 caracteres.',
    minLength: 8,
  })
  @IsString()
  @MinLength(8)
  newPassword!: string;
}
