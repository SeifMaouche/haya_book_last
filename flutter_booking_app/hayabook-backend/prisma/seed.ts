import { PrismaClient } from '@prisma/client'
import process from 'process'
const prisma = new PrismaClient()

async function main() {
  console.log('Seed: Cleaning existing categories...')
  await prisma.category.deleteMany({})

  const categories = [
    { name: 'Coiffure & Esthétique', icon: 'face', description: 'Coiffure, maquillage et soins de beauté premium.' },
    { name: 'Barber Shop', icon: 'content_cut', description: 'Services de coiffure et barbe pour hommes.' },
    { name: 'Soutien Scolaire', icon: 'school', description: 'Cours de soutien et aide aux devoirs pour tous les niveaux.' },
    { name: 'Plomberie & Chauffage', icon: 'plumbing', description: 'Installation et réparation de plomberie et chauffage.' },
    { name: 'Réparation Électroménager', icon: 'settings_suggest', description: 'Maintenance de machines à laver, frigos et fours.' },
    { name: 'Installation Climatisation', icon: 'ac_unit', description: 'Installation et recharge de climatiseurs.' },
    { name: 'Garde d’Enfants', icon: 'child_care', description: 'Baby-sitting et garde d’enfants à domicile.' },
    { name: 'Organisation de Fêtes', icon: 'celebration', description: 'Mariages, anniversaires et événements spéciaux.' },
    { name: 'Photographie & Vidéo', icon: 'camera_alt', description: 'Capturez vos moments précieux avec des professionnels.' },
    { name: 'Soins à Domicile', icon: 'medical_services', description: 'Infirmiers et kinésithérapeutes à votre service.' },
    { name: 'Mécanique Auto', icon: 'build', description: 'Réparation et entretien de véhicules.' },
    { name: 'Lavage Auto Mobile', icon: 'local_car_wash', description: 'Nettoyage complet de votre voiture chez vous.' },
    { name: 'Déménagement', icon: 'local_shipping', description: 'Transport et déménagement sécurisé de vos biens.' },
    { name: 'Ménage & Nettoyage', icon: 'cleaning_services', description: 'Services de nettoyage pour maisons et bureaux.' },
  ]

  console.log('Seed: Starting category population (Algerian Market)...')

  for (const cat of categories) {
    await prisma.category.create({
      data: {
        name: cat.name,
        icon: cat.icon,
        description: cat.description,
      },
    })
  }

  console.log('Seed: Localized categories seeded successfully.')
}

main()
  .catch((e) => {
    console.error(e)
    process.exit(1)
  })
  .finally(async () => {
    await prisma.$disconnect()
  })
