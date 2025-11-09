import { Test, TestingModule } from '@nestjs/testing';
import { AppController } from './app.controller';

describe('AppController', () => {
  let appController: AppController;

  beforeEach(async () => {
    const app: TestingModule = await Test.createTestingModule({
      controllers: [AppController],
    }).compile();

    appController = app.get<AppController>(AppController);
  });

  describe('root', () => {
    it('should return a welcome message', () => {
      expect(appController.getHello()).toBe('🚀 StudyMate API funcionando correctamente');
    });
  });

  describe('health', () => {
    it('should return server health status', () => {
      expect(appController.getHealth()).toEqual({
        status: 'ok',
        message: 'Servidor NestJS en línea',
      });
    });
  });
});
