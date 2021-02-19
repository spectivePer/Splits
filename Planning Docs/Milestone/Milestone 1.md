# Checklist
## UI Designs
These designs do not need to be pixel perfect, and in fact they shouldn't be. 
Use a whiteboard and take pictures, or better yet use a tool like Balsamiq that lets you draw sketch / wireframe designs easily.


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
- Transaction Model: will facilitate interactions between user to user transactions and the controller
- User Model: will facilitate interactions between the user table and the controller
- Collection Model: will facilitate interactions between users to collections and the controller
   - This will be the model we base off of splitting certain items between a group AKA a collection

## Server Support
Server will be based in Firebase Functions
- Transaction API: this api will be based off of which 3rd party library we choose for transactions
   - Examples: Pay, Request, Split, etc.. 
- User API: this api will encompass login, authentication, updating and getting user's information and will also use 3rd party authentication such as Google, Facebook, Apple and other sign in options
   - Examples: Login, Authenticate/Verify, UpdateName, GetUser(id) etc..
- Collection API: this api will encompass interactions between collections and will be using the Transactions API to facilitate these interactions
   - Examples: addToCollection(userID), createCollection(userIDList), deleteCollection(collectionID) etc...

## View Controllers
- Please include how you plan to navigate to / from each ViewController and any protocols / delegates / variables you plan to use for ViewController / 
   ViewController communication
   
- Launch, login, verification, home, settings, add split, scan receipt, history, purchase summary


## Project Timeline
A list of approximately week long tasks and a timeline of when each of them will be done
- Thursday, 2/11/2021 Topic Research
- Friday, 2/19/2021   Finish planning
- Monday 2/22/2021    Testing 1
- Friday, 2/26/2021   Implementation of all view controllers listed
- Monday, 3/1/2021    Testing 2
- Friday, 3/5/2021    Implementation from the testing feedback
- Monday, 3/8/2021    Testing 3
- Thursday, 3/11/2021 Implementation from the testing feedback + Ship to App Store

## Trello Board
https://trello.com/b/Ez0aGlsI/splits


## Testing Plan
We plan to have three testing phases using Google Forms.

### Phase 1
- Do you own a bill splitting app? 
   * Yes: what is the name of the bill splitting app you have installed? what do you like about your bill spllitting app? what features would you like it to have? how often do you use your bill splitting app during quaratine?
   * No: why do you not use a bill splitting app?
- Do you own an iPhone?
   * Yes: check which payment apps you use: Google Pay, Apple Pay, Venmo, Square Cash, Paypal, Other

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
