import { AuthService } from './auth.service';
declare class RegisterDto {
    name: string;
    email: string;
    password: string;
    type?: 'online';
    phone?: string;
}
declare class LoginDto {
    email: string;
    password: string;
}
declare class UpdateProfileDto {
    name: string;
}
declare class ChangePasswordDto {
    currentPassword: string;
    newPassword: string;
}
export declare class AuthController {
    private s;
    constructor(s: AuthService);
    private assertProvisioningKey;
    register(d: RegisterDto, key?: string): Promise<{
        success: boolean;
    }>;
    login(d: LoginDto): Promise<{
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
    profile(r: any): Promise<{
        id: number;
        name: string;
        email: string;
        type: string;
        phone: string;
        is_active: boolean;
        created_at: string;
    }>;
    updateProfile(r: any, d: UpdateProfileDto): Promise<{
        id: number;
        name: string;
        email: string;
        type: string;
        phone: string;
        is_active: boolean;
        created_at: string;
    }>;
    changePassword(r: any, d: ChangePasswordDto): Promise<{
        success: boolean;
    }>;
}
export {};
