# Checklist
## UI Designs and Wireframe Flow
https://xd.adobe.com/view/b888d80d-efd9-40ea-b771-1bd90dd750dd-eddb/


[Wireframe](Pictures/Wireframe.png)


## Third Party Libraries
- Server support: [Firebase](https://firebase.google.com/docs/functions)
- login/auth: [Facebook](https://developers.facebook.com/docs/facebook-login/ios/)
, [Apple](https://developer.apple.com/documentation/authenticationservices/implementing_user_authentication_with_sign_in_with_apple)
, [Google](https://developers.google.com/identity/sign-in/ios)
- Move money: [Stripe](https://stripe.com)
/ [Braintree](https://www.braintreepayments.com)
/ [Dwollo](https://www.dwolla.com)
- Showing transactions: [Plaid](https://plaid.com)

## Models
The database we plan to use will be served on Firebase Cloudstore which will host tables of each category below:
- Transaction Model: will facilitate interactions between user to user transactions and the controller
- User Model: will facilitate interactions between the user table and the controller
- Collection Model: will facilitate interactions between users to collections and the controller
   - This will be the model we base off of splitting certain items between a group AKA a collection

## Server Support
Server will be based in Firebase Functions
- Transaction API: this api will be based off of which 3rd party library we choose for transactions
   - Examples: Pay, Request, Split, etc.. 
- User API: this api will encompass login, authentication, updating and getting user's information and will also use 3rd party authentication such as Google, Facebook, Apple and other sign in options
   - Examples: Login, Authenticate/Verify, UpdateName(userID, newName), GetUserInformation(userId), addFriend(userID) etc..
- Collection API: this api will encompass interactions between collections and will be using the Transactions API to facilitate these interactions
   - Examples: addToCollection(userID), createCollection(userIDList), deleteCollection(collectionID) etc...

## View Controllers
- View Controllers
   - Launch: appears when the app opens, navigates to login or register vc
   - Login: appears when login button is clicked on launch vc, navigates to home vc
   - Register: appears when register button is clicked on launch vc, navigates to verification vc
   - Verification: appears after register vc, navigates to home vc
   - Home: appears after verification/login vc, navigates to paymentSplit, historySplit, and newSplit vcs
   - PaymentSplit: appears when you click on a split on the home vc that has not been paid, navigates back to home vc
   - HistorySplit: appears when you click on a split on the home vc that was previously paid, navigates back to home vc
   - NewSplit: appears when you click on the create button on the home vc, navigates to the home vc
   - OCR: appears when you click on the camera icon on the newSplit vc, navigates back to the newSplit vc
- Delegates & Protocols
   - UITextFieldDelegate: for back spacing and typing in money value
   - UITableViewDelegate: for displaying the history of transactions made


## Project Timeline
A list of approximately week long tasks and a timeline of when each of them will be done
- Thursday, 2/11/2021 Topic Research
- Friday, 2/19/2021   Finish planning
- Monday 2/22/2021    Testing 1
- Friday, 2/26/2021   Implementation of all view controllers listed and APIs
- Monday, 3/1/2021    Testing 2
- Friday, 3/5/2021    Implementation from the testing feedback
- Monday, 3/8/2021    Testing 3
- Thursday, 3/11/2021 Implementation from the testing feedback + Ship to App Store

## Trello Board
https://trello.com/b/Ez0aGlsI/splits


## Testing Plan
We plan to have three testing phases using Google Forms.

### Phase 1 Results
Total Responses: 34

Who do you split bills, receipts, or payments with? Check all that apply.
- 94.1% Friends
- 64.7% Roommates
- 38.2% Family
- 35.3% Coworkers

When do you split a bill, receipt, or payment? Check all that apply.
- 97.1% Food
- 76.5% Housing (Rent/Utilities)
- 64.7% Entertainment
- 44.1% Transportation

How often do you split payments during quaratine? [Question added late, only 5 responses]
- 40% Occasionally (1-2 times/month)
- 20% Rarely/Never
- 20% Often (3-4 times/week)
- 20% Always (5+ times/week)

Would you prefer making payments through Splits?
- 50% No, pay in another app
- 47.1% Yes, pay in app
- 2.9% Depends

Do you own an iPhone?
- 73.5% Yes
- 26.5% No

[iPhone user only] Which payment apps do you use? Check all that apply 
- 100% Venmo
- 56% Apple Pay
- 56% Paypal
- 56% Zelle
- 20% Google Pay
- 8% Square Cash

Do you currently own an expense splitting app?
- 91.2% No
- 8.8% Yes

Users who don't have a splitting app installed don't like the UI or didn't know that splitting apps existed.
Others are too lazy, estimate splits and then venmo, or use a calculator (venmo can now multiply, divide, add, and subtract).
Finally, there are users who don't believe they have a need for a splitting app or believe that splitting apps are inconvenient.

Users who have splitting apps installed use Zoom (2 people) or Splitwise (1 person).
They like the convenience, ease of use, and quick money transfer without cash.
They would like finance tracking and an option to make payments in the app.


### Phase 2
- From a scale of 1-5 (1 being easy, 5 being hard), how easy was it to signup?
- From a scale of 1-5, how easy was it to create a new split by manually inputting a number?
- From a scale of 1-5, how easy was it to create a new split using OCR function?
- What additional features would you like to see in the app?
- What can we improve on?
- Would you use this app? Y/N Why?

### Phase 3
Ask questions based off of things we changed from phase 2 feedback
- What can we improve on?
- Would you use this app? Y/N Why?
