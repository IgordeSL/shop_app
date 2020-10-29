# ShopApp

![App logo](/android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_round.png)

Flutter project developed during an online course.

[How to install Flutter](https://flutter.dev/docs/get-started/install) 

This project contains:
* Navigation by named routes
* State management using the Provider package
* Communication with a back-end (Firebase) using HTTP requests
* Implicit and explicit animations

## How to run this project
To execute this project, it is necessary to create a project in Firebase, which will be used as a back-end by the application.
You will also need to add the following features/settings to your Firebase project:
* Add a Realtime Database
* In the Realtime Database
    * Import the `products.json` file from the `mock-data` folder
    * Add the following configuration in the rules tab
    ```JSON
    {
      "rules": {
        ".read": "auth != null",
        ".write": "auth != null",
        "products": {
            ".indexOn": ["creatorId"]
        }
      }
    }
    ```
* Add email and password authentication

In the Flutter project it will be necessary to create a file called `env.dart` inside the `lib` folder.
In this file paste the following code:
```dart
const environment = {
  'firebaseWebAPIKey': 'yourWebAPIKey',
  'firebaseUrl': 'yourFirebaseUrl',
};
```
* Replace `yourWebAPIKey` with the key that can be found in your Firebase project settings
* Replace `yourFirebaseUrl` with the URL of your Realtime Database

**Flutter 1.22.1**
