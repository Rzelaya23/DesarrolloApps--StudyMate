import { IsISO8601, IsOptional } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';

export class QueryEventsDto {
  @ApiPropertyOptional({
    example: '2025-11-01T00:00:00Z',
    description: 'Filtra eventos que inician a partir de esta fecha (ISO 8601).',
  })
  @IsOptional()
  @IsISO8601()
  from?: string;

  @ApiPropertyOptional({
    example: '2025-12-31T23:59:59Z',
    description: 'Filtra eventos que finalizan antes de esta fecha (ISO 8601).',
  })
  @IsOptional()
  @IsISO8601()
  to?: string;
}
