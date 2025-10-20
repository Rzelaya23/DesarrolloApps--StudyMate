// src/assignments/assignments.service.ts
import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { CreateAssignmentDto } from './dto/create-assignment.dto';
import { SubmitDto } from './dto/submit.dto';

@Injectable()
export class AssignmentsService {
  constructor(private prisma: PrismaService) {}
  list(){ return this.prisma.assignment.findMany({ orderBy: { createdAt: 'desc' } }); }

  async create(dto: CreateAssignmentDto){
    return this.prisma.assignment.create({
      data: { courseId: dto.courseId, title: dto.title, description: dto.description, dueDate: dto.dueDate ? new Date(dto.dueDate) : null }
    });
  }

  async submit(id: string, dto: SubmitDto){
    const a = await this.prisma.assignment.findUnique({ where: { id } });
    if (!a) throw new NotFoundException('Assignment not found');
    return this.prisma.submission.create({ data: { assignmentId: id, studentId: dto.studentId, content: dto.content } });
  }

  submissions(id: string){
    return this.prisma.submission.findMany({ where: { assignmentId: id }, orderBy: { submittedAt: 'desc' } });
  }
}
