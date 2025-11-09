import 'reflect-metadata';
import 'dotenv/config';

import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import helmet from 'helmet';
import * as fs from 'fs';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Validación y seguridad básica
  app.useGlobalPipes(new ValidationPipe({ whitelist: true, transform: true }));
  app.use(helmet());
  app.enableCors();

  // Prefijo global de la API
  app.setGlobalPrefix('api');

  // -------------------------------
  // Swagger
  // -------------------------------
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
    // Servidores (útil si mueves el despliegue)
    .addServer('/api')
    .addServer('/')
    .build();

  const document = SwaggerModule.createDocument(app, config);

  SwaggerModule.setup('api-docs', app, document, {
    swaggerOptions: {
      persistAuthorization: true,
    },
  });

  // -------------------------------
  // Levantar servidor
  // -------------------------------
  const port = Number(process.env.PORT ?? 4000);
  await app.listen(port);
  console.log(`🚀 StudyMate API escuchando en http://localhost:${port}`);

  // -------------------------------
  // (Opcional) Volcado de rutas a JSON
  // -------------------------------

  const apiPrefix = (app as any).getGlobalPrefix?.() || ''; // normalmente "api"
  const versionPrefix = process.env.API_VERSION_PREFIX || ''; // p.ej. "v1" si lo usas

  type PathMap = Record<string, any>;
  const paths: PathMap = (document as any).paths || {};

  const rows: Array<{ method: string; path: string }> = [];

  for (const [rawPath, methods] of Object.entries(paths)) {
    for (const m of Object.keys(methods as object)) {
      // OpenAPI trae paths sin el global prefix; lo añadimos si existe.
      const full =
        '/' +
        [apiPrefix, versionPrefix, rawPath].filter(Boolean).join('/');
      const normalized = full.replace(/\/+/g, '/'); // normaliza dobles //
      rows.push({ method: m.toUpperCase(), path: normalized });
    }
  }

  console.table(rows);
  fs.writeFileSync('routes-openapi.json', JSON.stringify(rows, null, 2));

  // También usando express-list-endpoints (si lo tienes instalado)
  // eslint-disable-next-line @typescript-eslint/no-var-requires
  const listEndpoints = require('express-list-endpoints');
  const http = app.getHttpAdapter().getInstance();
  const routes = listEndpoints(http);
  const flat = routes.flatMap((r: any) =>
    r.methods.map((m: string) => ({ method: m, path: r.path })),
  );

  console.table(flat);
  fs.writeFileSync('routes-express.json', JSON.stringify(flat, null, 2));
}

bootstrap();
