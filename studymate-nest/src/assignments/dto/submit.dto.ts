import { IsString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class SubmitDto {
  @ApiProperty({
    example: 'stu-456',
    description: 'Identificador único del estudiante que realiza la entrega.',
  })
  @IsString()
  studentId: string;

  @ApiProperty({
    example: 'Este es el contenido de mi ensayo final sobre Derecho Internacional.',
    description: 'Contenido completo de la entrega del estudiante (puede ser texto, URL o referencia).',
  })
  @IsString()
  content: string;
}
