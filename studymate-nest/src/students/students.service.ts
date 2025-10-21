import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma.service'; 
import * as bcrypt from 'bcrypt';
import { CreateStudentDto } from './dto/create-student.dto';
import { UpdateStudentDto } from './dto/update-student.dto';
import { UpdatePreferencesDto } from './dto/update-preferences.dto';

@Injectable()
export class StudentsService {
  constructor(private prisma: PrismaService) {}

  async list() {
    const students = await this.prisma.student.findMany({
      include: { preferences: true },
      orderBy: { createdAt: 'desc' },
    });
    return students.map(({ passwordHash, refreshHash, ...safe }: any) => safe);
  }

  async create(dto: CreateStudentDto) {
    let passwordHash: string | undefined;
    if (dto.password) {
      passwordHash = await bcrypt.hash(dto.password, 10);
    }
    const student = await this.prisma.student.create({
      data: {
        name: dto.name,
        email: dto.email,
        passwordHash: passwordHash ?? (await bcrypt.hash(cryptoRandom(), 10)), 
        avatarUrl: dto.avatarUrl,
        timezone: dto.timezone ?? 'America/El_Salvador',
        preferences: { create: {} }, 
      },
      include: { preferences: true },
    });
    const { passwordHash: _ph, refreshHash, ...safe } = student as any;
    return safe;
  }

  async get(id: string) {
    const student = await this.prisma.student.findUnique({
      where: { id },
      include: { preferences: true },
    });
    if (!student) throw new NotFoundException();
    const { passwordHash, refreshHash, ...safe } = student as any;
    return safe;
  }

  async update(id: string, dto: UpdateStudentDto) {
    const student = await this.prisma.student.update({
      where: { id },
      data: dto,
      include: { preferences: true },
    });
    const { passwordHash, refreshHash, ...safe } = student as any;
    return safe;
  }

  async remove(id: string) {
    await this.prisma.student.delete({ where: { id } });
    return { success: true };
  }

  async getPreferences(id: string) {
    let prefs = await this.prisma.studentPreferences.findUnique({ where: { studentId: id } });
    if (!prefs) {
      prefs = await this.prisma.studentPreferences.create({ data: { studentId: id } });
    }
    return prefs;
  }

  async updatePreferences(id: string, dto: UpdatePreferencesDto) {
    const prefs = await this.prisma.studentPreferences.upsert({
      where: { studentId: id },
      update: dto,
      create: { studentId: id, ...dto },
    });
    return prefs;
  }
}

function cryptoRandom() {
  return Math.random().toString(36).slice(2) + Date.now().toString(36);
}
