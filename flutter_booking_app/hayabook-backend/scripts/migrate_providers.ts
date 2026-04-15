import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('--- STARTING PROVIDER APPROVAL MIGRATION ---');
  
  const result = await prisma.providerProfile.updateMany({
    where: {
      verificationStatus: {
        in: ['PENDING', 'REJECTED']
      }
    },
    data: {
      verificationStatus: 'APPROVED'
    }
  });

  console.log(`Successfully approved ${result.count} legacy providers.`);
  console.log('--- MIGRATION COMPLETE ---');
}

main()
  .catch((e) => {
    console.error('Migration failed:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
