import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { GradeSubmissionDto } from './dto/grade-submission.dto';

interface CreateSubmissionInput {
  assignmentId: string;
  studentId: string;
  textBody: string; 
}

@Injectable()
export class SubmissionsService {
  constructor(private prisma: PrismaService) {}

  async create(input: CreateSubmissionInput) {
    const assignment = await this.prisma.assignment.findUnique({
      where: { id: input.assignmentId },
      select: { id: true },
    });
    if (!assignment) throw new NotFoundException('Assignment not found');

    return this.prisma.submission.create({
      data: {
        assignmentId: input.assignmentId,
        studentId: input.studentId,
        content: input.textBody, 
      },
    });
  }

  async get(id: string, _requesterId: string) {
    const s = await this.prisma.submission.findUnique({
      where: { id },
      include: { assignment: true },
    });
    if (!s) throw new NotFoundException('Submission not found');
    return s;
  }

  async listByTask(taskId: string) {
    return this.prisma.submission.findMany({
      where: { assignmentId: taskId },
      orderBy: { submittedAt: 'desc' },
    });
  }

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
