### Summary

Splits is an app that conveniently splits a bill, receipt, or payment among two or more people. Splits can scan your receipts importing item desc and prices automatically, and can refund your split host through ApplePay.

### Trello Board Link

[https://trello.com/b/Ez0aGlsI/splits](https://trello.com/b/Ez0aGlsI/splits)

### Major Project Update
Will not be pursuing 250 DAU anymore

### List of user experience cases
- New user with no splits: open to new split vc
- New user with previous/pending splits: open to history vc, import previous and pending splits
- Non app user: text the amount the user owes the requestor
- App user with no splits: open to new split vc
- App user with previous/pending splits: open to history vc


### Completed Tasks
Jocelyn: 
  split evenly with manual input,
  take receipt pictures

Paul: Login flow is complete

Keith: Can add friends in a group to split with

Shaumik: Completed UI for adding payment method.


### Commit History
[Paul] Fixed the Login Flow -> Login process should be complete

[Jocelyn] [Rough newSplit vc layout](https://github.com/ECS189E/project-w21-splits/tree/cd46710246286602f4b1597eba23a75794a2cf95)

[Jocelyn] [Split evenly with manual input](https://github.com/ECS189E/project-w21-splits/tree/24db720366fb8ad7e6bec647971e64183c128c5b)

[Jocelyn] [Rough split unevenly vc layout](https://github.com/ECS189E/project-w21-splits/tree/bcb57c550c27bea7fb46a2f7deaa2fef4045ab90)

[Keith] [Adding participants based on friends](https://github.com/ECS189E/project-w21-splits/commit/48faf2c96b7287972686f0ec3036bd881a0be4ba)

[Jocelyn] [Take receipt pictures](https://github.com/ECS189E/project-w21-splits/tree/4bde7bf5ba141af8de29cf0a734a3f7e7796dc5f)


### In-progress Tasks
Jocelyn: Apple OCR

Paul: Working on adding contacts, UI layout (Last), HomeView, and Settings.

Keith: Friends feature and search bar when searching for friends

Shaumik: Fix errors with mutating attributes in Firebase realtime database.

### Notes
Jocelyn plan:
1. Apple OCR
2. NewSplit UI

[Tutorial for receipt scanning link](https://makeapppie.com/2014/12/04/swift-swift-using-the-uiimagepickercontroller-for-a-camera-and-photo-library/)

Keith:
1. Implement Add Friend feature with phone number 
2. For now, to test adding people to a group, we manually update the database
