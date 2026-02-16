const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json"); // ime tvog fajla

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});


// Kreiraj početne obroke za menzu
async function addInitialMeals() {
  console.log(' Dodajem početne obroke...');
  
  try {
    const meals = [
      // Doručak
      {
        name: 'Omlet sa sirom',
        price: 120,
        calories: 420,
        description: 'Svež omlet sa domaćim sirom',
        mealTime: 'breakfast',
        type: 'main',
        isAvailable: true,
        image: ''
      },
      {
        name: 'Kašica sa mlekom',
        price: 80,
        calories: 280,
        description: 'Pšenična kašica sa toplim mlekom',
        mealTime: 'breakfast',
        type: 'main',
        isAvailable: true,
        image: ''
      },
      {
        name: 'Čaj',
        price: 40,
        calories: 20,
        description: 'Crni ili biljni čaj',
        mealTime: 'breakfast',
        type: 'drink',
        isAvailable: true,
        image: ''
      },
      {
        name: 'Kafa',
        price: 60,
        calories: 30,
        description: 'Espresso ili mlečna kafa',
        mealTime: 'breakfast',
        type: 'drink',
        isAvailable: true,
        image: ''
      },
      {
        name: 'Sok od pomorandže',
        price: 80,
        calories: 110,
        description: 'Svež sok od pomorandže',
        mealTime: 'breakfast',
        type: 'drink',
        isAvailable: true,
        image: ''
      },
      
      // Ručak
      {
        name: 'Piletina sa pirinčem',
        price: 180,
        calories: 650,
        description: 'Pečena piletina sa belim pirinčem',
        mealTime: 'lunch',
        type: 'main',
        isAvailable: true,
        image: ''
      },
      {
        name: 'Gulaš sa mesom',
        price: 200,
        calories: 720,
        description: 'Tradicionalni gulaš sa junetinom',
        mealTime: 'lunch',
        type: 'main',
        isAvailable: true,
        image: ''
      },
      {
        name: 'Punjene paprike',
        price: 190,
        calories: 680,
        description: 'Paprike punjene mesnim filom',
        mealTime: 'lunch',
        type: 'main',
        isAvailable: true,
        image: ''
      },
      {
        name: 'Krompir sa lukom',
        price: 100,
        calories: 350,
        description: 'Pečen krompir sa crnim lukom',
        mealTime: 'lunch',
        type: 'main',
        isAvailable: true,
        image: ''
      },
      {
        name: 'Salata od povrća',
        price: 80,
        calories: 120,
        description: 'Sveža salata sa povrćem sezone',
        mealTime: 'lunch',
        type: 'salad',
        isAvailable: true,
        image: ''
      },
      {
        name: 'Kupus salata',
        price: 60,
        calories: 80,
        description: 'Kiseli kupus sa peršunom',
        mealTime: 'lunch',
        type: 'salad',
        isAvailable: true,
        image: ''
      },
      {
        name: 'Jogurt',
        price: 70,
        calories: 150,
        description: 'Prirodni jogurt',
        mealTime: 'lunch',
        type: 'dessert',
        isAvailable: true,
        image: ''
      },
      {
        name: 'Voćna salata',
        price: 90,
        calories: 180,
        description: 'Sveže voće sezonsko',
        mealTime: 'lunch',
        type: 'dessert',
        isAvailable: true,
        image: ''
      },
      {
        name: 'Sok od jabuke',
        price: 70,
        calories: 100,
        description: '100% sok od jabuke',
        mealTime: 'lunch',
        type: 'drink',
        isAvailable: true,
        image: ''
      },
      {
        name: 'Mineralna voda',
        price: 50,
        calories: 0,
        description: 'Prirodna mineralna voda',
        mealTime: 'lunch',
        type: 'drink',
        isAvailable: true,
        image: ''
      },
      
      // Večera
      {
        name: 'Riblja čorba',
        price: 160,
        calories: 420,
        description: 'Vrela riblja čorba sa povrćem',
        mealTime: 'dinner',
        type: 'main',
        isAvailable: true,
        image: ''
      },
      {
        name: 'Pljeskavica',
        price: 220,
        calories: 780,
        description: 'Klasična pljeskavica sa lukom',
        mealTime: 'dinner',
        type: 'main',
        isAvailable: true,
        image: ''
      },
      {
        name: 'Pasta sa sirom',
        price: 170,
        calories: 620,
        description: 'Italijanska pasta sa kačkavaljem',
        mealTime: 'dinner',
        type: 'main',
        isAvailable: true,
        image: ''
      },
      {
        name: 'Pomfri',
        price: 120,
        calories: 450,
        description: 'Hrskavi pomfri',
        mealTime: 'dinner',
        type: 'salad',
        isAvailable: true,
        image: ''
      },
      {
        name: 'Šopska salata',
        price: 110,
        calories: 200,
        description: 'Klasična šopska salata',
        mealTime: 'dinner',
        type: 'salad',
        isAvailable: true,
        image: ''
      },
      {
        name: 'Palacinke sa džemom',
        price: 100,
        calories: 320,
        description: 'Slatke palacinke sa domaćim džemom',
        mealTime: 'dinner',
        type: 'dessert',
        isAvailable: true,
        image: ''
      },
      {
        name: 'Kolač',
        price: 80,
        calories: 280,
        description: 'Domaći kolač dana',
        mealTime: 'dinner',
        type: 'dessert',
        isAvailable: true,
        image: ''
      },
      {
        name: 'Čaj',
        price: 40,
        calories: 20,
        description: 'Razni vrste čaja',
        mealTime: 'dinner',
        type: 'drink',
        isAvailable: true,
        image: ''
      },
      {
        name: 'Sok',
        price: 70,
        calories: 100,
        description: 'Razni vrste sokova',
        mealTime: 'dinner',
        type: 'drink',
        isAvailable: true,
        image: ''
      }
    ];

    // Dodaj obroke u batch operaciji
    const batch = admin.firestore().batch();
    const mealsRef = admin.firestore().collection('meals');

    meals.forEach((meal, index) => {
      const docRef = mealsRef.doc(); // Automatski generiši ID
      batch.set(docRef, {
        ...meal,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        id: docRef.id
      });
    });

    await batch.commit();
    console.log(` Uspešno dodato ${meals.length} obroka!`);
    
  } catch (error) {
    console.error('Greška pri dodavanju obroka:', error);
  }
}

addInitialMeals().catch(console.error);
