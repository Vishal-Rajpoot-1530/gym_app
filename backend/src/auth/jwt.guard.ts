import { CanActivate, ExecutionContext, Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class JwtGuard implements CanActivate {
  constructor(private jwt: JwtService, private p: PrismaService) {}
  async canActivate(c: ExecutionContext) {
    const r=c.switchToHttp().getRequest(),h=r.headers.authorization||'';
    if(!h.startsWith('Bearer '))throw new UnauthorizedException();
    try {
      const x=await this.jwt.verifyAsync(h.slice(7),{secret:process.env.JWT_SECRET});
      const id=BigInt(x.sub);
      const admin=await this.p.admin.findUnique({where:{id}});
      if(!admin || !admin.isActive) throw new UnauthorizedException('Account is inactive');
      if(admin.type!=='online') throw new UnauthorizedException('Offline accounts are no longer supported');
      const sub=await this.p.appSubscription.findFirst({where:{adminId:id,status:'active',endDate:{gt:new Date()}},orderBy:{endDate:'desc'}});
      if(!sub)throw new UnauthorizedException('Online subscription is missing or expired');
      r.user={id,email:admin.email,type:admin.type};return true;
    } catch(e) { if(e instanceof UnauthorizedException)throw e; throw new UnauthorizedException(); }
  }
}
