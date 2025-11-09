import { Controller, Get } from '@nestjs/common';

@Controller()
export class AppController {
  @Get()
  getHello(): string {
    return '🚀 StudyMate API funcionando correctamente';
  }

  @Get('health')
  getHealth(): Record<string, string> {
    return { status: 'ok', message: 'Servidor NestJS en línea' };
  }
}
