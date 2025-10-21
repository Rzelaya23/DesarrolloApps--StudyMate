import { Body, Controller, Get, Post, Req, UseGuards, UnauthorizedException } from '@nestjs/common';
import { AuthService } from './auth.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { JwtAuthGuard } from './jwt.guard';
import { IsEmail, IsString, MinLength } from 'class-validator';

class RefreshDto { @IsString() refreshToken!: string; }
class ForgotDto { @IsEmail() email!: string; }
class ResetDto {
  @IsString() token!: string;
  @IsString() @MinLength(8) newPassword!: string;
}

@Controller('api/auth')
export class AuthController {
  constructor(private readonly auth: AuthService) {}

  @Post('register')
  register(@Body() dto: RegisterDto) {
    return this.auth.register(dto);
  }

  @Post('login')
  login(@Body() dto: LoginDto) {
    return this.auth.login(dto);
  }

  @UseGuards(JwtAuthGuard)
  @Get('me')
  async me(@Req() req: any) {
    const userId = req.user?.sub ?? req.user?.userId;
    if (!userId) throw new UnauthorizedException('Invalid or missing token');
    return this.auth.me(userId);
  }

  @Post('refresh')
  refresh(@Body() dto: RefreshDto) {
    return this.auth.refresh(dto.refreshToken);
  }

  @UseGuards(JwtAuthGuard)
  @Post('logout')
  logout(@Req() req: any) {
    const userId = req.user?.sub ?? req.user?.userId;
    if (!userId) throw new UnauthorizedException('Invalid or missing token');
    return this.auth.logout(userId);
  }

  @Post('password/forgot')
  forgot(@Body() dto: ForgotDto) {
    return this.auth.forgotPassword(dto.email);
  }

  @Post('password/reset')
  reset(@Body() dto: ResetDto) {
    return this.auth.resetPassword(dto.token, dto.newPassword);
  }
}
