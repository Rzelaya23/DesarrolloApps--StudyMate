import { Module } from '@nestjs/common';
import { EventsController } from './events.controller';
import { EventsService } from './events.service';
import { AuthModule } from '../auth/auth.module';
import { PrismaService } from '../prisma.service'; // usamos el mismo PrismaService del proyecto

@Module({
  imports: [AuthModule],                 // 👈 trae la estrategia/guard ya registrados
  controllers: [EventsController],
  providers: [EventsService, PrismaService], // 👈 inyecta Prisma sin depender de un PrismaModule
})
export class EventsModule {}
