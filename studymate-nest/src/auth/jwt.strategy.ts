import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { Strategy } from 'passport-jwt';
import type { StrategyOptions, JwtFromRequestFunction } from 'passport-jwt';
import type { Request } from 'express';

export type UserRole = 'ADMIN' | 'TEACHER' | 'STUDENT';

export interface JwtPayload {
  sub: string;
  email: string;
  role: UserRole;
}

/** Extractor Bearer 100% tipado (evita ExtractJwt.*) */
function bearerFromAuthHeader(req: Request | undefined): string | null {
  const auth = req?.headers?.authorization;
  if (typeof auth !== 'string') return null;
  const [scheme, token] = auth.split(' ');
  if (!scheme || !token) return null;
  return /^Bearer$/i.test(scheme) ? token : null;
}

/** Type guards súper estrictos (sin any) */
function isString(x: unknown): x is string {
  return typeof x === 'string' && x.length > 0;
}
function isUserRole(x: unknown): x is UserRole {
  return x === 'ADMIN' || x === 'TEACHER' || x === 'STUDENT';
}
function isJwtPayload(p: unknown): p is JwtPayload {
  if (typeof p !== 'object' || p === null) return false;
  const obj = p as Record<string, unknown>; // unknown → Record<..., unknown> es seguro
  return isString(obj.sub) && isString(obj.email) && isUserRole(obj.role);
}

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor() {
    const jwtFromRequest: JwtFromRequestFunction = (req: Request) =>
      bearerFromAuthHeader(req);

    const opts: StrategyOptions = {
      jwtFromRequest,
      secretOrKey: process.env.JWT_SECRET ?? 'dev_secret',
      ignoreExpiration: false,
    };

    super(opts);
  }

  // Sin async (no dispara require-await)
  validate(payload: unknown): JwtPayload {
    if (isJwtPayload(payload)) {
      // Retorno tipado tras pasar el guard (no hay "unsafe assignment/return")
      return payload;
    }
    throw new UnauthorizedException('Invalid JWT payload');
  }
}
