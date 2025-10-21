import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Param,
  Body,
  Query,
  UseGuards,
  Req,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt.guard'; 
import { EventsService } from './events.service';
import { QueryEventsDto } from './dto/query-events.dto';
import { CreateEventDto } from './dto/create-event.dto';
import { UpdateEventDto } from './dto/update-event.dto';

@Controller('api/v1/events')
@UseGuards(JwtAuthGuard)
export class EventsController {
  constructor(private readonly events: EventsService) {}

  @Get()
  list(@Query() query: QueryEventsDto, @Req() req) {
    return this.events.list(query, req.user.userId);
  }

  @Post()
  create(@Body() dto: CreateEventDto, @Req() req) {
    return this.events.create(dto, req.user.userId);
  }

  @Get(':id')
  get(@Param('id') id: string, @Req() req) {
    return this.events.get(id, req.user.userId);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() dto: UpdateEventDto, @Req() req) {
    return this.events.update(id, dto, req.user.userId);
  }

  @Delete(':id')
  remove(@Param('id') id: string, @Req() req) {
    return this.events.delete(id, req.user.userId);
  }
}
