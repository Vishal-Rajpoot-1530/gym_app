import { PrismaService } from '../prisma/prisma.service';
export declare class MembersService {
    private p;
    constructor(p: PrismaService);
    all(adminId: bigint): Promise<{
        id: number;
        name: any;
        email: any;
        phone: any;
        gender: any;
        age: any;
        plan: any;
        duration_months: any;
        fee: number;
        joining_date: string | null;
        expiry_date: string | null;
        status: any;
        notes: any;
        keycard: any;
        pr_kg: number;
        photo: any;
        created_at: string | null;
    }[]>;
    one(adminId: bigint, id: string): Promise<{
        id: number;
        name: any;
        email: any;
        phone: any;
        gender: any;
        age: any;
        plan: any;
        duration_months: any;
        fee: number;
        joining_date: string | null;
        expiry_date: string | null;
        status: any;
        notes: any;
        keycard: any;
        pr_kg: number;
        photo: any;
        created_at: string | null;
    }>;
    key(adminId: bigint, code?: string, except?: string): Promise<{
        taken: boolean;
    }>;
    body(adminId: bigint, body: any): {
        adminId: bigint;
        name: any;
        email: any;
        phone: any;
        gender: any;
        age: number;
        plan: any;
        durationMonths: number;
        fee: any;
        joiningDate: Date;
        expiryDate: Date;
        status: any;
        notesText: any;
        keycard: any;
        prKg: any;
        createdAt: Date;
    };
    add(adminId: bigint, body: any): Promise<{
        id: number;
    }>;
    update(adminId: bigint, id: string, body: any): Promise<{
        success: boolean;
        transactionUpdated: boolean;
    }>;
    renew(adminId: bigint, id: string, body: any): Promise<{
        success: boolean;
    }>;
    adjustment(adminId: bigint, id: string, body: any): Promise<{
        success: boolean;
    }>;
    status(adminId: bigint, id: string, active: boolean): Promise<{
        success: boolean;
    }>;
    pr(adminId: bigint, id: string, kg: any): Promise<{
        success: boolean;
    }>;
    photo(adminId: bigint, id: string, file?: Express.Multer.File): Promise<{
        success: boolean;
    }>;
    del(adminId: bigint, id: string): Promise<{
        deleted: number;
    }>;
    clean(adminId: bigint): Promise<{
        deleted: number;
    }>;
    notes(adminId: bigint, id: string): Promise<{
        id: number;
        member_id: number;
        title: string;
        body: string;
        tags: string;
        created_at: string;
    }[]>;
    addNote(adminId: bigint, id: string, body: any): Promise<{
        success: boolean;
    }>;
}
