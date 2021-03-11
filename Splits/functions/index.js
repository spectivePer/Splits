const functions = require("firebase-functions");
const admin = require('firebase-admin');

admin.initializeApp();

const twilio = require("twilio");

const accountSid = functions.config().twilio.sid;
const authToken = functions.config().twilio.token;

const client = new twilio(accountSid, authToken);

const twilioNumber = '+18064547805'  // twilio phone number


exports.textStatus = functions.https.onCall(async (data, context) =>{
  var phoneNumber = data.phoneNumber;
  const amount = data.totalAmount;
  const isEqual = data.isEqual;
  var messageBody = amount;
  var newMessage = data.messageBody;
  let reciever = data.recieverName;
  let recievedAmt = data.totalAmt;
  console.log("phone number is " + phoneNumber)
//   if (phoneNumber.indexOf("+") !== -1){
//       phoneNumber = "+1" + phoneNumber 
//   }
    if (isEqual === "true") {
        if (data.isOwed === "true"){
            messageBody = reciever + " has requested $" + amount
        }
        else if(data.isOwed === "false"){
            messageBody = "You will get " + amount + " from each participant."
        }
    }else if (isEqual === "false"){
        if (data.isOwed === "true"){
            messageBody = reciever + " has requested " + recievedAmt + ". Here is a summary of your bill: \n" + newMessage
        }
        else if (data.isOwed === "false"){
            messageBody = "you will get recieve " + amount + " from the users." 
    }
}
    const textMessage = {
        body: messageBody,
        to: phoneNumber,
        from: twilioNumber
      }

  return client.messages.create(textMessage)
})


// exports.createStripeCustomer = functions.https.onCall(async (data, context) => {
//   const email = data.email;
//   const username = data.username;
//   const customer = await stripe.customers.create({
//       email: email,
//   });
//   console.log('new customer created: ', customer.id)
//   return {
//       customer_id: customer.id
//   }
// });

// exports.createCharge = functions.https.onCall(async (data, context) => {

//   const customerId = data.customerId;
//   const totalAmount = data.total;
//   const idempotency = data.idempotency;
//   const uid = context.auth.uid

//   if (uid === null) {
//       console.log('Illegal access attempt due to unauthenticated user');
//       throw new functions.https.HttpsError('permission-denied', 'Illegal access attempt.')
//   }

//   return stripe.charges.create({
//       amount: totalAmount,
//       currency: 'usd',
//       customer: customerId
//   }, {
//       idempotency_key: idempotency
//   }).then( customer => {
//       return customer
//   }).catch( err => {
//       console.log(err);
//       throw new functions.https.HttpsError('internal', 'Unable to create charge')
//   });
// })

// exports.createEphemeralKey = functions.https.onCall(async (data, context) => {
//   const customerId = data.stripeId;
//   const stripeVersion = data.stripe_version;
//   // const uid = context.auth.uid;

//   // if (uid === null){
//   //   console.log("illegal access attempt due to unauthenticated user");
//   //   throw new functions.https.HttpsError('permission-denied', 'Illegal access attempt')
//   // }
//   return stripe.ephemeralKeys.create(
//     {customer_id: customerId},
//     {stripe_version: stripeVersion}
//   ).then((key) => {
//       return key
//   })
//   // }).catch((err) => {
//   //     console.log(err)
//   //     throw new functions.https.HttpsError('internal','Unable to create epheremal key.')
//   // })
// })

// exports.createConnectAccount = functions.https.onCall( async (data, context) => {
  
//   // var email = data.email
//   var response = {}
//   stripe.accounts.create(
//     {
//       type: 'express',
//       country: 'US',
//       requested_capabilities: [
//         'transfers',
//       ],
//       business_type: 'individual',
//     },
//       function(err, account) {
//         if (err) {
//           console.log("Couldn't create stripe account: " + err)
//           return
//       }
//       console.log("ACCOUNT: " + account.id)
//       response.body = {success: account.id}
//       return account.id
//     }
//   );
// });

// exports.createStripeAccountLink = functions.https.onRequest((req, res) => {
//   var data = req.body
//   var accountID = data.accountID
//   var response = {}
//   stripe.accountLinks.create({
//     account: accountID,
//     failure_url: 'https://example.com/failure',
//     success_url: 'https://example.com/success',
//     type: 'custom_account_verification',
//     collect: 'eventually_due',
//   }, function(err, accountLink) {
//     if (err) {
//       console.log(err)
//       response.body = {failure: err}
//       return res.send(response)
//     }
//   console.log(accountLink.url)
//     response.body = {success: accountLink.url}
//     return res.send(response)
//   });
// });

// const currency = functions.config().stripe.currency || 'USD';

// Create and Deploy Your First Cloud Functions
// https://firebase.google.com/docs/functions/write-firebase-functions

const functionConfig = () => {
    const fs = require('fs');
    return JSON.parse(fs.readFileSync('.env.json'));
};

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
