// src/auth/auth.controller.ts
import {
  Body, Controller, Get, Post, Req, UseGuards, UnauthorizedException, HttpCode
} from '@nestjs/common';
import { AuthService } from './auth.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { JwtAuthGuard } from './jwt.guard';
import { IsEmail, IsString, MinLength } from 'class-validator';
import { ApiTags, ApiOperation, ApiCreatedResponse, ApiOkResponse, ApiNoContentResponse, ApiBearerAuth } from '@nestjs/swagger';

// DTOs inline documentados para Swagger
class RefreshDto { @IsString() refreshToken!: string; }
class ForgotDto { @IsEmail() email!: string; }
class ResetDto {
  @IsString() token!: string;
  @IsString() @MinLength(8) newPassword!: string;
}

// Puedes crear un DTO formal para la respuesta si prefieres
class AuthResponseDto {
  id!: string;
  name!: string;
  email!: string;
  accessToken!: string;
  refreshToken!: string;
}

@ApiTags('auth')
@Controller('auth') // <<< sin 'api' aquí
export class AuthController {
  constructor(private readonly auth: AuthService) {}

  @Post('register')
  @ApiOperation({ summary: 'Registro de usuario' })
  @ApiCreatedResponse({ type: AuthResponseDto, description: 'Usuario creado y tokens emitidos' })
  async register(@Body() dto: RegisterDto) {
    // Asegúrate que esto DEVUELVA un objeto JSON serializable
    return this.auth.register(dto);
  }

  @Post('login')
  @ApiOperation({ summary: 'Inicio de sesión' })
  @ApiOkResponse({ type: AuthResponseDto })
  async login(@Body() dto: LoginDto) {
    return this.auth.login(dto);
  }

  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('jwt')
  @Get('me')
  @ApiOperation({ summary: 'Perfil del usuario autenticado' })
  @ApiOkResponse({ description: 'Perfil del usuario' })
  async me(@Req() req: any) {
    const userId = req.user?.sub ?? req.user?.userId;
    if (!userId) throw new UnauthorizedException('Invalid or missing token');
    return this.auth.me(userId);
  }

  @Post('refresh')
  @ApiOperation({ summary: 'Refrescar token' })
  @ApiOkResponse({ description: 'Tokens renovados' })
  async refresh(@Body() dto: RefreshDto) {
    return this.auth.refresh(dto.refreshToken);
  }

  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('jwt')
  @Post('logout')
  @HttpCode(204) // <<< si no devuelves body, usa 204
  @ApiOperation({ summary: 'Cerrar sesión' })
  @ApiNoContentResponse({ description: 'Sesión cerrada' })
  async logout(@Req() req: any) {
    const userId = req.user?.sub ?? req.user?.userId;
    if (!userId) throw new UnauthorizedException('Invalid or missing token');
    await this.auth.logout(userId);
    // No retornes body con 204
  }

  @Post('password/forgot')
  @ApiOperation({ summary: 'Solicitar recuperación de contraseña' })
  @ApiOkResponse({ description: 'Correo de recuperación enviado (si aplica)' })
  async forgot(@Body() dto: ForgotDto) {
    return this.auth.forgotPassword(dto.email);
  }

  @Post('password/reset')
  @ApiOperation({ summary: 'Restablecer contraseña' })
  @ApiOkResponse({ description: 'Contraseña restablecida' })
  async reset(@Body() dto: ResetDto) {
    return this.auth.resetPassword(dto.token, dto.newPassword);
  }
}
