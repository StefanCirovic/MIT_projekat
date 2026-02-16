const admin = require('firebase-admin');


async function addAdminRoles() {
  console.log(' Proveravam postojeće studente...');
  
  try {
    const studentsSnapshot = await admin.firestore()
      .collection('students')
      .get();

    if (studentsSnapshot.empty) {
      console.log(' Nema studenata u bazi');
      return;
    }

    const batch = admin.firestore().batch();
    let updatedCount = 0;

    studentsSnapshot.docs.forEach((doc) => {
      const data = doc.data();
      
    if (!data.role) {
        console.log(` Dodajem role za ${data.firstName} ${data.lastName} (${doc.id})`);
        
        batch.update(doc.ref, {
          role: 'user', 
          ...data 
        });
        updatedCount++;
      } else {
        console.log(` ${data.firstName} ${data.lastName} već ima role: ${data.role}`);
      }
    });

    if (updatedCount > 0) {
      console.log(` Čuvam ${updatedCount} izmena...`);
      await batch.commit();
      console.log(` Uspešno dodato role polje za ${updatedCount} korisnika`);
    } else {
      console.log(' Svi korisnici već imaju role polje');
    }

  } catch (error) {
    console.error(' Greška:', error);
  }
}


async function createTestAdmin() {
  console.log('Kreiram test admin korisnika...');
  
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

    console.log(' Test admin kreiran: 9999999 / admin123');
    
  } catch (error) {
    console.error(' Greška pri kreiranju admina:', error);
  }
}


async function main() {
    console.log(' Pokrećem migraciju admin role...');
  
  
  await addAdminRoles();
  
 
  await createTestAdmin();
  
  console.log(' Migracija završena!');
}

main().catch(console.error);