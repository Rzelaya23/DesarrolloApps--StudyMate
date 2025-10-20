// src/assignments/assignments.module.ts
import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma.module';
import { AssignmentsController } from './assignments.controller';
import { AssignmentsService } from './assignments.service';

@Module({
  imports: [PrismaModule],
  controllers: [AssignmentsController],
  providers: [AssignmentsService],
})
export class AssignmentsModule {}
