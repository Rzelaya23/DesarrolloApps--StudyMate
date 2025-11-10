import { Module } from '@nestjs/common';
import { PlannerService } from './planner.service';
import { PlannerController } from './planner.controller';
import { PrismaService } from '../prisma.service';

@Module({
  controllers: [PlannerController],
  providers: [PlannerService, PrismaService],
})
export class PlannerModule {}
