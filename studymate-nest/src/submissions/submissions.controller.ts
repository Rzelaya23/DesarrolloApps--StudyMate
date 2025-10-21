import { Controller, Get, Post, Patch, Param, Body, UseGuards, Req } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt.guard'; 
import { SubmissionsService } from './submissions.service';
import { GradeSubmissionDto } from './dto/grade-submission.dto';

@Controller(['api/v1/submissions', 'api/submissions'])
@UseGuards(JwtAuthGuard)
export class SubmissionsController {
  constructor(private readonly submissions: SubmissionsService) {}

  @Post()
  create(
    @Body() dto: { assignmentId: string; textBody: string; studentId?: string },
    @Req() req,
  ) {
    const studentId = dto.studentId ?? req.user.userId;
    return this.submissions.create(
      { assignmentId: dto.assignmentId, studentId, textBody: dto.textBody },
    );
  }

  @Get(':id')
  get(@Param('id') id: string, @Req() req) {
    return this.submissions.get(id, req.user.userId);
  }

  @Patch(':id/grade')
  grade(@Param('id') id: string, @Body() dto: GradeSubmissionDto /*, @Req() req*/) {
    return this.submissions.grade(id, dto);
  }
}
