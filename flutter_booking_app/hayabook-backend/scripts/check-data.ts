import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

async function main() {
  const providers = await prisma.providerProfile.findMany({
    include: { services: true }
  });
  
  console.log('--- Database Check ---');
  for (const p of providers) {
    console.log(`Provider: ${p.businessName} (ID: ${p.id})`);
    console.log(`Availability: ${p.availability}`);
    console.log('Services:');
    p.services.forEach(s => console.log(` - ${s.name} (DZD ${s.price})`));
    console.log('----------------------');
  }
}

main().catch(console.error).finally(() => prisma.$disconnect());
