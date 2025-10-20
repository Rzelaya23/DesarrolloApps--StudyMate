// src/students/students.controller.ts
import { Body, Controller, Delete, Get, Param, Post, Put, UseGuards } from '@nestjs/common';
import { StudentsService } from './students.service';
import { JwtAuthGuard } from '../auth/jwt.guard';
import { CreateStudentDto } from './dto/create-student.dto';
import { UpdateStudentDto } from './dto/update-student.dto';

@UseGuards(JwtAuthGuard)
@Controller('api/students')
export class StudentsController {
  constructor(private readonly service: StudentsService) {}
  @Get() list(){ return this.service.list(); }
  @Post() create(@Body() dto: CreateStudentDto){ return this.service.create(dto); }
  @Get(':id') get(@Param('id') id: string){ return this.service.get(id); }
  @Put(':id') update(@Param('id') id: string, @Body() dto: UpdateStudentDto){ return this.service.update(id, dto); }
  @Delete(':id') remove(@Param('id') id: string){ return this.service.remove(id); }
}
