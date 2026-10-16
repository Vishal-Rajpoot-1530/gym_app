import { BadRequestException, ConflictException, Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { PrismaService } from '../prisma/prisma.service';
import * as bcrypt from 'bcryptjs';

type RegistrationInput = {
  name: string;
  email: string;
  password: string;
  phone?: string;
};

@Injectable()
export class AuthService {
  constructor(private p: PrismaService, private jwt: JwtService) {}

  async register(d: RegistrationInput) {
    const email = d.email.trim().toLowerCase();
    if (await this.p.admin.findUnique({ where: { email } })) {
      throw new ConflictException('Email already registered');
    }
    const hash = await bcrypt.hash(d.password, 12);
    await this.p.$transaction(async (tx) => {
      const a = await tx.admin.create({
        data: {
          name: d.name,
          email,
          passwordHash: hash,
          type: 'online',
          phone: d.phone?.trim() ?? '',
        },
      });
      await tx.plan.createMany({
        data: [[1, 65], [3, 180], [6, 340], [12, 620]].map(([months, fee]) => ({
          adminId: a.id,
          months,
          fee,
        })),
      });
    });
    return { success: true };
  }

  async login(d: any) {
    const email = d.email.trim().toLowerCase();
    const u = await this.p.admin.findUnique({ where: { email } });
    if (!u || !await bcrypt.compare(d.password, u.passwordHash)) {
      throw new UnauthorizedException('Invalid email or password');
    }
    if (!u.isActive) throw new UnauthorizedException('Account is inactive');
    if (u.type !== 'online') {
      throw new UnauthorizedException('Offline accounts are no longer supported');
    }
    const sub = await this.p.appSubscription.findFirst({ where: { adminId: u.id, status: 'active', endDate: { gt: new Date() } }, orderBy: { endDate: 'desc' } });
    if (!sub) throw new UnauthorizedException('Online subscription is missing or expired');
    const token = await this.jwt.signAsync(
      { sub: u.id.toString(), email: u.email },
      { secret: process.env.JWT_SECRET, expiresIn: (process.env.JWT_EXPIRES_IN || '30d') as any },
    );
    return {
      token,
      user: {
        id: Number(u.id),
        name: u.name,
        email: u.email,
        type: u.type,
        phone: u.phone,
        is_active: u.isActive,
      },
    };
  }

  async getProfile(adminId: bigint) {
    const admin = await this.p.admin.findUniqueOrThrow({
      where: { id: adminId },
      select: { id: true, name: true, email: true, phone: true, type: true, isActive: true, createdAt: true },
    });
    return {
      id: Number(admin.id),
      name: admin.name,
      email: admin.email,
      type: admin.type,
      phone: admin.phone,
      is_active: admin.isActive,
      created_at: admin.createdAt.toISOString(),
    };
  }

  async updateProfile(adminId: bigint, name: string) {
    const trimmedName = name.trim();
    if (!trimmedName) {
      throw new BadRequestException('Name cannot be empty.');
    }
    const admin = await this.p.admin.update({
      where: { id: adminId },
      data: { name: trimmedName },
      select: { id: true, name: true, email: true, phone: true, type: true, isActive: true, createdAt: true },
    });
    return {
      id: Number(admin.id),
      name: admin.name,
      email: admin.email,
      type: admin.type,
      phone: admin.phone,
      is_active: admin.isActive,
      created_at: admin.createdAt.toISOString(),
    };
  }

  async changePassword(adminId: bigint, currentPassword: string, newPassword: string) {
    const admin = await this.p.admin.findUniqueOrThrow({ where: { id: adminId } });
    if (!await bcrypt.compare(currentPassword, admin.passwordHash)) {
      throw new UnauthorizedException('Current password is incorrect.');
    }
    const passwordHash = await bcrypt.hash(newPassword, 12);
    await this.p.admin.update({ where: { id: adminId }, data: { passwordHash } });
    return { success: true };
  }
}