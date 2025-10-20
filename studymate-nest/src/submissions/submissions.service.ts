// src/submissions/submissions.service.ts
import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { GradeSubmissionDto } from './dto/grade-submission.dto';

@Injectable()
export class SubmissionsService {
  constructor(private prisma: PrismaService) {}

  async get(id: string, requesterId: string) {
    const s = await this.prisma.submission.findUnique({ where: { id }, include: { assignment: true } });
    if (!s) throw new NotFoundException();
    // (opcional) validar permisos: dueño del assignment o el propio estudiante
    return s;
  }

  async grade(id: string, dto: GradeSubmissionDto /*, teacherId?: string*/) {
    // (opcional) validar que el requester sea docente
    return this.prisma.submission.update({
      where: { id },
      data: { grade: dto.grade, feedback: dto.feedback },
    });
  }
}
