import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('--- Starting Avatar Migration ---');

  // 1. Update Users with null or empty profileImage
  const userResult = await prisma.user.updateMany({
    where: {
      OR: [
        { profileImage: null },
        { profileImage: '' },
      ],
    },
    data: {
      profileImage: 'default',
    },
  });
  console.log(`Updated ${userResult.count} users with default avatar.`);

  console.log('--- Migration Finished ---');
}

main()
  .catch((e) => {
    console.error(e);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
