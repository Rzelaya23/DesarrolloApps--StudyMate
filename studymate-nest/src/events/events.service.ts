// src/events/events.service.ts
import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { QueryEventsDto } from './dto/query-events.dto';
import { CreateEventDto } from './dto/create-event.dto';
import { UpdateEventDto } from './dto/update-event.dto';

@Injectable()
export class EventsService {
  constructor(private prisma: PrismaService) {}

  async list(dto: QueryEventsDto, studentId: string) {
    const where: any = { studentId };
    if (dto.from || dto.to) {
      where.startsAt = {};
      if (dto.from) where.startsAt.gte = new Date(dto.from);
      if (dto.to) where.startsAt.lte = new Date(dto.to);
    }
    return this.prisma.event.findMany({ where, orderBy: { startsAt: 'asc' } });
  }

  async create(dto: CreateEventDto, studentId: string) {
    return this.prisma.event.create({
      data: { ...dto, startsAt: new Date(dto.startsAt), endsAt: new Date(dto.endsAt), studentId },
    });
  }

  async get(id: string, studentId: string) {
    const e = await this.prisma.event.findUnique({ where: { id } });
    if (!e) throw new NotFoundException();
    if (e.studentId !== studentId) throw new ForbiddenException();
    return e;
  }

  async update(id: string, dto: UpdateEventDto, studentId: string) {
    await this.get(id, studentId);
    const data: any = { ...dto };
    if (dto.startsAt) data.startsAt = new Date(dto.startsAt);
    if (dto.endsAt) data.endsAt = new Date(dto.endsAt);
    return this.prisma.event.update({ where: { id }, data });
  }

  async delete(id: string, studentId: string) {
    await this.get(id, studentId);
    await this.prisma.event.delete({ where: { id } });
    return { success: true };
  }
}
