import { JwtService } from '@nestjs/jwt';
import { PrismaService } from '../prisma/prisma.service';
type RegistrationInput = {
    name: string;
    email: string;
    password: string;
    phone?: string;
};
export declare class AuthService {
    private p;
    private jwt;
    constructor(p: PrismaService, jwt: JwtService);
    register(d: RegistrationInput): Promise<{
        success: boolean;
    }>;
    login(d: any): Promise<{
        token: string;
        user: {
            id: number;
            name: string;
            email: string;
            type: string;
            phone: string;
            is_active: true;
        };
    }>;
    getProfile(adminId: bigint): Promise<{
        id: number;
        name: string;
        email: string;
        type: string;
        phone: string;
        is_active: boolean;
        created_at: string;
    }>;
    updateProfile(adminId: bigint, name: string): Promise<{
        id: number;
        name: string;
        email: string;
        type: string;
        phone: string;
        is_active: boolean;
        created_at: string;
    }>;
    changePassword(adminId: bigint, currentPassword: string, newPassword: string): Promise<{
        success: boolean;
    }>;
}
export {};
