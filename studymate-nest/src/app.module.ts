import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AuthModule } from './auth/auth.module';
import { StudentsModule } from './students/students.module';
import { CoursesModule } from './courses/courses.module';
import { AssignmentsModule } from './assignments/assignments.module';
import { SubmissionsModule } from './submissions/submissions.module';
import { EventsModule } from './events/events.module';
import { AiModule } from './ai/ai.module';

@Module({
  imports: [
    AuthModule,
    StudentsModule,
    CoursesModule,
    AssignmentsModule,
    SubmissionsModule,
    EventsModule,
    AiModule,
  ],
  controllers: [AppController],
  providers: [],
})
export class AppModule {}
