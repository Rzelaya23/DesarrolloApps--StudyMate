// src/submissions/submissions.controller.ts
import { Controller, Get, Post, Patch, Param, Body, UseGuards, Req } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt.guard'; // 👈 ruta consistente
import { SubmissionsService } from './submissions.service';
import { GradeSubmissionDto } from './dto/grade-submission.dto';

// Acepta ambos prefijos para evitar 404 por confusión de rutas
@Controller(['api/v1/submissions', 'api/submissions'])
@UseGuards(JwtAuthGuard)
export class SubmissionsController {
  constructor(private readonly submissions: SubmissionsService) {}

  // POST /api(/v1)/submissions  -> crear entrega
  @Post()
  create(
    @Body() dto: { assignmentId: string; textBody: string; studentId?: string },
    @Req() req,
  ) {
    // usa el alumno autenticado si no viene en el body
    const studentId = dto.studentId ?? req.user.userId;
    return this.submissions.create(
      { assignmentId: dto.assignmentId, studentId, textBody: dto.textBody },
    );
  }

  // GET /api(/v1)/submissions/:id  -> ver una entrega
  @Get(':id')
  get(@Param('id') id: string, @Req() req) {
    return this.submissions.get(id, req.user.userId);
  }

  // PATCH /api(/v1)/submissions/:id/grade  -> calificar
  @Patch(':id/grade')
  grade(@Param('id') id: string, @Body() dto: GradeSubmissionDto /*, @Req() req*/) {
    return this.submissions.grade(id, dto);
  }
}
