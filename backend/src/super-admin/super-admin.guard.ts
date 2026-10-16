import { CanActivate, ExecutionContext, Injectable, InternalServerErrorException, UnauthorizedException } from '@nestjs/common';
import { timingSafeEqual } from 'node:crypto';

@Injectable()
export class SuperAdminGuard implements CanActivate {
  canActivate(context: ExecutionContext) {
    const req = context.switchToHttp().getRequest();
    const configured = process.env.SUPER_ADMIN_KEY;
    if (!configured) throw new InternalServerErrorException('Super admin access is not configured.');
    const provided = String(req.headers['x-super-admin-key'] ?? '');
    const a = Buffer.from(provided), b = Buffer.from(configured);
    if (a.length !== b.length || !timingSafeEqual(a, b)) throw new UnauthorizedException('Invalid super-admin API key.');
    return true;
  }
}
