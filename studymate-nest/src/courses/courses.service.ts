// src/courses/courses.service.ts
import { ConflictException, Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { CreateCourseDto } from './dto/create-course.dto';
import { UpdateCourseDto } from './dto/update-course.dto';

@Injectable()
export class CoursesService {
  constructor(private prisma: PrismaService) {}
  list(){ return this.prisma.course.findMany({ orderBy: { createdAt: 'desc' } }); }
  async create(dto: CreateCourseDto){ try { return await this.prisma.course.create({ data: dto }); } catch { throw new ConflictException('Course code already exists'); } }
  async update(id: string, dto: UpdateCourseDto){ try { return await this.prisma.course.update({ where:{ id }, data: dto }); } catch { throw new NotFoundException('Course not found'); } }
  async remove(id: string){ try { return await this.prisma.course.delete({ where:{ id } }); } catch { throw new NotFoundException('Course not found'); } }
}
