import Category from '../modules/categories/models/category.js';

const seedCategories = async () => {
  try {
    const categories = [
      { name: 'Política', description: 'Noticias relacionadas con política nacional e internacional.' },
      { name: 'Deportes', description: 'Noticias sobre deportes y eventos deportivos.' },
      { name: 'Tecnología', description: 'Noticias sobre avances tecnológicos y gadgets.' },
      { name: 'Economía', description: 'Noticias relacionadas con la economía y finanzas.' },
      { name: 'Cultura', description: 'Noticias sobre arte, música, y eventos culturales.' },
      { name: 'Salud', description: 'Noticias relacionadas con la salud y el bienestar.' },
      { name: 'Educación', description: 'Noticias sobre el sistema educativo y aprendizaje.' }
    ];

    for (const category of categories) {
      await Category.findOrCreate({
        where: { name: category.name },
        defaults: category
      });
    }

    console.log('Categories seeded successfully.');
  } catch (error) {
    console.error('Error seeding categories:', error.message);
  }
};

seedCategories();