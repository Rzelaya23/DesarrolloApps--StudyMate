// src/assignments/assignments.controller.ts
import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt.guard';
import { AssignmentsService } from './assignments.service';
import { CreateAssignmentDto } from './dto/create-assignment.dto';
import { SubmitDto } from './dto/submit.dto';
import { QueryAssignmentsDto } from './dto/query-assignments.dto';
import { UpdateAssignmentDto } from './dto/update-assignment.dto';
import { IsArray, ArrayNotEmpty, IsString } from 'class-validator';

// DTO para operaciones masivas (opcional)
export class BulkIdsDto {
  @IsArray()
  @ArrayNotEmpty()
  @IsString({ each: true })
  ids!: string[];
}

@UseGuards(JwtAuthGuard)
@Controller('api/assignments')
export class AssignmentsController {
  constructor(private readonly service: AssignmentsService) {}

  // GET /api/assignments?status=&due_from=&due_to=&courseId=&priority=&page=&limit=
  @Get()
  list(@Query() query: QueryAssignmentsDto) {
    return this.service.list(query);
  }

  // GET /api/assignments/:id
  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.service.findOne(id);
  }

  // POST /api/assignments
  @Post()
  create(@Body() dto: CreateAssignmentDto) {
    return this.service.create(dto);
  }

  // PATCH /api/assignments/:id
  @Patch(':id')
  update(@Param('id') id: string, @Body() dto: UpdateAssignmentDto) {
    return this.service.update(id, dto);
  }

  // DELETE /api/assignments/:id
  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.service.remove(id);
  }

  // POST /api/assignments/:id/submit
  @Post(':id/submit')
  submit(@Param('id') id: string, @Body() dto: SubmitDto) {
    return this.service.submit(id, dto);
  }

  // GET /api/assignments/:id/submissions
  @Get(':id/submissions')
  submissions(@Param('id') id: string) {
    return this.service.submissions(id);
  }

  // ===== Opcionales: operaciones masivas =====

  // POST /api/assignments/bulk/complete
  @Post('bulk/complete')
  bulkComplete(@Body() dto: BulkIdsDto) {
    return this.service.bulkComplete(dto.ids);
  }

  // POST /api/assignments/bulk/delete
  @Post('bulk/delete')
  bulkDelete(@Body() dto: BulkIdsDto) {
    return this.service.bulkDelete(dto.ids);
  }
}
