import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { Prisma } from '@prisma/client';
import { CreateCourseDto } from './dto/create-course.dto';
import { UpdateCourseDto } from './dto/update-course.dto';

@Injectable()
export class CoursesService {
  constructor(private prisma: PrismaService) {}

  async list(params: { search?: string; page: number; limit: number }) {
    const { search, page, limit } = params;
    const where: Prisma.CourseWhereInput = search
      ? {
          OR: [
            { title: { contains: search, mode: Prisma.QueryMode.insensitive } },
            { code:  { contains: search, mode: Prisma.QueryMode.insensitive } },
          ],
        }
      : {};
    const skip = (page - 1) * limit;
    const [items, total] = await this.prisma.$transaction([
      this.prisma.course.findMany({ where, skip, take: limit, orderBy: { createdAt: 'desc' } }),
      this.prisma.course.count({ where }),
    ]);
    return { items, total, page, limit };
  }

  async create(dto: CreateCourseDto) {
    try {
      return await this.prisma.course.create({
        data: {
          title: dto.title,
          code: dto.code,                    // ← obligatorio
          ...(dto.description ? { description: dto.description } : {}),
        },
      });
    } catch (e: any) {
      if (e.code === 'P2002') {
        throw new ConflictException('Course code already in use');
      }
      throw e;
    }
  }

  async get(id: string) {
    const course = await this.prisma.course.findUnique({ where: { id } });
    if (!course) throw new NotFoundException('Course not found');
    return course;
  }

  async update(id: string, dto: UpdateCourseDto) {
    await this.get(id);
    try {
      return await this.prisma.course.update({ where: { id }, data: dto });
    } catch (e: any) {
      if (e.code === 'P2002') {
        throw new ConflictException('Course code already in use');
      }
      throw e;
    }
  }

  async delete(id: string) {
    await this.get(id);
    await this.prisma.course.delete({ where: { id } });
    return { success: true };
  }
}
