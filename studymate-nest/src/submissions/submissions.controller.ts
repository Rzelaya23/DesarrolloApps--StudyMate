// src/submissions/submissions.controller.ts
import { Controller, Get, Param, Patch, Body, UseGuards, Req } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt.guard';
import { SubmissionsService } from './submissions.service';
import { GradeSubmissionDto } from './dto/grade-submission.dto';

@Controller('api/v1/submissions')
@UseGuards(JwtAuthGuard)
export class SubmissionsController {
  constructor(private readonly submissions: SubmissionsService) {}

  @Get(':id')
  get(@Param('id') id: string, @Req() req) {
    return this.submissions.get(id, req.user.userId);
  }

  @Patch(':id/grade')
  grade(@Param('id') id: string, @Body() dto: GradeSubmissionDto /*, @Req() req*/) {
    return this.submissions.grade(id, dto);
  }
}
