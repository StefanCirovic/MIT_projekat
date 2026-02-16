const admin = require('firebase-admin');

async function createAdmin() {
  console.log('Kreiram admin nalog...');
  
  try {
    const adminData = {
      cardNumber: '9999999',
      firstName: 'Admin',
      lastName: 'Test',
      email: 'admin@test.com',
      pinHash: 'a665a45920422f9d417e4867efdc4fb5a2a013c6', // 'admin123'
      role: 'admin',
      status: 'budget',
      isActive: true,
      balance: 10000,
      index: 'IT99-2023',
      ziroRacun: '123456789',
      monthlyLimitBreakfast: 50,
      monthlyLimitLunch: 100,
      monthlyLimitDinner: 100,
      onCardBreakfast: 0,
      onCardLunch: 0,
      onCardDinner: 0
    };

    await admin.firestore()
      .collection('students')
      .doc('9999999')
      .set(adminData);

    console.log('Admin kreiran: 9999999 / admin123');
    
  } catch (error) {
    console.error('Greška:', error);
  }
}

createAdmin().catch(console.error);
