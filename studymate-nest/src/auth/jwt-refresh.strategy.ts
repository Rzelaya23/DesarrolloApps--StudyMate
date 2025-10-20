import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { Strategy } from 'passport-jwt';
import type { StrategyOptions, JwtFromRequestFunction } from 'passport-jwt';
import type { Request } from 'express';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../prisma.service';

interface RefreshJwtPayload {
  sub: string;
  email: string;
  role: 'ADMIN' | 'TEACHER' | 'STUDENT';
}

function refreshFromBody(req: Request | undefined): string | null {
  const token = (req?.body as any)?.refreshToken;
  return typeof token === 'string' && token.length > 0 ? token : null;
}

@Injectable()
export class JwtRefreshStrategy extends PassportStrategy(Strategy, 'jwt-refresh') {
  constructor(private prisma: PrismaService) {
    const jwtFromRequest: JwtFromRequestFunction = (req: Request) =>
      refreshFromBody(req);

    const opts: StrategyOptions = {
      jwtFromRequest,
      secretOrKey: process.env.JWT_REFRESH_SECRET ?? 'dev_refresh_secret',
      ignoreExpiration: false,
      passReqToCallback: true,
    };
    super(opts);
  }

  async validate(req: Request, payload: RefreshJwtPayload) {
    const refreshToken = (req.body as any)?.refreshToken;
    if (!refreshToken) throw new UnauthorizedException('Missing refresh token');

    const user = await this.prisma.student.findUnique({ where: { id: payload.sub } });
    if (!user?.refreshHash) throw new UnauthorizedException('No session');

    const ok = await bcrypt.compare(refreshToken, user.refreshHash);
    if (!ok) throw new UnauthorizedException('Invalid refresh token');

    // Shape consistente con la estrategia de access
    return {
      userId: payload.sub,
      email: payload.email,
      role: payload.role,
    };
  }
}
