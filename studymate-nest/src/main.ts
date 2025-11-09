import 'reflect-metadata';
import 'dotenv/config';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import * as fs from 'fs';
import helmet from 'helmet';
import * as bodyParser from 'body-parser';
const listEndpoints = require('express-list-endpoints');

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  const expressApp = app.getHttpAdapter().getInstance();
  expressApp.set('trust proxy', 1);
  
  app.use(helmet());
  app.use(bodyParser.json({ limit: process.env.JSON_BODY_LIMIT || '2mb' }));
  app.use(bodyParser.urlencoded({ limit: process.env.JSON_BODY_LIMIT || '2mb', extended: true }));

  app.useGlobalPipes(new ValidationPipe({ whitelist: true }));
  app.enableCors();
  if (process.env.API_PREFIX) app.setGlobalPrefix(process.env.API_PREFIX);
  app.enableShutdownHooks();

  // Prefijo global para rutas HTTP
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
        description:
          'Pegue aquí su token JWT para probar endpoints protegidos.',
      },
      'jwt',
    )
    // Tag que tenía tu compa
    .addTag('health')
    // Alinea Swagger con y sin prefijo (útil en dev)
    .addServer('/api')
    .addServer('/')
    .build();

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api-docs', app, document, {
    swaggerOptions: {
      persistAuthorization: true,
    },
  });
  // --- Fin Swagger ---

  await app.listen(Number(process.env.PORT ?? 4000));

  const apiPrefix = (app as any).getGlobalPrefix?.() || '';
  const versionPrefix = process.env.API_VERSION_PREFIX || '';

  type PathMap = Record<string, any>;
  const paths: PathMap = (document as any).paths || {};
  const rows: Array<{ method: string; path: string }> = [];

  for (const [rawPath, methods] of Object.entries(paths)) {
    for (const m of Object.keys(methods)) {
      const full = `/${[apiPrefix, versionPrefix, rawPath].filter(Boolean).join('/')}`
        .replace(/\/+/g, '/');
      rows.push({ method: m.toUpperCase(), path: full });
    }
  }

  console.table(rows);
  fs.writeFileSync('routes-openapi.json', JSON.stringify(rows, null, 2));

  // ---- Dump de rutas (express-list-endpoints) ----
  const http = app.getHttpAdapter().getInstance();
  const routes = listEndpoints(http);
  const flat = routes.flatMap((r: any) =>
    (r.methods as string[]).map((m: string) => ({
      method: m,
      path: r.path,
    })),
  );

  console.table(flat);
  fs.writeFileSync('routes-express.json', JSON.stringify(flat, null, 2));
}

bootstrap();
