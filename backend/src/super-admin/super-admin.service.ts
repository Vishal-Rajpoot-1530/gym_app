import {
  BadRequestException,
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';

import { PrismaService } from '../prisma/prisma.service';

import * as bcrypt from 'bcryptjs';


// ============================================================
// SOFTWARE SUBSCRIPTION PLANS
// ============================================================

type PlanCode =
  | 'monthly'
  | 'quarterly'
  | 'yearly';


const PLANS: Record<
  PlanCode,
  {
    price: number;
    months: number;
  }
> = {
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


// ============================================================
// SUPER ADMIN SERVICE
// ============================================================

@Injectable()
export class SuperAdminService {

  constructor(
    private readonly prisma: PrismaService,
  ) {}


  // ==========================================================
  // PRISMA INCLUDE
  // ==========================================================

  private readonly includeSubscription = {
    appSubscriptions: {
      orderBy: {
        endDate: 'desc' as const,
      },
      take: 1,
    },
  };


  // ==========================================================
  // FORMAT SUBSCRIPTION FOR FLUTTER
  // ==========================================================

private formatSubscription(
  subscription: any,
) {
  if (!subscription) {
    return null;
  }

  const isExpired =
    subscription.endDate <= new Date();

  let status =
    String(subscription.status).toLowerCase();

  if (
    status === 'active' &&
    isExpired
  ) {
    status = 'expired';
  }

  return {
    id: Number(
      subscription.id,
    ),

    plan_type:
      String(subscription.plan).toLowerCase(),

    price: Number(
      subscription.price,
    ),

    start_date:
      subscription.startDate.toISOString(),

    expiry_date:
      subscription.endDate.toISOString(),

    status: status,
  };
}
  // ==========================================================
  // FORMAT USER FOR FLUTTER
  // ==========================================================

private formatUser(
  user: any,
) {
  const subscription =
    user.appSubscriptions?.[0] ?? null;

  return {
    id: Number(
      user.id,
    ),

    name: user.name,

    phone: user.phone,

    email: user.email,

    type:
      String(user.type).toLowerCase(),

    status:
      user.isActive
        ? 'active'
        : 'inactive',

    created_at:
      user.createdAt.toISOString(),

    subscription:
      this.formatSubscription(
        subscription,
      ),
  };
}

  // ==========================================================
  // GET ALL USERS
  // ==========================================================

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

  // ==========================================================
  // GET SINGLE USER
  // ==========================================================

  async one(
    id: string,
  ) {

    const adminId = BigInt(
      id,
    );

    const user =
      await this.prisma.admin.findUnique({
        where: {
          id: adminId,
        },

        include: this.includeSubscription,
      });

    if (!user) {
      throw new NotFoundException(
        'User not found',
      );
    }

    return this.formatUser(
      user,
    );
  }


  // ==========================================================
  // CREATE USER
  // ==========================================================

  async createUser(
    data: any,
  ) {

    // --------------------------------------------------------
    // NAME
    // --------------------------------------------------------

    const name = String(
      data.name ?? '',
    ).trim();

    if (!name) {
      throw new BadRequestException(
        'Name required',
      );
    }


    // --------------------------------------------------------
    // EMAIL
    // --------------------------------------------------------

    const email = String(
      data.email ?? '',
    )
        .trim()
        .toLowerCase();

    if (!email) {
      throw new BadRequestException(
        'Email required',
      );
    }


    // --------------------------------------------------------
    // CHECK DUPLICATE EMAIL
    // --------------------------------------------------------

    const existingUser =
      await this.prisma.admin.findUnique({
        where: {
          email: email,
        },
      });

    if (existingUser) {
      throw new ConflictException(
        'Email already registered',
      );
    }


    // --------------------------------------------------------
    // PHONE
    // --------------------------------------------------------

    const phone = String(
      data.phone ?? '',
    ).trim();

    if (!phone) {
      throw new BadRequestException(
        'Phone number required',
      );
    }


    // --------------------------------------------------------
    // USER TYPE
    // --------------------------------------------------------

    const type = String(data.type ?? 'online').toLowerCase();
    if (type !== 'online') {
      throw new BadRequestException(
        'Only online accounts are supported',
      );
    }


    // --------------------------------------------------------
    // PASSWORD
    // --------------------------------------------------------

    const password = String(
      data.password ?? '',
    );

    if (password.length < 4) {
      throw new BadRequestException(
        'Password must be at least 4 characters',
      );
    }


    // --------------------------------------------------------
    // HASH PASSWORD
    // --------------------------------------------------------

    const passwordHash =
      await bcrypt.hash(
        password,
        12,
      );


    // --------------------------------------------------------
    // CREATE ADMIN
    // --------------------------------------------------------

    const admin =
      await this.prisma.admin.create({
        data: {
          name: name,

          email: email,

          phone: phone,

          type: type,

          isActive: true,

          passwordHash: passwordHash,
        },
      });


    // --------------------------------------------------------
    // CREATE EXISTING GYM MEMBER PLANS
    //
    // IMPORTANT:
    // These are Gym business/member plans.
    // These are NOT software subscriptions.
    // --------------------------------------------------------

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


    // --------------------------------------------------------
    // RETURN CREATED USER
    // --------------------------------------------------------

    return this.one(
      admin.id.toString(),
    );
  }


  // ==========================================================
  // UPDATE USER
  // ==========================================================

  async update(
    id: string,
    data: any,
  ) {

    const adminId = BigInt(
      id,
    );


    // --------------------------------------------------------
    // CHECK USER
    // --------------------------------------------------------

    const currentUser =
      await this.prisma.admin.findUnique({
        where: {
          id: adminId,
        },
      });

    if (!currentUser) {
      throw new NotFoundException(
        'User not found',
      );
    }


    const updateData: any = {};


    // --------------------------------------------------------
    // UPDATE NAME
    // --------------------------------------------------------

    if (data.name !== undefined) {

      const name = String(
        data.name,
      ).trim();

      if (!name) {
        throw new BadRequestException(
          'Name required',
        );
      }

      updateData.name = name;
    }


    // --------------------------------------------------------
    // UPDATE PHONE
    // --------------------------------------------------------

    if (data.phone !== undefined) {

      const phone = String(
        data.phone,
      ).trim();

      if (!phone) {
        throw new BadRequestException(
          'Phone number required',
        );
      }

      updateData.phone = phone;
    }


    // --------------------------------------------------------
    // UPDATE TYPE
    // --------------------------------------------------------

    if (data.type !== undefined) {

      const type = String(data.type).toLowerCase();
      if (type !== 'online') {
        throw new BadRequestException(
          'Only online accounts are supported',
        );
      }

      updateData.type = type;
    }


    // --------------------------------------------------------
    // UPDATE EMAIL
    // --------------------------------------------------------

    if (data.email !== undefined) {

      const email = String(
        data.email,
      )
          .trim()
          .toLowerCase();

      if (!email) {
        throw new BadRequestException(
          'Email required',
        );
      }


      const existingUser =
        await this.prisma.admin.findUnique({
          where: {
            email: email,
          },
        });


      if (
        existingUser &&
        existingUser.id !== adminId
      ) {
        throw new ConflictException(
          'Email already registered',
        );
      }


      updateData.email = email;
    }


    // --------------------------------------------------------
    // NOTHING TO UPDATE
    // --------------------------------------------------------

    if (
      Object.keys(
        updateData,
      ).length === 0
    ) {
      throw new BadRequestException(
        'No editable fields supplied',
      );
    }


    // --------------------------------------------------------
    // UPDATE DATABASE
    // --------------------------------------------------------

    await this.prisma.admin.update({
      where: {
        id: adminId,
      },

      data: updateData,
    });


    // --------------------------------------------------------
    // RETURN UPDATED USER
    // --------------------------------------------------------

    return this.one(
      id,
    );
  }


  // ==========================================================
  // ACTIVE / INACTIVE USER
  // ==========================================================

  async status(
    id: string,
    active: boolean,
  ) {

    const adminId = BigInt(
      id,
    );


    // --------------------------------------------------------
    // CHECK USER EXISTS
    // --------------------------------------------------------

    await this.requireUser(
      adminId,
    );


    // --------------------------------------------------------
    // UPDATE STATUS
    // --------------------------------------------------------

    await this.prisma.admin.update({
      where: {
        id: adminId,
      },

      data: {
        isActive: Boolean(
          active,
        ),
      },
    });


    return {
      success: true,
    };
  }


  // ==========================================================
  // RESET PASSWORD
  // ==========================================================

  async resetPassword(
    id: string,
    password: string,
  ) {

    const adminId = BigInt(
      id,
    );


    // --------------------------------------------------------
    // CHECK USER EXISTS
    // --------------------------------------------------------

    await this.requireUser(
      adminId,
    );


    // --------------------------------------------------------
    // PASSWORD VALIDATION
    // --------------------------------------------------------

    const newPassword = String(
      password ?? '',
    );

    if (
      newPassword.length < 4
    ) {
      throw new BadRequestException(
        'Password must be at least 4 characters',
      );
    }


    // --------------------------------------------------------
    // HASH NEW PASSWORD
    // --------------------------------------------------------

    const passwordHash =
      await bcrypt.hash(
        newPassword,
        12,
      );


    // --------------------------------------------------------
    // UPDATE PASSWORD
    // --------------------------------------------------------

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


  // ==========================================================
  // ASSIGN / RENEW SOFTWARE SUBSCRIPTION
  // ==========================================================

  async assign(
    id: string,
    planType: PlanCode,
    renew = false,
  ) {

    const adminId = BigInt(
      id,
    );


    // --------------------------------------------------------
    // GET USER
    // --------------------------------------------------------

    const admin =
      await this.requireUser(
        adminId,
      );


    // --------------------------------------------------------
    // ONLY ONLINE USER CAN HAVE SUBSCRIPTION
    // --------------------------------------------------------

    if (
      admin.type !== 'online'
    ) {
      throw new BadRequestException(
        'Subscription is only available for online users',
      );
    }


    // --------------------------------------------------------
    // NORMALIZE PLAN TYPE
    //
    // Flutter sends:
    // monthly
    // quarterly
    // yearly
    // --------------------------------------------------------

    const normalizedPlan =
      String(
        planType ?? '',
      ).toLowerCase() as PlanCode;


    // --------------------------------------------------------
    // GET PLAN CONFIGURATION
    // --------------------------------------------------------

    const planConfig =
      PLANS[normalizedPlan];


    if (!planConfig) {
      throw new BadRequestException(
        'Invalid subscription plan',
      );
    }


    // --------------------------------------------------------
    // GET LATEST SOFTWARE SUBSCRIPTION
    // --------------------------------------------------------

    const latestSubscription =
      await this.prisma.appSubscription.findFirst({
        where: {
          adminId: admin.id,
        },

        orderBy: {
          endDate: 'desc',
        },
      });


    const now = new Date();


    // --------------------------------------------------------
    // CALCULATE START DATE
    //
    // ASSIGN:
    // starts today.
    //
    // RENEW:
    // if existing subscription is still valid,
    // continue from current expiry date.
    // --------------------------------------------------------

    let startDate = new Date(
      now,
    );


    if (
      renew &&
      latestSubscription &&
      latestSubscription.endDate > now
    ) {
      startDate = new Date(
        latestSubscription.endDate,
      );
    }


    // --------------------------------------------------------
    // CALCULATE END DATE
    // --------------------------------------------------------

    const endDate = new Date(
      startDate,
    );


    endDate.setMonth(
      endDate.getMonth() +
      planConfig.months,
    );


    // --------------------------------------------------------
    // DATABASE TRANSACTION
    // --------------------------------------------------------

    await this.prisma.$transaction(
      async (transaction) => {

        // ----------------------------------------------------
        // MARK PREVIOUS ACTIVE SUBSCRIPTION AS REPLACED
        // ----------------------------------------------------

        await transaction.appSubscription.updateMany({
          where: {
            adminId: admin.id,

            status: 'active',
          },

          data: {
            status: 'replaced',
          },
        });


        // ----------------------------------------------------
        // CREATE NEW SOFTWARE SUBSCRIPTION
        // ----------------------------------------------------

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
      },
    );


    // --------------------------------------------------------
    // RETURN UPDATED USER
    // --------------------------------------------------------

    return this.one(
      id,
    );
  }


  // ==========================================================
  // REQUIRE USER
  // ==========================================================

  private async requireUser(
    id: bigint,
  ) {

    const admin =
      await this.prisma.admin.findUnique({
        where: {
          id: id,
        },
      });


    if (!admin) {
      throw new NotFoundException(
        'User not found',
      );
    }


    return admin;
  }
}