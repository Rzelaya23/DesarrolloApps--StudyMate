import { ConflictException, Injectable, UnauthorizedException } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import * as bcrypt from 'bcryptjs';
import * as jwt from 'jsonwebtoken';

@Injectable()
export class AuthService {
  constructor(private prisma: PrismaService) {}

  async register(dto: RegisterDto) {
    const exists = await this.prisma.user.findUnique({ where: { email: dto.email } });
    if (exists) throw new ConflictException('Email already registered');
    const passwordHash = bcrypt.hashSync(dto.password, 10);
    const u = await this.prisma.user.create({ data: { name: dto.name, email: dto.email, passwordHash, role: 'STUDENT' } });
    return { id: u.id, name: u.name, email: u.email, role: u.role };
  }

  async login(dto: LoginDto) {
    const u = await this.prisma.user.findUnique({ where: { email: dto.email } });
    if (!u || !bcrypt.compareSync(dto.password, u.passwordHash)) throw new UnauthorizedException('Invalid credentials');
    const token = jwt.sign({ sub: u.id, email: u.email, role: u.role }, process.env.JWT_SECRET || 'dev', { expiresIn: '2h' });
    return { token, user: { id: u.id, name: u.name, email: u.email, role: u.role } };
  }

  async me(user: any) {
    const u = await this.prisma.user.findUnique({ where: { id: user.sub } });
    if (!u) throw new UnauthorizedException('User not found');
    return { id: u.id, name: u.name, email: u.email, role: u.role };
  }
}
