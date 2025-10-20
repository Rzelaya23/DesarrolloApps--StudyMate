import { Controller, Get, Post, Put, Patch, Delete, Param, Body, UseGuards } from '@nestjs/common';
import { StudentsService } from './students.service';
import { JwtAuthGuard } from '../auth/jwt.guard';
import { CreateStudentDto } from './dto/create-student.dto';
import { UpdateStudentDto } from './dto/update-student.dto';
import { UpdatePreferencesDto } from './dto/update-preferences.dto';

@Controller('api/v1/students')
@UseGuards(JwtAuthGuard)
export class StudentsController {
  constructor(private readonly service: StudentsService) {}

  // GET /students
  @Get()
  list() {
    return this.service.list();
  }

  // POST /students
  @Post()
  create(@Body() dto: CreateStudentDto) {
    return this.service.create(dto);
  }

  // GET /students/:id
  @Get(':id')
  get(@Param('id') id: string) {
    return this.service.get(id);
  }

  // PUT /students/:id
  @Put(':id')
  update(@Param('id') id: string, @Body() dto: UpdateStudentDto) {
    return this.service.update(id, dto);
  }

  // DELETE /students/:id
  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.service.remove(id);
  }

  // GET /students/:id/preferences
  @Get(':id/preferences')
  getPrefs(@Param('id') id: string) {
    return this.service.getPreferences(id);
  }

  // PATCH /students/:id/preferences
  @Patch(':id/preferences')
  updatePrefs(@Param('id') id: string, @Body() dto: UpdatePreferencesDto) {
    return this.service.updatePreferences(id, dto);
  }
}
