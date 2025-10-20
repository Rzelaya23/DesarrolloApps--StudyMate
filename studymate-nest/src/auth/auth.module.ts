// src/auth/auth.module.ts
import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';

import { AuthService } from './auth.service';
import { AuthController } from './auth.controller';

// Ajusta estas rutas según tu árbol real
// Si tus estrategias están en src/auth/strategies/...
import { JwtStrategy } from './jwt.strategy';
import { JwtRefreshStrategy } from './jwt-refresh.strategy';

// Si NO usas path aliases, usa ruta relativa:
import { PrismaModule } from '../prisma.module';
// Si tienes alias (tsconfig paths): import { PrismaModule } from 'src/prisma/prisma.module';

@Module({
  imports: [
    PrismaModule,
    // No pongas secretos aquí; se leen desde process.env en las estrategias/servicio
    JwtModule.register({}),
  ],
  controllers: [AuthController],
  providers: [
    AuthService,
    JwtStrategy,
    JwtRefreshStrategy, // necesario para /auth/refresh
  ],
  exports: [
    AuthService,
    // Exporta JwtModule solo si otros módulos necesitan inyectar JwtService directamente
    // JwtModule,
  ],
})
export class AuthModule {}
