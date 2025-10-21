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

  @Get()
  list(@Query() query: QueryAssignmentsDto) {
    return this.service.list(query);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.service.findOne(id);
  }

  @Post()
  create(@Body() dto: CreateAssignmentDto) {
    return this.service.create(dto);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() dto: UpdateAssignmentDto) {
    return this.service.update(id, dto);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.service.remove(id);
  }

  @Post(':id/submit')
  submit(@Param('id') id: string, @Body() dto: SubmitDto) {
    return this.service.submit(id, dto);
  }

  @Get(':id/submissions')
  submissions(@Param('id') id: string) {
    return this.service.submissions(id);
  }


  @Post('bulk/complete')
  bulkComplete(@Body() dto: BulkIdsDto) {
    return this.service.bulkComplete(dto.ids);
  }

  @Post('bulk/delete')
  bulkDelete(@Body() dto: BulkIdsDto) {
    return this.service.bulkDelete(dto.ids);
  }
}
