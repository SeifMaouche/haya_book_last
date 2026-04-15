import { PrismaClient } from '@prisma/client';

async function test() {
  const prisma = new PrismaClient();
  const now = new Date();
  const today = new Date(now);
  today.setHours(0, 0, 0, 0);

  console.log('--- Current Time Info ---');
  console.log('Now (Local):', now.toString());
  console.log('Now (ISO/UTC):', now.toISOString());
  console.log('Today Marker (Local Midnight):', today.toString());
  console.log('Today Marker (ISO/UTC):', today.toISOString());

  const bookings = await prisma.booking.findMany({
    take: 5,
    orderBy: { createdAt: 'desc' }
  });

  console.log('\n--- Recent Bookings (RAW) ---');
  bookings.forEach(b => {
    console.log(`ID: ${b.id}`);
    console.log(`  Date in DB (JS object): ${b.date.toString()}`);
    console.log(`  Date in ISO:            ${b.date.toISOString()}`);
    console.log(`  Status:                 ${b.status}`);
    console.log(`  b.date < today:         ${b.date < today}`);
    console.log(`  b.date === today:       ${b.date.getTime() === today.getTime()}`);
  });

  await prisma.$disconnect();
}

test();
