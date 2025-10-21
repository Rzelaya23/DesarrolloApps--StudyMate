import 'reflect-metadata';
import 'dotenv/config';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';

// 👇 Agregados para Swagger
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Validación & CORS (tal como ya lo tenías)
  app.useGlobalPipes(new ValidationPipe({ whitelist: true }));
  app.enableCors();

  // ---------- Swagger Bootstrapping ----------
  // Puedes condicionar por entorno si quieres:
  // if (process.env.NODE_ENV !== 'production') { ... }
  const config = new DocumentBuilder()
    .setTitle('StudyMate API')
    .setDescription('Documentación de la API de StudyMate')
    .setVersion('1.0.0')
    .addBearerAuth(
      {
        type: 'http',
        scheme: 'bearer',
        bearerFormat: 'JWT',
        description: 'Ingrese su JWT en el campo "Authorize".',
      },
      'jwt', // nombre del esquema (opcional, pero útil)
    )
    .addTag('health') // ejemplo, cambia/añade los tags que uses
    .build();

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api-docs', app, document, {
    swaggerOptions: {
      persistAuthorization: true, // mantiene el token entre recargas
    },
  });
  // ---------- Fin Swagger ----------

  await app.listen(Number(process.env.PORT ?? 4000));
}
bootstrap();
