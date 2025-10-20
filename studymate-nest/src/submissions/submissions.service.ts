// src/submissions/submissions.service.ts
import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { GradeSubmissionDto } from './dto/grade-submission.dto';

interface CreateSubmissionInput {
  assignmentId: string;
  studentId: string;
  textBody: string; // viene del controller; lo mapeamos al campo real del schema
}

@Injectable()
export class SubmissionsService {
  constructor(private prisma: PrismaService) {}

  // CREATE
  async create(input: CreateSubmissionInput) {
    // validar que exista la tarea
    const assignment = await this.prisma.assignment.findUnique({
      where: { id: input.assignmentId },
      select: { id: true },
    });
    if (!assignment) throw new NotFoundException('Assignment not found');

    // ⚠️ Mapea 'textBody' al nombre REAL del campo de tu schema:
    // Reemplaza 'content' por 'body' si ese es tu nombre de columna.
    return this.prisma.submission.create({
      data: {
        assignmentId: input.assignmentId,
        studentId: input.studentId,
        content: input.textBody, // <-- 👈 CAMBIA a 'body' si tu modelo lo usa así
      },
    });
  }

  // GET /submissions/:id
  async get(id: string, _requesterId: string) {
    const s = await this.prisma.submission.findUnique({
      where: { id },
      include: { assignment: true },
    });
    if (!s) throw new NotFoundException('Submission not found');
    return s;
  }

  // Listar por tarea
  async listByTask(taskId: string) {
    // ⚠️ Si tu modelo NO tiene 'submittedAt', quita el orderBy o usa 'updatedAt'
    return this.prisma.submission.findMany({
      where: { assignmentId: taskId },
      orderBy: { submittedAt: 'desc' }, // <-- 👈 CAMBIA a 'updatedAt' si no tienes 'submittedAt'
    });
  }

  // Calificar
  async grade(id: string, dto: GradeSubmissionDto /*, teacherId?: string*/) {
    await this.ensureExists(id);
    return this.prisma.submission.update({
      where: { id },
      data: { grade: dto.grade, feedback: dto.feedback },
    });
  }

  private async ensureExists(id: string) {
    const exists = await this.prisma.submission.findUnique({ where: { id }, select: { id: true } });
    if (!exists) throw new NotFoundException('Submission not found');
  }
}
