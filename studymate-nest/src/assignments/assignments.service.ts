import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { Prisma } from '@prisma/client';
import { CreateAssignmentDto } from './dto/create-assignment.dto';
import { SubmitDto } from './dto/submit.dto';
import { QueryAssignmentsDto } from './dto/query-assignments.dto';
import { UpdateAssignmentDto } from './dto/update-assignment.dto';

@Injectable()
export class AssignmentsService {
  constructor(private prisma: PrismaService) {}

  async list(query: QueryAssignmentsDto) {
    const where: Prisma.AssignmentWhereInput = {};

    if (query.status) where.status = query.status;
    if (query.courseId) where.courseId = query.courseId;
    if (query.priority) where.priority = query.priority;

    if (query.due_from || query.due_to) {
      where.dueDate = {};
      if (query.due_from) (where.dueDate as any).gte = new Date(query.due_from);
      if (query.due_to) (where.dueDate as any).lte = new Date(query.due_to);
    }

    const page = query.page ?? 1;
    const limit = query.limit ?? 10;
    const skip = (page - 1) * limit;

    const orderBy: Prisma.AssignmentOrderByWithRelationInput = {
      dueDate: 'asc',
    };

    const [items, total] = await this.prisma.$transaction([
      this.prisma.assignment.findMany({
        where,
        skip,
        take: limit,
        orderBy,
      }),
      this.prisma.assignment.count({ where }),
    ]);

    return {
      items,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  async findOne(id: string) {
    const a = await this.prisma.assignment.findUnique({
      where: { id },
      include: {
        course: true,       
        submissions: true,  
      },
    });
    if (!a) throw new NotFoundException('Assignment not found');
    return a;
  }

  async create(dto: CreateAssignmentDto) {
    return this.prisma.assignment.create({
      data: {
        courseId: dto.courseId,
        title: dto.title,
        description: dto.description,
        dueDate: dto.dueDate ? new Date(dto.dueDate) : null,
        status: (dto as any).status ?? 'pending',
        priority: (dto as any).priority ?? null,
      },
    });
  }

  async update(id: string, dto: UpdateAssignmentDto) {
    const data: Prisma.AssignmentUpdateInput = { ...dto } as any;
    if ((dto as any).dueDate) {
      (data as any).dueDate = new Date((dto as any).dueDate);
    }

    try {
      return await this.prisma.assignment.update({
        where: { id },
        data,
      });
    } catch {
      throw new NotFoundException('Assignment not found');
    }
  }

  async remove(id: string) {
    try {
      return await this.prisma.assignment.delete({ where: { id } });
    } catch {
      throw new NotFoundException('Assignment not found');
    }
  }

  async submit(id: string, dto: SubmitDto) {
    const a = await this.prisma.assignment.findUnique({ where: { id } });
    if (!a) throw new NotFoundException('Assignment not found');

    return this.prisma.submission.create({
      data: { assignmentId: id, studentId: dto.studentId, content: dto.content },
    });
  }

  submissions(id: string) {
    return this.prisma.submission.findMany({
      where: { assignmentId: id },
      orderBy: { submittedAt: 'desc' },
    });
  }

  async bulkComplete(ids: string[]) {
    await this.prisma.assignment.updateMany({
      where: { id: { in: ids } },
      data: { status: 'done' },
    });
    return { success: true, updated: ids.length };
  }

  async bulkDelete(ids: string[]) {
    await this.prisma.assignment.deleteMany({ where: { id: { in: ids } } });
    return { success: true, deleted: ids.length };
  }
}
