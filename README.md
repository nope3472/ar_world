# AR Furniture World 🌍

**AR Furniture World** is an innovative Augmented Reality (AR) app built with Flutter using the `ar_flutter_plugin`. The app allows users to upload photos to Firebase, automatically removes the background of the photos using the [remove.bg API](https://www.remove.bg/pricing), and provides the ability to dynamically adjust the size, position, and rotation of objects in an AR environment.

## Features ✨

- **Augmented Reality (AR)**: Leverage Flutter’s `ar_flutter_plugin` to display objects in AR space, allowing immersive 3D experiences.
- **Firebase Integration**: Users can seamlessly upload photos to Firebase for storage and processing.
- **Background Removal**: Automatically remove the background from uploaded images using the [remove.bg API](https://www.remove.bg/pricing), turning any photo into a clean, background-free object for AR placement.
- **Object Manipulation**: Users can dynamically resize, rotate, and move objects in real-time within the AR space.
- **Interactive UI**: A user-friendly interface to upload images, manage AR objects, and control their placement in the real world.

## Getting Started 🚀

### Prerequisites

- Flutter SDK installed on your local machine.
- Firebase project setup with Firestore and Storage.
- [remove.bg API Key](https://www.remove.bg/pricing) for background removal.
- A device that supports AR (iOS or Android).

### Installation

1. **Clone the repository**:

   ```bash
   git clone https://github.com/yourusername/ar-furniture-world.git
   cd ar-furniture-world
Install dependencies:

bash
Copy code
flutter pub get
Firebase Setup:

Follow the Firebase setup instructions for both Android and iOS.
Add your google-services.json (for Android) and GoogleService-Info.plist (for iOS) files to the respective directories.
Add remove.bg API key:

Create an account at remove.bg and get your API key.
Add the API key in your app by including it in a configuration file or as a constant in your code.
Run the app:

bash
Copy code
flutter run
Usage 🛠️
## Screenshots 📸



## Demo Video 🎥



[![Watch the video](https://img.youtube.com/vi/your-video-id/maxresdefault.jpg)](https://www.youtube.com/watch?v=your-video-id)

## Built With 🛠️

- [Flutter](https://flutter.dev/) - UI framework for building the app.
- [ar_flutter_plugin](https://pub.dev/packages/ar_flutter_plugin) - Plugin for adding AR functionalities.
- [Firebase](https://firebase.google.com/) - Backend services for storage and data.
- [remove.bg API](https://www.remove.bg/pricing) - API for automatic background removal.

## Future Improvements 🚀

- Add support for more 3D models in AR.
- Enhance object manipulation with gesture support.
- Integrate AI for better image/object placement in AR space.
