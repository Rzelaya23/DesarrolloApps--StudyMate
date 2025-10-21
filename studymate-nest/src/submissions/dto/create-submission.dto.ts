import { IsString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateSubmissionDto {
  @ApiProperty({
    example: 'assign-12345',
    description: 'Identificador único de la asignación a la cual corresponde la entrega.',
  })
  @IsString()
  assignmentId!: string;

  @ApiProperty({
    example: 'Este es el ensayo final con el análisis del caso práctico.',
    description: 'Contenido textual principal de la entrega del estudiante.',
  })
  @IsString()
  textBody!: string;

  @ApiProperty({
    example: 'student-98765',
    description:
      'Identificador del estudiante que realiza la entrega. Puede omitirse si se obtiene desde el token.',
  })
  @IsString()
  studentId!: string; // Si se obtiene del JWT, puedes eliminarlo del DTO y asignarlo en el controlador.
}
