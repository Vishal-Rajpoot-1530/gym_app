import { PrismaService } from '../prisma/prisma.service';
export declare class SettingsController {
    private p;
    constructor(p: PrismaService);
    get(r: any): Promise<{
        revenue_goal: number;
        plans: {
            months: number;
            fee: number;
        }[];
    }>;
    goal(r: any, b: any): Promise<{
        success: boolean;
    }>;
    plans(r: any, b: any): Promise<{
        success: boolean;
    }>;
}
