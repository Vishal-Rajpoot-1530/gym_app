import { PrismaService } from '../prisma/prisma.service';
type PlanCode = 'monthly' | 'quarterly' | 'yearly';
export declare class SuperAdminService {
    private readonly prisma;
    constructor(prisma: PrismaService);
    private readonly includeSubscription;
    private formatSubscription;
    private formatUser;
    all(): Promise<{
        id: number;
        name: any;
        phone: any;
        email: any;
        type: string;
        status: string;
        created_at: any;
        subscription: {
            id: number;
            plan_type: string;
            price: number;
            start_date: any;
            expiry_date: any;
            status: string;
        } | null;
    }[]>;
    one(id: string): Promise<{
        id: number;
        name: any;
        phone: any;
        email: any;
        type: string;
        status: string;
        created_at: any;
        subscription: {
            id: number;
            plan_type: string;
            price: number;
            start_date: any;
            expiry_date: any;
            status: string;
        } | null;
    }>;
    createUser(data: any): Promise<{
        id: number;
        name: any;
        phone: any;
        email: any;
        type: string;
        status: string;
        created_at: any;
        subscription: {
            id: number;
            plan_type: string;
            price: number;
            start_date: any;
            expiry_date: any;
            status: string;
        } | null;
    }>;
    update(id: string, data: any): Promise<{
        id: number;
        name: any;
        phone: any;
        email: any;
        type: string;
        status: string;
        created_at: any;
        subscription: {
            id: number;
            plan_type: string;
            price: number;
            start_date: any;
            expiry_date: any;
            status: string;
        } | null;
    }>;
    status(id: string, active: boolean): Promise<{
        success: boolean;
    }>;
    resetPassword(id: string, password: string): Promise<{
        success: boolean;
        message: string;
    }>;
    assign(id: string, planType: PlanCode, renew?: boolean): Promise<{
        id: number;
        name: any;
        phone: any;
        email: any;
        type: string;
        status: string;
        created_at: any;
        subscription: {
            id: number;
            plan_type: string;
            price: number;
            start_date: any;
            expiry_date: any;
            status: string;
        } | null;
    }>;
    private requireUser;
}
export {};
