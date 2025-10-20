import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma.service'; // ← ajusta si tu path difiere
import * as bcrypt from 'bcrypt';
import { CreateStudentDto } from './dto/create-student.dto';
import { UpdateStudentDto } from './dto/update-student.dto';
import { UpdatePreferencesDto } from './dto/update-preferences.dto';

@Injectable()
export class StudentsService {
  constructor(private prisma: PrismaService) {}

  // LIST
  async list() {
    const students = await this.prisma.student.findMany({
      include: { preferences: true },
      orderBy: { createdAt: 'desc' },
    });
    // sanea hashes
    return students.map(({ passwordHash, refreshHash, ...safe }: any) => safe);
  }

  // CREATE
  async create(dto: CreateStudentDto) {
    let passwordHash: string | undefined;
    if (dto.password) {
      passwordHash = await bcrypt.hash(dto.password, 10);
    }
    const student = await this.prisma.student.create({
      data: {
        name: dto.name,
        email: dto.email,
        passwordHash: passwordHash ?? (await bcrypt.hash(cryptoRandom(), 10)), // password temporal si no envían
        avatarUrl: dto.avatarUrl,
        timezone: dto.timezone ?? 'America/El_Salvador',
        preferences: { create: {} }, // crea prefs por defecto
      },
      include: { preferences: true },
    });
    const { passwordHash: _ph, refreshHash, ...safe } = student as any;
    return safe;
  }

  // GET
  async get(id: string) {
    const student = await this.prisma.student.findUnique({
      where: { id },
      include: { preferences: true },
    });
    if (!student) throw new NotFoundException();
    const { passwordHash, refreshHash, ...safe } = student as any;
    return safe;
  }

  // UPDATE
  async update(id: string, dto: UpdateStudentDto) {
    const student = await this.prisma.student.update({
      where: { id },
      data: dto,
      include: { preferences: true },
    });
    const { passwordHash, refreshHash, ...safe } = student as any;
    return safe;
  }

  // DELETE
  async remove(id: string) {
    await this.prisma.student.delete({ where: { id } });
    return { success: true };
  }

  // PREFERENCES GET
  async getPreferences(id: string) {
    let prefs = await this.prisma.studentPreferences.findUnique({ where: { studentId: id } });
    if (!prefs) {
      prefs = await this.prisma.studentPreferences.create({ data: { studentId: id } });
    }
    return prefs;
  }

  // PREFERENCES UPDATE
  async updatePreferences(id: string, dto: UpdatePreferencesDto) {
    const prefs = await this.prisma.studentPreferences.upsert({
      where: { studentId: id },
      update: dto,
      create: { studentId: id, ...dto },
    });
    return prefs;
  }
}

// util para password temporal si no lo envían
function cryptoRandom() {
  // evita importar crypto si no quieres; suficiente para temp.
  return Math.random().toString(36).slice(2) + Date.now().toString(36);
}
