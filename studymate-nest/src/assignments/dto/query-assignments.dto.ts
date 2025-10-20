// src/assignments/dto/query-assignments.dto.ts
import { IsOptional, IsString, IsISO8601, IsInt, Min } from 'class-validator';
import { Type } from 'class-transformer';

export class QueryAssignmentsDto {
  @IsOptional() @IsString() status?: string;
  @IsOptional() @IsISO8601() due_from?: string;
  @IsOptional() @IsISO8601() due_to?: string;
  @IsOptional() @IsString() courseId?: string;
  @IsOptional() @Type(() => Number) @IsInt() priority?: number;
  @IsOptional() @Type(() => Number) @IsInt() @Min(1) page?: number = 1;
  @IsOptional() @Type(() => Number) @IsInt() @Min(1) limit?: number = 10;
}

