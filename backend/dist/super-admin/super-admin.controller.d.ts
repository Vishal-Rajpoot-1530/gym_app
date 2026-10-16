import { SuperAdminService } from './super-admin.service';
export declare class SuperAdminController {
    private readonly superAdminService;
    constructor(superAdminService: SuperAdminService);
    getAllUsers(): Promise<{
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
    getUser(id: string): Promise<{
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
    updateUser(id: string, data: any): Promise<{
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
    updateUserStatus(id: string, data: any): Promise<{
        success: boolean;
    }>;
    assignSubscription(id: string, data: any): Promise<{
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
    renewSubscription(id: string, data: any): Promise<{
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
    resetPassword(id: string, data: any): Promise<{
        success: boolean;
        message: string;
    }>;
}
