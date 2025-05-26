# Safe Space Web Module

## Project Description
Safe Space is a comprehensive healthcare platform that connects patients with healthcare providers through a modern web interface. The web module is built using Flutter for web, providing a responsive and user-friendly experience across different devices.

### Key Features
- **Patient Dashboard**: A centralized hub for patients to manage their healthcare journey
- **Appointment Management**: Schedule and track medical appointments
- **Doctor Search**: Find and connect with healthcare providers
- **Profile Management**: Maintain personal and medical information
- **Real-time Messaging**: Communicate with healthcare providers
- **Settings & Preferences**: Customize user experience and notification preferences

### Technical Architecture
The web module follows a modular architecture with clear separation of concerns:
- `pages/`: Contains all the main application pages
- `layouts/`: Reusable layout components
- `widgets/`: Shared UI components
- `models/`: Data models and business logic

## Firebase Integration
The application leverages Firebase services for backend functionality:

### Authentication
- Firebase Authentication for secure user management
- Email/password authentication
- User session management

### Cloud Firestore
- Real-time database for storing and syncing data
- Collections for:
  - User profiles
  - Appointments
  - Medical records
  - Messages
  - Settings

### Key Firebase Features Used
1. **Firebase Auth**
   - User authentication and authorization
   - Session management
   - Secure user data access

2. **Cloud Firestore**
   - Real-time data synchronization
   - Structured data storage
   - Efficient querying and filtering
   - Offline data persistence

### Data Structure
The application uses the following main collections:
- `humanpatients`: Patient profiles and information
- `appointments`: Medical appointment records
- `doctors`: Healthcare provider information
- `messages`: Communication between patients and doctors

## Getting Started
1. Ensure Firebase project is properly configured
2. Set up Firebase configuration in the project
3. Install required dependencies
4. Run the application using Flutter web

## Dependencies
- Flutter Web
- Firebase Core
- Firebase Auth
- Cloud Firestore
- Flutter Material Design

## Security
- All Firebase operations are secured with proper authentication
- Data access is controlled through Firebase Security Rules
- Sensitive information is properly encrypted and protected 