"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.SuperAdminService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma/prisma.service");
const bcrypt = __importStar(require("bcryptjs"));
const PLANS = {
    monthly: {
        price: 150,
        months: 1,
    },
    quarterly: {
        price: 300,
        months: 3,
    },
    yearly: {
        price: 1000,
        months: 12,
    },
};
let SuperAdminService = class SuperAdminService {
    constructor(prisma) {
        this.prisma = prisma;
        this.includeSubscription = {
            appSubscriptions: {
                orderBy: {
                    endDate: 'desc',
                },
                take: 1,
            },
        };
    }
    formatSubscription(subscription) {
        if (!subscription) {
            return null;
        }
        const isExpired = subscription.endDate <= new Date();
        let status = String(subscription.status).toLowerCase();
        if (status === 'active' &&
            isExpired) {
            status = 'expired';
        }
        return {
            id: Number(subscription.id),
            plan_type: String(subscription.plan).toLowerCase(),
            price: Number(subscription.price),
            start_date: subscription.startDate.toISOString(),
            expiry_date: subscription.endDate.toISOString(),
            status: status,
        };
    }
    formatUser(user) {
        const subscription = user.appSubscriptions?.[0] ?? null;
        return {
            id: Number(user.id),
            name: user.name,
            phone: user.phone,
            email: user.email,
            type: String(user.type).toLowerCase(),
            status: user.isActive
                ? 'active'
                : 'inactive',
            created_at: user.createdAt.toISOString(),
            subscription: this.formatSubscription(subscription),
        };
    }
    async all() {
        const users = await this.prisma.admin.findMany({
            include: {
                appSubscriptions: {
                    orderBy: {
                        endDate: 'desc',
                    },
                    take: 1,
                },
            },
            orderBy: {
                createdAt: 'desc',
            },
        });
        return users.map((user) => {
            return this.formatUser(user);
        });
    }
    async one(id) {
        const adminId = BigInt(id);
        const user = await this.prisma.admin.findUnique({
            where: {
                id: adminId,
            },
            include: this.includeSubscription,
        });
        if (!user) {
            throw new common_1.NotFoundException('User not found');
        }
        return this.formatUser(user);
    }
    async createUser(data) {
        const name = String(data.name ?? '').trim();
        if (!name) {
            throw new common_1.BadRequestException('Name required');
        }
        const email = String(data.email ?? '')
            .trim()
            .toLowerCase();
        if (!email) {
            throw new common_1.BadRequestException('Email required');
        }
        const existingUser = await this.prisma.admin.findUnique({
            where: {
                email: email,
            },
        });
        if (existingUser) {
            throw new common_1.ConflictException('Email already registered');
        }
        const phone = String(data.phone ?? '').trim();
        if (!phone) {
            throw new common_1.BadRequestException('Phone number required');
        }
        const type = String(data.type ?? 'online').toLowerCase();
        if (type !== 'online') {
            throw new common_1.BadRequestException('Only online accounts are supported');
        }
        const password = String(data.password ?? '');
        if (password.length < 4) {
            throw new common_1.BadRequestException('Password must be at least 4 characters');
        }
        const passwordHash = await bcrypt.hash(password, 12);
        const admin = await this.prisma.admin.create({
            data: {
                name: name,
                email: email,
                phone: phone,
                type: type,
                isActive: true,
                passwordHash: passwordHash,
            },
        });
        await this.prisma.plan.createMany({
            data: [
                {
                    adminId: admin.id,
                    months: 1,
                    fee: 65,
                },
                {
                    adminId: admin.id,
                    months: 3,
                    fee: 180,
                },
                {
                    adminId: admin.id,
                    months: 6,
                    fee: 340,
                },
                {
                    adminId: admin.id,
                    months: 12,
                    fee: 620,
                },
            ],
        });
        return this.one(admin.id.toString());
    }
    async update(id, data) {
        const adminId = BigInt(id);
        const currentUser = await this.prisma.admin.findUnique({
            where: {
                id: adminId,
            },
        });
        if (!currentUser) {
            throw new common_1.NotFoundException('User not found');
        }
        const updateData = {};
        if (data.name !== undefined) {
            const name = String(data.name).trim();
            if (!name) {
                throw new common_1.BadRequestException('Name required');
            }
            updateData.name = name;
        }
        if (data.phone !== undefined) {
            const phone = String(data.phone).trim();
            if (!phone) {
                throw new common_1.BadRequestException('Phone number required');
            }
            updateData.phone = phone;
        }
        if (data.type !== undefined) {
            const type = String(data.type).toLowerCase();
            if (type !== 'online') {
                throw new common_1.BadRequestException('Only online accounts are supported');
            }
            updateData.type = type;
        }
        if (data.email !== undefined) {
            const email = String(data.email)
                .trim()
                .toLowerCase();
            if (!email) {
                throw new common_1.BadRequestException('Email required');
            }
            const existingUser = await this.prisma.admin.findUnique({
                where: {
                    email: email,
                },
            });
            if (existingUser &&
                existingUser.id !== adminId) {
                throw new common_1.ConflictException('Email already registered');
            }
            updateData.email = email;
        }
        if (Object.keys(updateData).length === 0) {
            throw new common_1.BadRequestException('No editable fields supplied');
        }
        await this.prisma.admin.update({
            where: {
                id: adminId,
            },
            data: updateData,
        });
        return this.one(id);
    }
    async status(id, active) {
        const adminId = BigInt(id);
        await this.requireUser(adminId);
        await this.prisma.admin.update({
            where: {
                id: adminId,
            },
            data: {
                isActive: Boolean(active),
            },
        });
        return {
            success: true,
        };
    }
    async resetPassword(id, password) {
        const adminId = BigInt(id);
        await this.requireUser(adminId);
        const newPassword = String(password ?? '');
        if (newPassword.length < 4) {
            throw new common_1.BadRequestException('Password must be at least 4 characters');
        }
        const passwordHash = await bcrypt.hash(newPassword, 12);
        await this.prisma.admin.update({
            where: {
                id: adminId,
            },
            data: {
                passwordHash: passwordHash,
            },
        });
        return {
            success: true,
            message: 'Password reset successfully',
        };
    }
    async assign(id, planType, renew = false) {
        const adminId = BigInt(id);
        const admin = await this.requireUser(adminId);
        if (admin.type !== 'online') {
            throw new common_1.BadRequestException('Subscription is only available for online users');
        }
        const normalizedPlan = String(planType ?? '').toLowerCase();
        const planConfig = PLANS[normalizedPlan];
        if (!planConfig) {
            throw new common_1.BadRequestException('Invalid subscription plan');
        }
        const latestSubscription = await this.prisma.appSubscription.findFirst({
            where: {
                adminId: admin.id,
            },
            orderBy: {
                endDate: 'desc',
            },
        });
        const now = new Date();
        let startDate = new Date(now);
        if (renew &&
            latestSubscription &&
            latestSubscription.endDate > now) {
            startDate = new Date(latestSubscription.endDate);
        }
        const endDate = new Date(startDate);
        endDate.setMonth(endDate.getMonth() +
            planConfig.months);
        await this.prisma.$transaction(async (transaction) => {
            await transaction.appSubscription.updateMany({
                where: {
                    adminId: admin.id,
                    status: 'active',
                },
                data: {
                    status: 'replaced',
                },
            });
            await transaction.appSubscription.create({
                data: {
                    adminId: admin.id,
                    plan: normalizedPlan,
                    price: planConfig.price,
                    startDate: startDate,
                    endDate: endDate,
                    status: 'active',
                },
            });
        });
        return this.one(id);
    }
    async requireUser(id) {
        const admin = await this.prisma.admin.findUnique({
            where: {
                id: id,
            },
        });
        if (!admin) {
            throw new common_1.NotFoundException('User not found');
        }
        return admin;
    }
};
exports.SuperAdminService = SuperAdminService;
exports.SuperAdminService = SuperAdminService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], SuperAdminService);
//# sourceMappingURL=super-admin.service.js.map