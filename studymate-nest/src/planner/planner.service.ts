import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { CreatePlannerActivityDto } from './dto/create-planner-activity.dto';
import { UpdatePlannerActivityDto } from './dto/update-planner-activity.dto';
import { GenerateScheduleDto } from './dto/generate-schedule.dto';
import { CommitScheduleDto } from './dto/commit-schedule.dto';

@Injectable()
export class PlannerService {
  constructor(private prisma: PrismaService) {}

  async listActivities(userId: string, dateISO: string) {
    const start = new Date(dateISO);
    const end = new Date(dateISO);
    end.setUTCHours(23, 59, 59, 999);
    return this.prisma.plannerActivity.findMany({
      where: { userId, date: { gte: start, lte: end } },
      orderBy: [{ priority: 'desc' }, { difficulty: 'desc' }, { createdAt: 'asc' }],
    });
  }

  async createActivity(userId: string, dto: CreatePlannerActivityDto) {
    return this.prisma.plannerActivity.create({
      data: {
        userId,
        date: new Date(dto.date),
        title: dto.title,
        durationMin: dto.durationMin,
        priority: dto.priority as any,
        difficulty: dto.difficulty as any,
      },
    });
  }

  async updateActivity(userId: string, id: string, dto: UpdatePlannerActivityDto) {
    const existing = await this.prisma.plannerActivity.findFirst({ where: { id, userId } });
    if (!existing) throw new NotFoundException();
    return this.prisma.plannerActivity.update({
      where: { id },
      data: {
        title: dto.title ?? existing.title,
        durationMin: dto.durationMin ?? existing.durationMin,
        priority: (dto.priority as any) ?? existing.priority,
        difficulty: (dto.difficulty as any) ?? existing.difficulty,
        date: dto.date ? new Date(dto.date) : existing.date,
      },
    });
  }

  private toMinutes(hhmm: string) {
    const [h, m] = hhmm.split(':').map(Number);
    return h * 60 + m;
  }

  private fromMinutes(mins: number) {
    const h = Math.floor(mins / 60);
    const m = mins % 60;
    const pad = (n: number) => (n < 10 ? `0${n}` : `${n}`);
    return `${pad(h)}:${pad(m)}`;
  }

  async deleteActivity(userId: string, id: string) {
    const existing = await this.prisma.plannerActivity.findFirst({ where: { id, userId } });
    if (!existing) throw new NotFoundException();
    await this.prisma.plannerActivity.delete({ where: { id } });
    return { ok: true };
  }

  async generate(userId: string, dto: GenerateScheduleDto) {
    const startMin = this.toMinutes(dto.start);
    const endMin = this.toMinutes(dto.end);
    const activities = [...dto.activities].sort((a, b) => {
      const pr: any = { ALTA: 3, MEDIA: 2, BAJA: 1 };
      const df: any = { DIFICIL: 3, INTERMEDIA: 2, FACIL: 1 };
      if (pr[b.priority] !== pr[a.priority]) return pr[b.priority] - pr[a.priority];
      if (df[b.difficulty] !== df[a.difficulty]) return df[b.difficulty] - df[a.difficulty];
      return 0;
    });

    let cursor = startMin;
    const blocks: { title: string; start: string; end: string }[] = [];
    for (const act of activities) {
      let remaining = act.durationMin;
      while (remaining > 0 && cursor < endMin) {
        const chunk = Math.min(dto.focusMin, remaining, endMin - cursor);
        if (chunk <= 0) break;
        const s = this.fromMinutes(cursor);
        const e = this.fromMinutes(cursor + chunk);
        blocks.push({ title: act.title, start: s, end: e });
        cursor += chunk;
        remaining -= chunk;
        if (remaining > 0 && cursor < endMin) {
          const rest = Math.min(dto.restMin, endMin - cursor);
          cursor += rest;
        } else if (remaining <= 0 && cursor < endMin) {
          const rest = Math.min(dto.restMin, endMin - cursor);
          if (rest > 0) cursor += rest;
        }
      }
    }

    const version = new Date().toISOString();
    const payload = { date: dto.date, blocks, conflicts: [], version };
    if (dto.persist) {
      await this.prisma.plannerCommit.create({
        data: { userId, date: new Date(dto.date), version, blocks: blocks as any },
      });
    }
    return payload;
  }

  async commit(userId: string, dto: CommitScheduleDto) {
    const saved = await this.prisma.plannerCommit.create({
      data: { userId, date: new Date(dto.date), version: dto.version, blocks: dto.blocks as any },
    });
    return { ok: true, id: saved.id };
  }
}
