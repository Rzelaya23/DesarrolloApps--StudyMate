// src/submissions/submissions.module.ts
import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma.module';
import { SubmissionsController } from './submissions.controller';
import { SubmissionsService } from './submissions.service';

@Module({
  imports: [PrismaModule],
  controllers: [SubmissionsController],
  providers: [SubmissionsService],
})
export class SubmissionsModule {}
