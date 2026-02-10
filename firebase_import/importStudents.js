const admin = require('firebase-admin');
const fs = require('fs');

admin.initializeApp({
  credential: admin.credential.cert(require('./serviceAccountKey.json')),
});

const db = admin.firestore();
const students = JSON.parse(fs.readFileSync('./student_import.json', 'utf8')).students;

async function importStudents() {
  const batch = db.batch();
  const studentsRef = db.collection('students');

  let i = 0;
  for (const [cardNumber, data] of Object.entries(students)) {
    batch.set(studentsRef.doc(cardNumber), {
      cardNumber: data.cardNumber,
      firstName: data.firstName,
      lastName: data.lastName,
      index: data.index,
      email: data.email || '',
      pinHash: data.pinHash || '',
      role: data.role || 'student',
      status: data.status || 'budzet',
      isActive: data.isActive !== undefined ? data.isActive : true,
      balance: data.balance || 0,
      ziroRacun: data.ziroRacun || '',
      monthlyLimitBreakfast: data.monthlyLimitBreakfast || 30,
      monthlyLimitLunch: data.monthlyLimitLunch || 30,
      monthlyLimitDinner: data.monthlyLimitDinner || 30,
      onCardBreakfast: data.onCardBreakfast || 0,
      onCardLunch: data.onCardLunch || 0,
      onCardDinner: data.onCardDinner || 0,
    });

    if (++i % 500 === 0) {
      await batch.commit();
      batch.reset();
    }
  }

  if (i % 500 !== 0) await batch.commit();

  console.log(`Importovano ${i} studenata.`);
}

importStudents().catch(console.error);
