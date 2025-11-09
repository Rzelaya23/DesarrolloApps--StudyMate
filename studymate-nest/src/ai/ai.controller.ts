import { Controller, Post, UseInterceptors, UploadedFiles, Body, UseGuards } from '@nestjs/common';
import { FilesInterceptor } from '@nestjs/platform-express';
import { AuthGuard } from '@nestjs/passport';
import { ApiBearerAuth } from '@nestjs/swagger';
import { AiService } from './ai.service';
import { ChatDto } from './dto/chat.dto';
import { aiUploadsMulter } from './ai.multer';

@ApiBearerAuth('jwt')
@UseGuards(AuthGuard('jwt'))
@Controller('chat')
export class AiController {
  constructor(private readonly ai: AiService) {}

  @Post()
  @UseInterceptors(FilesInterceptor('attachments[]', undefined, aiUploadsMulter))
  async chat(@Body() dto: ChatDto, @UploadedFiles() files: Express.Multer.File[]) {
    const names = Array.isArray(files) ? files.map(f => f.originalname || f.filename) : [];
    const reply = await this.ai.answer(dto.message, names);
    return { reply };
  }
}
