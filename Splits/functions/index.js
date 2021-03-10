const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

const stripe = require("stripe")(functions.config().stripe.secret_test_key);


exports.createStripeCustomer = functions.https.onCall(async (data, context) => {
  const email = data.email;
  const username = data.username;
  const customer = await stripe.customers.create({
      email: email,
  });
  console.log('new customer created: ', customer.id)
  return {
      customer_id: customer.id
  }
});

exports.createCharge = functions.https.onCall(async (data, context) => {

  const customerId = data.customerId;
  const totalAmount = data.total;
  const idempotency = data.idempotency;
  const uid = context.auth.uid

  if (uid === null) {
      console.log('Illegal access attempt due to unauthenticated user');
      throw new functions.https.HttpsError('permission-denied', 'Illegal access attempt.')
  }

  return stripe.charges.create({
      amount: totalAmount,
      currency: 'usd',
      customer: customerId
  }, {
      idempotency_key: idempotency
  }).then( customer => {
      return customer
  }).catch( err => {
      console.log(err);
      throw new functions.https.HttpsError('internal', 'Unable to create charge')
  });
})

exports.createEphemeralKey = functions.https.onCall(async (data, context) => {
  const customerId = data.stripeId;
  const stripeVersion = data.stripe_version;
  // const uid = context.auth.uid;

  // if (uid === null){
  //   console.log("illegal access attempt due to unauthenticated user");
  //   throw new functions.https.HttpsError('permission-denied', 'Illegal access attempt')
  // }
  return stripe.ephemeralKeys.create(
    {customer_id: customerId},
    {stripe_version: stripeVersion}
  ).then((key) => {
      return key
  // }).catch((err) => {
  //     console.log(err)
  //     throw new functions.https.HttpsError('internal','Unable to create epheremal key.')
  // })
})

exports.createConnectAccount = functions.https.onCall( async (data, context) => {
  // var data = req.body
  // var email = data.email
  var response = {}
  stripe.accounts.create(
    {
      type: 'custom',
      country: 'US',
      requested_capabilities: [
        'transfers',
      ],
      business_type: 'individual',
    },
      function(err, account) {
        if (err) {
          console.log("Couldn't create stripe account: " + err)
          return
      }
      console.log("ACCOUNT: " + account.id)
      response.body = {success: account.id}
      return account.id
    }
  );
});

exports.createStripeAccountLink = functions.https.onRequest((req, res) => {
  var data = req.body
  var accountID = data.stripeId
  var response = {}
  stripe.accountLinks.create({
    account: accountID,
    failure_url: 'https://example.com/failure',
    success_url: 'https://example.com/success',
    type: 'custom_account_verification',
    collect: 'eventually_due',
  }, function(err, accountLink) {
    if (err) {
      console.log(err)
      response.body = {failure: err}
      return res.send(response)
    }
  console.log(accountLink.url)
    response.body = {success: accountLink.url}
    return res.send(response)
  });
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

