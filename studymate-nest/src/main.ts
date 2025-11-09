import 'reflect-metadata';
import 'dotenv/config';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Validación & CORS
  app.useGlobalPipes(new ValidationPipe({ whitelist: true }));
  app.enableCors();

  // Prefijo global para rutas HTTP (quítalo si no lo usas)
  app.setGlobalPrefix('api');

  // --- Swagger ---
  const config = new DocumentBuilder()
    .setTitle('StudyMate API')
    .setDescription('Documentación de la API de StudyMate')
    .setVersion('1.0.0')
    .addBearerAuth(
      {
        type: 'http',
        scheme: 'bearer',
        bearerFormat: 'JWT',
        description: 'Pegue aquí su token JWT para probar endpoints protegidos.',
      },
      'jwt',
    )
    // Alinea Swagger con y sin prefijo (útil en dev o si cambias despliegue)
    .addServer('/api')
    .addServer('/')
    .build();

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api-docs', app, document, {
    swaggerOptions: { persistAuthorization: true },
  });
  // --- Fin Swagger ---

  await app.listen(Number(process.env.PORT ?? 4000));
}
bootstrap();
