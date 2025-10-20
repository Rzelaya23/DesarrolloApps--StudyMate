// src/students/students.service.ts
import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { CreateStudentDto } from './dto/create-student.dto';
import { UpdateStudentDto } from './dto/update-student.dto';

@Injectable()
export class StudentsService {
  constructor(private prisma: PrismaService) {}
  list() { return this.prisma.student.findMany({ orderBy: { createdAt: 'desc' } }); }
  create(dto: CreateStudentDto) { return this.prisma.student.create({ data: dto }); }
  async get(id: string) { const s = await this.prisma.student.findUnique({ where: { id } }); if (!s) throw new NotFoundException('Student not found'); return s; }
  async update(id: string, dto: UpdateStudentDto){ try { return await this.prisma.student.update({ where:{ id }, data: dto }); } catch { throw new NotFoundException('Student not found'); } }
  async remove(id: string){ try { return await this.prisma.student.delete({ where:{ id } }); } catch { throw new NotFoundException('Student not found'); } }
}
