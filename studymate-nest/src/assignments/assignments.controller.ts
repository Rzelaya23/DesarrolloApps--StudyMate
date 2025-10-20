// src/assignments/assignments.controller.ts
import { Body, Controller, Get, Param, Post, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt.guard';
import { AssignmentsService } from './assignments.service';
import { CreateAssignmentDto } from './dto/create-assignment.dto';
import { SubmitDto } from './dto/submit.dto';

@UseGuards(JwtAuthGuard)
@Controller('api/assignments')
export class AssignmentsController {
  constructor(private readonly service: AssignmentsService) {}
  @Get() list(){ return this.service.list(); }
  @Post() create(@Body() dto: CreateAssignmentDto){ return this.service.create(dto); }
  @Post(':id/submit') submit(@Param('id') id: string, @Body() dto: SubmitDto){ return this.service.submit(id, dto); }
  @Get(':id/submissions') submissions(@Param('id') id: string){ return this.service.submissions(id); }
}
