import { PartialType } from '@nestjs/mapped-types';
import { CreateSubmissionDto } from './create-submission.dto';
import { ApiPropertyOptional } from '@nestjs/swagger';

export class UpdateSubmissionDto extends PartialType(CreateSubmissionDto) {
  @ApiPropertyOptional({
    example: 'Este es el texto actualizado de la entrega tras la corrección solicitada.',
    description: 'Contenido textual actualizado de la entrega (opcional).',
  })
  textBody?: string;

  @ApiPropertyOptional({
    example: 'assign-12345',
    description: 'Identificador de la asignación asociado a la entrega (opcional).',
  })
  assignmentId?: string;

  @ApiPropertyOptional({
    example: 'student-98765',
    description:
      'Identificador del estudiante. Puede omitirse si se gestiona automáticamente desde el token (opcional).',
  })
  studentId?: string;
}
