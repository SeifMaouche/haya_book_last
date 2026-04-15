// cleanup.ts
import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

async function main() {
  console.log('--- Database Cleanup Started ---');
  
  // Replace '' with null for email
  const emailRes = await prisma.user.updateMany({
    where: { email: '' },
    data: { email: null }
  });
  console.log(`Updated ${emailRes.count} users with empty email to NULL.`);

  // Replace '' with null for phone
  const phoneRes = await prisma.user.updateMany({
    where: { phone: '' },
    data: { phone: null }
  });
  console.log(`Updated ${phoneRes.count} users with empty phone to NULL.`);

  // Delete any incomplete users from previous failed attempts
  // (e.g., users with neither email nor phone if it somehow happened)
  const delRes = await prisma.user.deleteMany({
    where: {
      email: null,
      phone: null
    }
  });
  console.log(`Deleted ${delRes.count} invalid users.`);

  console.log('--- Database Cleanup Finished ---');
}

main()
  .catch(console.error)
  .finally(() => prisma.$disconnect());
