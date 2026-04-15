const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  try {
    const otps = await prisma.otp.findMany({
      orderBy: { updatedAt: 'desc' },
      take: 5
    });
    console.log('--- RECENT OTPS ---');
    otps.forEach(otp => {
      console.log(`Identifier: ${otp.identifier} | Code: ${otp.code} | Expires: ${otp.expiresAt}`);
    });
  } catch (e) {
    console.error(e);
  } finally {
    await prisma.$disconnect();
  }
}

main();
