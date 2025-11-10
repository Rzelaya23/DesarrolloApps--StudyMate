import { Body, Controller, Delete, Get, Param, Post, Put, Query, Req, UseGuards } from '@nestjs/common';
import { PlannerService } from './planner.service';
import { JwtAuthGuard } from 'src/auth/jwt.guard';
import { CreatePlannerActivityDto } from './dto/create-planner-activity.dto';
import { UpdatePlannerActivityDto } from './dto/update-planner-activity.dto';
import { GenerateScheduleDto } from './dto/generate-schedule.dto';
import { CommitScheduleDto } from './dto/commit-schedule.dto';

@UseGuards(JwtAuthGuard)
@Controller('planner')
export class PlannerController {
  constructor(private readonly service: PlannerService) {}

  private userId(req: any) {
    return req.user?.id || req.user?.sub || req.user?.userId || req.user?.uid;
  }

  @Get('activities')
  async list(@Req() req: any, @Query('date') date: string) {
    return this.service.listActivities(this.userId(req), date);
  }

  @Post('activities')
  async create(@Req() req: any, @Body() dto: CreatePlannerActivityDto) {
    return this.service.createActivity(this.userId(req), dto);
  }

  @Put('activities/:id')
  async update(@Req() req: any, @Param('id') id: string, @Body() dto: UpdatePlannerActivityDto) {
    return this.service.updateActivity(this.userId(req), id, dto);
  }

  @Delete('activities/:id')
  async del(@Req() req: any, @Param('id') id: string) {
    return this.service.deleteActivity(this.userId(req), id);
  }

  @Post('generate')
  async generate(@Req() req: any, @Body() dto: GenerateScheduleDto) {
    return this.service.generate(this.userId(req), dto);
  }

  @Post('commit')
  async commit(@Req() req: any, @Body() dto: CommitScheduleDto) {
    return this.service.commit(this.userId(req), dto);
  }
}
