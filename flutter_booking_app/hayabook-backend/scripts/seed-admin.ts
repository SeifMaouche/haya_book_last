/**
 * scripts/seed-admin.ts
 * Run once to create the initial ADMIN user in the database.
 *
 * Usage:
 *   cd hayabook-backend
 *   npx ts-node scripts/seed-admin.ts
 *
 * Default credentials:
 *   Email    : admin@hayabook.dz
 *   Password : Admin@1234
 */
import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function main() {
  const email    = 'admin@hayabook.dz';
  const password = 'Admin@1234';

  const existing = await prisma.user.findUnique({ where: { email } });
  if (existing) {
    console.log(`✅  Admin already exists: ${email}`);
    return;
  }

  const passwordHash = await bcrypt.hash(password, 10);

  const admin = await prisma.user.create({
    data: {
      email,
      passwordHash,
      firstName:  'HayaBook',
      lastName:   'Admin',
      role:       'ADMIN',
      isVerified: true,
      isActive:   true,
    },
  });

  console.log(`✅  Admin created successfully!`);
  console.log(`    Email    : ${admin.email}`);
  console.log(`    Password : ${password}`);
  console.log(`    ID       : ${admin.id}`);
}

main()
  .catch((e) => { console.error('❌ Seed failed:', e); })
  .finally(() => prisma.$disconnect());
