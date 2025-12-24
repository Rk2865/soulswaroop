# Soulswaroop - Mental Wellness App

Soulswaroop is a comprehensive mental wellness application designed to help users achieve inner peace and self-awareness. Built with Flutter and powered by AI, it offers a personalized experience for mental health support.

## Features

- **AI-Powered Assistant**: Integrated with Google Gemini AI to provide intelligent, conversational mental health support and guidance.
- **Mental Health Assessment**: Includes personality tests (such as MBTI and Enneagram) to help users understand themselves better.
- **Meditation & Relaxation**: Audio integration for meditation tracks and soothing sounds to aid in relaxation.
- **User Management**: Secure authentication and profile management using Firebase.
- **Interactive Dashboard**: A user-friendly interface to access various tools and resources.
- **Admin Panel**: Web-based admin panel for managing content and users.

## Tech Stack

- **Frontend**: Flutter (Mobile & Web)
- **Backend**: Firebase (Authentication, Firestore, Storage)
- **AI Integration**: Google Generative AI (Gemini)
- **Packages**:
  - `provider` (State Management)
  - `firebase_auth`, `cloud_firestore` (Backend Services)
  - `google_generative_ai` (AI)
  - `audioplayers` (Media)
  - `shared_preferences` (Local Storage)

## Getting Started

To run this project locally, follow these steps:

### Prerequisites

- Flutter SDK installed
- Dart SDK installed
- Firebase account and project setup

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/yourusername/soulswaroop.git
    cd soulswaroop
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Firebase Setup:**
    - Ensure `firebase_options.dart` is configured for your project.
    - If not, run `flutterfire configure` to generate it.

4.  **Run the App:**
    ```bash
    flutter run
    ```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
