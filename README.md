# SolemateIOS
## FEATURES:
* Ability to take an image and send it to AWS for identification
* Ability to upload an image from the camera roll and send it to AWS for identification
* Ability to aim the phone at a sneaker and automatic capture and send to AWS for identification
* Ability to aim the phone at a sneaker and get AR feedback that the app has captured and sent to AWS for identification
* Ability to save images taken in Solemate app to user camera roll
* Ability to have an offline saved list of sneakers recognized by Solemate 
* Ability to see description of the sneaker 
* Ability to see lowest price of the sneaker (Updated Daily)
* Ability to be redirected to buy sneaker at lowest price(Updated Daily)
* Ability to see recommended shoes based on our recommendation model
* Ability to retrieve images uploaded to our server for identification


## BUGS:
* At the moment we can only retrieve the last 11 user uploaded images  
* Sometimes the local ML model recognizes theres a shoe in the frame even though there might not be
* Sometimes the image uploaded via the local model may have the	AR feedback we display in the frame.
* Sometimes if the details call is made before the user closes the pop up or "tries again" the next upload may show the last recognized shoe for a quick second then show the actual recognized shoe

## INSTRUCTIONS: 
Note: Cannot be run on simulators, only iPhones 6s and up due to needing arm v7 for AR. 

The device will also need to be running iOS 11(preferably 11.2 but we still support 11-11.3.1)

* Open XCODE 9(9.3 preferably) select open another project from bottom right.
* Open Solemate.xcodeproj
* Update Application signing 
	1. Rename bundle Identifier to a unique id (Ex. Wang.Solemate)
	2. Change team to your personal team.
* Connect iPhone 
* Select the attached iPhone as target Device
* Run Solemate
* Allow developer permissions on device by going to General > Device Management > Developer App> Trust
* Open Solemate, you will be prompted for allowing camera permissions, say accept
* If you click camera roll it will prompt you for camera roll permissions, say accept
* If you capture an image it will ask for permission for saving to camera roll, accept if you'd like to save images you take in the app locally, deny if you rather not
