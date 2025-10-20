import { IsOptional, IsString, IsObject } from 'class-validator';
export class UpdatePreferencesDto {
  @IsOptional() @IsString() theme?: string;
  @IsOptional() @IsObject() reminderDefaults?: Record<string, any>;
  @IsOptional() @IsString() weekStartsOn?: string;
  @IsOptional() @IsString() calendarView?: string;
}