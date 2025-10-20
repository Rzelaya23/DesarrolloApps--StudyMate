import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  BadRequestException,
} from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { Prisma } from '@prisma/client';
import { QueryEventsDto } from './dto/query-events.dto';
import { CreateEventDto } from './dto/create-event.dto';
import { UpdateEventDto } from './dto/update-event.dto';

@Injectable()
export class EventsService {
  constructor(private prisma: PrismaService) {}

  async list(dto: QueryEventsDto, studentId: string) {
    const where: Prisma.EventWhereInput = { studentId };
    if (dto.from || dto.to) {
      (where as any).startsAt = {};
      if (dto.from) (where as any).startsAt.gte = new Date(dto.from);
      if (dto.to)   (where as any).startsAt.lte = new Date(dto.to);
    }
    return this.prisma.event.findMany({
      where,
      orderBy: { startsAt: 'asc' },
    });
  }

  async create(dto: CreateEventDto, studentId: string) {
    const startStr = (dto as any).startsAt ?? (dto as any).startAt;
    const endStr   = (dto as any).endsAt   ?? (dto as any).endAt;

    const startsAt = new Date(startStr);
    const endsAt   = new Date(endStr);

    if (!startStr || !endStr || isNaN(startsAt.getTime()) || isNaN(endsAt.getTime())) {
      throw new BadRequestException('start[s]At y end[s]At deben ser fechas ISO válidas');
    }
    if (endsAt <= startsAt) {
      throw new BadRequestException('endsAt debe ser posterior a startsAt');
    }

    const data: Prisma.EventUncheckedCreateInput = {
      title: (dto as any).title,
      startsAt,
      endsAt,
      studentId,
      ...(typeof (dto as any).description === 'string' && { description: (dto as any).description }),
      ...(typeof (dto as any).location === 'string'    && { location: (dto as any).location }),
    };

    try {
      return await this.prisma.event.create({ data });
    } catch (e: any) {
      if (e?.code === 'P2003') {
        throw new BadRequestException('FK inválida (studentId). Verifica el alumno del token.');
      }
      if (e?.name === 'PrismaClientValidationError') {
        throw new BadRequestException('Datos inválidos para Event (campo desconocido o tipo no válido).');
      }
      throw e;
    }
  }

  async get(id: string, studentId: string) {
    const e = await this.prisma.event.findUnique({ where: { id } });
    if (!e) throw new NotFoundException('Event not found');
    if (e.studentId !== studentId) throw new ForbiddenException();
    return e;
  }

  async update(id: string, dto: UpdateEventDto, studentId: string) {
    const current = await this.get(id, studentId);

    const data: Prisma.EventUncheckedUpdateInput = {};
    if ((dto as any).title !== undefined)       data.title       = (dto as any).title;
    if ((dto as any).description !== undefined) data.description = (dto as any).description;
    if ((dto as any).location !== undefined)    data.location    = (dto as any).location;

    const startStr = (dto as any).startsAt ?? (dto as any).startAt;
    const endStr   = (dto as any).endsAt   ?? (dto as any).endAt;
    if (startStr) (data as any).startsAt = new Date(startStr);
    if (endStr)   (data as any).endsAt   = new Date(endStr);

    const s = ((data as any).startsAt ?? current.startsAt) as Date | undefined;
    const e = ((data as any).endsAt   ?? current.endsAt)   as Date | undefined;
    if (s && e && e <= s) {
      throw new BadRequestException('endsAt debe ser posterior a startsAt');
    }

    try {
      return await this.prisma.event.update({ where: { id }, data });
    } catch (err: any) {
      if (err?.name === 'PrismaClientValidationError') {
        throw new BadRequestException('Datos inválidos para Event (campo desconocido o tipo no válido).');
      }
      throw err;
    }
  }

  async delete(id: string, studentId: string) {
    await this.get(id, studentId);
    await this.prisma.event.delete({ where: { id } });
    return { success: true };
  }
}
