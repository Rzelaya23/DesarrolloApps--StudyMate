import {
  BadRequestException,
  ConflictException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import * as bcrypt from 'bcryptjs';
import * as jwt from 'jsonwebtoken';
import * as crypto from 'crypto';

function addHours(date: Date, hours: number) {
  return new Date(date.getTime() + hours * 60 * 60 * 1000);
}

@Injectable()
export class AuthService {
  constructor(private prisma: PrismaService) {}

  private signAccess(payload: any) {
    const secret = process.env.JWT_ACCESS_SECRET || process.env.JWT_SECRET || 'dev_access';
    return jwt.sign(payload, secret, { expiresIn: '15m' });
  }

  private signRefresh(payload: any) {
    const secret = process.env.JWT_REFRESH_SECRET || 'dev_refresh';
    return jwt.sign(payload, secret, { expiresIn: '7d' });
  }

  private verifyRefresh(token: string): any {
    const secret = process.env.JWT_REFRESH_SECRET || 'dev_refresh';
    try {
      return jwt.verify(token, secret);
    } catch {
      throw new UnauthorizedException('Invalid refresh token');
    }
  }

  async register(dto: RegisterDto) {
    const exists = await this.prisma.student.findUnique({ where: { email: dto.email } });
    if (exists) throw new ConflictException('Email already registered');

    const passwordHash = bcrypt.hashSync(dto.password, 10);
    const s = await this.prisma.student.create({
      data: {
        name: dto.name,
        email: dto.email,
        passwordHash,
        timezone: 'America/El_Salvador',
      },
    });

    const payload = { sub: s.id, email: s.email, role: 'STUDENT' };
    const accessToken = this.signAccess(payload);
    const refreshToken = this.signRefresh(payload);

    const refreshHash = bcrypt.hashSync(refreshToken, 10);
    await this.prisma.student.update({
      where: { id: s.id },
      data: { refreshHash },
    });

    return {
      accessToken,
      refreshToken,
      user: { id: s.id, name: s.name, email: s.email, role: 'STUDENT' },
    };
  }

  async login(dto: LoginDto) {
    const s = await this.prisma.student.findUnique({ where: { email: dto.email } });
    if (!s || !bcrypt.compareSync(dto.password, s.passwordHash)) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const payload = { sub: s.id, email: s.email, role: 'STUDENT' };
    const accessToken = this.signAccess(payload);
    const refreshToken = this.signRefresh(payload);

    const refreshHash = bcrypt.hashSync(refreshToken, 10);
    await this.prisma.student.update({
      where: { id: s.id },
      data: { refreshHash },
    });

    return {
      accessToken,
      refreshToken,
      user: { id: s.id, name: s.name, email: s.email, role: 'STUDENT' },
    };
  }

  async refresh(refreshToken: string) {
    const decoded = this.verifyRefresh(refreshToken) as { sub: string; email: string };
    const student = await this.prisma.student.findUnique({ where: { id: decoded.sub } });
    if (!student?.refreshHash) throw new UnauthorizedException('No active session');

    const ok = bcrypt.compareSync(refreshToken, student.refreshHash);
    if (!ok) throw new UnauthorizedException('Invalid refresh token');

    const payload = { sub: student.id, email: student.email, role: 'STUDENT' };
    const accessToken = this.signAccess(payload);
    const newRefresh = this.signRefresh(payload);

    const newHash = bcrypt.hashSync(newRefresh, 10);
    await this.prisma.student.update({
      where: { id: student.id },
      data: { refreshHash: newHash },
    });

    return { accessToken, refreshToken: newRefresh };
  }

  async logout(userId: string) {
    await this.prisma.student.update({
      where: { id: userId },
      data: { refreshHash: null },
    });
    return { success: true };
  }

  async me(userJwtPayload: any) {
    const s = await this.prisma.student.findUnique({
      where: { id: userJwtPayload.sub },
      include: { preferences: true },
    });
    if (!s) throw new UnauthorizedException('User not found');
    const { passwordHash, refreshHash, ...safe } = s as any;
    return safe;
  }

  async forgotPassword(email: string) {
    const s = await this.prisma.student.findUnique({ where: { email } });
    if (!s) return { ok: true };

    const rawToken = crypto.randomBytes(24).toString('hex');
    const tokenHash = bcrypt.hashSync(rawToken, 10);
    const hours = Number(process.env.PASSWORD_RESET_HOURS || 2);
    const expiresAt = addHours(new Date(), hours);

    await this.prisma.passwordResetToken.create({
      data: {
        studentId: s.id,
        tokenHash,
        expiresAt,
      },
    });

    return { ok: true, token: rawToken };
  }

  async resetPassword(token: string, newPassword: string) {
    const last = await this.prisma.passwordResetToken.findFirst({
      where: { usedAt: null, expiresAt: { gt: new Date() } },
      orderBy: { createdAt: 'desc' },
    });
    if (!last) throw new BadRequestException('Invalid or expired token');

    const valid = bcrypt.compareSync(token, last.tokenHash);
    if (!valid) throw new BadRequestException('Invalid or expired token');

    const passwordHash = bcrypt.hashSync(newPassword, 10);

    await this.prisma.$transaction([
      this.prisma.student.update({
        where: { id: last.studentId },
        data: { passwordHash, refreshHash: null }, 
      }),
      this.prisma.passwordResetToken.update({
        where: { id: last.id },
        data: { usedAt: new Date() },
      }),
    ]);

    return { ok: true };
  }
}
