import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('--- STARTING AVATAR MIGRATION ---');
  
  const result = await prisma.user.updateMany({
    where: {
      OR: [
        { profileImage: null },
        { profileImage: '' }
      ]
    },
    data: {
      profileImage: 'default'
    }
  });

  console.log(`Updated ${result.count} users to use the 'default' avatar.`);
  console.log('--- MIGRATION COMPLETE ---');
}

main()
  .catch((e) => {
    console.error('Migration failed:', e);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
