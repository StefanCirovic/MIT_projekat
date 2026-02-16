require('dotenv').config();
const admin = require('firebase-admin');

// Inicijalizuj Firebase sa environment variable
admin.initializeApp({
  credential: admin.credential.cert({
    projectId: process.env.FIREBASE_PROJECT_ID,
    clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
    privateKey: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
  }),
});

// Obriši sve obroke iz kolekcije
async function clearMeals() {
  console.log(' Brišem sve obroke...');
  
  try {
    const snapshot = await admin.firestore().collection('meals').get();
    
    if (snapshot.empty) {
      console.log(' Nema obroka za brisanje');
      return;
    }

    const batch = admin.firestore().batch();
    
    snapshot.docs.forEach((doc) => {
      batch.delete(doc.ref);
    });

    await batch.commit();
    console.log(` Obrisano ${snapshot.size} obroka!`);
    
  } catch (error) {
    console.error(' Greška pri brisanju obroka:', error);
  }
}

clearMeals().catch(console.error);
