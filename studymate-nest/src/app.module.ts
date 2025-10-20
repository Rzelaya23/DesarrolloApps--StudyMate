// src/app.module.ts
import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AuthModule } from './auth/auth.module';
import { StudentsModule } from './students/students.module';
import { CoursesModule } from './courses/courses.module';
import { AssignmentsModule } from './assignments/assignments.module';

@Module({
  imports: [
    AuthModule,
    StudentsModule,
    CoursesModule,
    AssignmentsModule,
  ],
  controllers: [AppController],
  providers: [],
})
export class AppModule {}
