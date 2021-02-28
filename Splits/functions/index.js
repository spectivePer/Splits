const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

const stripe = require("stripe")(functions.config().stripe.secret_test_key);

exports.createStripeCustomer = functions.firestore.document('users/{uid}').onCreate(async (snap, context) => {
  const data = snap.data();
  const email = snap.email();

  const customer = await stripe.customers.create({ email: email })
  return admin.firestore().collection('users').doc(data.id).update({ stripeId: customer.id})

});




// const currency = functions.config().stripe.currency || 'USD';

// Create and Deploy Your First Cloud Functions
// https://firebase.google.com/docs/functions/write-firebase-functions
// const functionConfig = () => {
//     const fs = require('fs');
//     return JSON.parse(fs.readFileSync('.env.json'));
// };

// exports.getStripeSecretKey =  functions.https.onCall((data, context) => {
//     return {
//         stripesecretkeys: functionConfig().stripesecretkeys.key
//     };
// })

// exports.createStripeCustomer = functions.auth.user().onCreate((user) => {
//   return stripe.customers.create({
//     email: user.email,
//   }).then((customer) => {
//     return admin.database()
//         .ref(`/stripe_customers/${user.uid}/customer_id`).set(customer.id);
//   });
// });

