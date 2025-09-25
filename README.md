# HairStyle AI - Flutter App

An AI-powered hair styling mobile application built with Flutter that provides virtual try-on capabilities, personalized recommendations, and a social community around hair styling inspiration.

## Features

### Phase 1 - Foundation (Current)
- ✅ Modern Flutter app structure with clean architecture
- ✅ Firebase integration ready (Auth, Firestore, Storage, Analytics)
- ✅ Beautiful UI with custom theme system
- ✅ Authentication system (Email/Password, Google, Apple ready)
- ✅ Gallery with filtering and search capabilities
- ✅ Camera integration with face detection placeholder
- ✅ AI Consultant interface
- ✅ User profile management

### Phase 2 - AI Integration (Planned)
- 🔄 AI-powered hair analysis
- 🔄 Face shape detection and analysis
- 🔄 Personalized hairstyle recommendations
- 🔄 Color matching based on skin tone

### Phase 3 - AR Features (Planned)
- 🔄 AR virtual try-on capabilities
- 🔄 Real-time hairstyle overlay
- 🔄 3D hair model integration

### Phase 4 - Social Features (Planned)
- 🔄 Social sharing and community features
- 🔄 User-generated content
- 🔄 Trending hairstyles
- 🔄 User interactions (likes, comments, follows)

## Tech Stack

- **Frontend**: Flutter 3.9.2+, Dart
- **Backend**: Firebase (Auth, Firestore, Storage, Analytics)
- **State Management**: Provider
- **Camera**: Camera plugin with ML Kit face detection
- **UI**: Material Design 3 with custom theming
- **AR**: ARCore (Android) + ARKit (iOS) - Phase 2

## Project Structure

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/          # App constants and enums
│   ├── theme/             # App theme and colors
│   ├── utils/             # Utility functions
│   └── services/          # Core services (Auth, Theme)
├── features/
│   ├── auth/              # Authentication screens
│   ├── gallery/           # Gallery and hairstyle browsing
│   ├── camera/            # Camera and photo capture
│   ├── ai_consultant/     # AI analysis and recommendations
│   ├── ar_tryOn/          # AR virtual try-on (Phase 2)
│   └── profile/           # User profile management
├── shared/
│   ├── widgets/           # Reusable UI components
│   └── models/            # Data models
└── assets/
    ├── images/            # App images and icons
    └── videos/            # Video assets
```

## Getting Started

### Prerequisites

- Flutter SDK 3.9.2 or higher
- Dart 3.0 or higher
- Android Studio / VS Code with Flutter extensions
- Firebase project setup

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd hair_styling_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Enable Authentication, Firestore, Storage, and Analytics
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place them in the appropriate platform folders
   - Update `lib/firebase_options.dart` with your Firebase configuration

4. **Run the app**
   ```bash
   flutter run
   ```

### Firebase Configuration

1. **Authentication**
   - Enable Email/Password authentication
   - Enable Google Sign-In (optional)
   - Enable Apple Sign-In (optional)

2. **Firestore Database**
   - Create collections: `users`, `hairstyles`, `userGalleries`
   - Set up security rules

3. **Storage**
   - Configure storage rules for image uploads
   - Set up folders: `profile_images/`, `hairstyle_images/`, `try_on_images/`

## Development Phases

### Phase 1: Foundation (Weeks 1-3) ✅
- [x] Project setup and architecture
- [x] UI/UX design system
- [x] Authentication system
- [x] Basic navigation and screens
- [x] Data models and services

### Phase 2: AI Integration (Weeks 4-8) 🔄
- [ ] AI model integration
- [ ] Face detection and analysis
- [ ] Personalized recommendations
- [ ] Color matching algorithms

### Phase 3: AR Features (Weeks 9-14) 📋
- [ ] AR framework setup
- [ ] 3D hair model integration
- [ ] Virtual try-on functionality
- [ ] Real-time overlay system

### Phase 4: Social Features (Weeks 15-20) 📋
- [ ] Social sharing
- [ ] User-generated content
- [ ] Community features
- [ ] Content moderation

## Key Features Implementation

### Authentication
- Email/Password authentication
- Social login (Google, Apple) - ready for implementation
- User profile management
- Secure data handling

### Gallery System
- Staggered grid layout for hairstyles
- Advanced filtering (category, difficulty, length)
- Search functionality
- Like and save features

### Camera Integration
- Real-time camera preview
- Face detection overlay
- Photo capture with metadata
- Image processing pipeline

### AI Consultant
- Face shape analysis
- Hair type recognition
- Personalized recommendations
- Color matching suggestions

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support, email support@hairstyle-ai.com or join our Discord community.

## Roadmap

- [ ] **Q1 2024**: Complete Phase 1 foundation
- [ ] **Q2 2024**: AI integration and face analysis
- [ ] **Q3 2024**: AR virtual try-on features
- [ ] **Q4 2024**: Social features and community
- [ ] **Q1 2025**: Advanced AI features and monetization

---

**Note**: This is a development version. Some features are placeholders and will be implemented in future phases.