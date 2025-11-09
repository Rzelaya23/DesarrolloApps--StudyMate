import 'dotenv/config';
import 'reflect-metadata';
import 'dotenv/config';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import * as fs from 'fs'

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  app.useGlobalPipes(new ValidationPipe({ whitelist: true }));
  app.enableCors();

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
      'jwt',
    )
    .addTag('health')
    .build();

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api-docs', app, document, {
    swaggerOptions: {
      persistAuthorization: true,
    },
  });

  await app.listen(Number(process.env.PORT ?? 4000));

  // Después de await app.listen(...)
  const apiPrefix = (app as any).getGlobalPrefix?.() || ''; // si no tienes globalPrefix, será ''
  const versionPrefix = process.env.API_VERSION_PREFIX || ''; // p.ej. 'v1' si usas versionado por URI

  type PathMap = Record<string, any>;
  const paths: PathMap = (document as any).paths || {};

  const rows: Array<{ method: string; path: string }> = [];

  for (const [rawPath, methods] of Object.entries(paths)) {
    for (const m of Object.keys(methods)) {
      // OpenAPI trae paths sin el global prefix; lo añadimos si existe.
      const full = `/${[apiPrefix, versionPrefix, rawPath].filter(Boolean).join('/')}`
        .replace(/\/+/g, '/'); // normaliza dobles //
      rows.push({ method: m.toUpperCase(), path: full });
    }
  }

  console.table(rows);
  fs.writeFileSync('routes.json', JSON.stringify(rows, null, 2));

  const listEndpoints = require('express-list-endpoints');
  const http = app.getHttpAdapter().getInstance();
  const routes = listEndpoints(http);
  const flat = routes.flatMap((r: any) => r.methods.map((m: string) => ({ method: m, path: r.path })));
  console.table(flat);
  fs.writeFileSync('routes.json', JSON.stringify(flat, null, 2));
}
bootstrap();
