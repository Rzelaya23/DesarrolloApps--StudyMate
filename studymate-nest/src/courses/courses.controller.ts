// src/courses/courses.controller.ts
import { Body, Controller, Delete, Get, Param, Post, Put, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt.guard';
import { CoursesService } from './courses.service';
import { CreateCourseDto } from './dto/create-course.dto';
import { UpdateCourseDto } from './dto/update-course.dto';

@UseGuards(JwtAuthGuard)
@Controller('api/courses')
export class CoursesController {
  constructor(private readonly service: CoursesService) {}
  @Get() list(){ return this.service.list(); }
  @Post() create(@Body() dto: CreateCourseDto){ return this.service.create(dto); }
  @Put(':id') update(@Param('id') id: string, @Body() dto: UpdateCourseDto){ return this.service.update(id, dto); }
  @Delete(':id') remove(@Param('id') id: string){ return this.service.remove(id); }
}
