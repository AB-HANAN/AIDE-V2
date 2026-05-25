# AIDE - App Documentation & Technical Overview

## 📱 Application Overview

**AIDE** is a sophisticated Flutter-based robot control application that enables secure remote management and control of robotic systems. The app provides real-time telemetry monitoring, multi-user management with role-based access, and autonomous robot capabilities.

### Core Purpose
- Remote robot control and monitoring in real-time
- Secure multi-user authentication and authorization
- Admin and operator role management
- Real-time telemetry data visualization (speed, heading, coordinates, obstacles)
- AI-powered user support chat
- WebView integration for complex interfaces

---

## 🏗️ Architecture & Design Patterns

### Multi-Layer Architecture
The app follows a clean three-tier architecture: UI layer (Screens) → Business Logic (Services) → Data Layer (Firebase, Local Storage, REST API).

### Design Patterns Used

#### 1. **Singleton Pattern**
Services use singleton pattern to ensure only one instance exists throughout the app lifecycle. This reduces memory overhead and provides a single centralized access point for all services.

#### 2. **Service Locator Pattern**
All business logic is centralized in services:
- **FirebaseAuthService** - User authentication and profile management
- **FirestoreUserService** - User data operations
- **RobotApiService** - Robot communication and telemetry
- **AppStorage** - Local device storage
- **AdminSetupService** - Admin configuration

#### 3. **Model/Data Classes**
Strong typing with automatic serialization/deserialization for database operations. Models include validation and type conversion logic.

#### 4. **Enums for Type Safety**
Type-safe role management and state definitions prevent runtime errors and enable compile-time checking.

---

## 🔧 Key Technologies & Frameworks

### Frontend
- Flutter 3.11+ with Material Design 3 for modern, adaptive UI

### Backend & Database
- Firebase Core for infrastructure
- Firebase Authentication for secure user login
- Cloud Firestore for real-time NoSQL database
- Firestore Security Rules for database-level access control

### Communication & Storage
- HTTP package for REST API requests to robot backend
- WebView Flutter for embedded web content
- SharedPreferences for local configuration storage

### Cloud Functions
- Firebase Cloud Functions (Node.js) for server-side operations
- Callable HTTP functions for secure user deletion from Auth
- Admin SDK for authentication and user management

### Security Features
- Firebase Auth with JWT-based authentication
- Email/password login with automatic UID generation
- Firestore Rules for role-based database access

---

## 🔐 Important Techniques

### 1. **Firebase Authentication & Security**
Firebase handles secure user registration, login, and password management. The system supports email/password authentication with automatic UID generation, secure password reset via email, and user profile management. Firebase implements industry-standard password hashing and OAuth 2.0 protocols, ensuring passwords are never stored as plain text locally or remotely.

**Key Features:** Email/password login, secure password reset, automatic token management, user profile updates.

---

### 2. **Role-Based Access Control (RBAC)**
The app implements a two-tier security model with Admin and Operator roles. Security is enforced at two levels: database rules prevent unauthorized data access, and application logic restricts actions based on user role. Admins can create users, assign roles, manage passwords, and configure systems. Operators have limited capabilities for robot control only.

**Benefit:** Multi-layer security prevents privilege escalation and unauthorized access.

---

### 3. **Password History & Audit Trail**
Every password change is recorded with timestamp and actor information (user or admin). This creates a complete audit trail for security compliance and suspicious activity investigation. Admins can force password changes on operator accounts when needed.

**Use Case:** Security audits, compliance requirements, incident investigation.

---

### 4. **Real-Time Robot Telemetry System**
The app receives live telemetry data from robots including navigation mode, target information, GPS heading, speed monitoring, motor RPM, localization status, obstacle detection distances, and safety status. The system intelligently handles multiple data formats from the robot API, converting strings to numbers, handling boolean variations, and providing sensible fallbacks.

**Advantage:** Robust parsing handles inconsistent API responses gracefully without crashes.

---

### 5. **Advanced Theme Customization**
The app supports dynamic theming where users can change primary and secondary colors at runtime. All theme changes persist locally and apply immediately across the entire interface. Material Design 3 ensures consistent, adaptive layouts across different devices. Colors can be customized per installation, enabling white-label deployments.

**Benefits:** Consistent branding, theme switching without app restart, support for brand customization.

---

### 6. **Persistent Local Storage**
App configuration, robot settings, theme preferences, and user credentials are stored locally on the device. This enables offline access to settings, fast app startup, and reduced network requests. The system detects first-time app launch and triggers initial setup automatically.

**Use Cases:** First launch detection, configuration caching, theme persistence, offline access.

---

### 7. **Firestore Data Serialization & Type Safety**
User profiles and data models include automatic conversion between Dart objects and Firestore documents. The system handles nested data structures (like password history), automatic timestamp conversion, and graceful handling of missing fields with default values. Strict typing prevents runtime data errors.

**Advantages:** Type-safe operations, default value handling, support for complex nested data, automatic format conversion.

---

### 8. **Multi-Screen Application Architecture**
The app organizes screens into logical groups: authentication (login, registration, password change), admin functions (user management, setup), robot control (dashboard, manual drive, person following), communication (AI chat), and settings/information screens. Navigation automatically routes users based on authentication status and role.

**Organization:** Clean separation of concerns makes feature addition and maintenance easier.

---

### 9. **Error Handling Strategy**
All async operations use try-catch blocks to handle errors gracefully. Firebase-specific exceptions are converted to user-friendly messages. Errors are logged for debugging while showing appropriate messages to users.

**Benefit:** Better user experience and easier troubleshooting.

---

### 10. **WebView Integration**
The app embeds web content using WebView for privacy policies, help documentation, and complex dashboards. This allows displaying HTML/CSS content without building native UI, and enables integration with web-based monitoring tools.

**Use Cases:** Terms of service, help pages, remote dashboards, documentation.

---

## 📊 Data Flow Architecture

User Input → Screen Widget → Service Layer (Business Logic) → Data Layer (Firebase, Local Storage, Robot API) → UI Update

The flow ensures clean separation: UI only handles presentation, services handle business logic, and data layer manages all persistence and API communication.

---

## 🔄 State Management

The app uses **StatefulWidget** pattern for local state management within screens. Global state (current user, telemetry data, app configuration) is maintained in service instances that persist across screen changes. This simple approach works well for the app's architecture.

---

## 🛡️ Security Features

**Database-Level Security:** Firestore rules enforce authentication and role-based access. Only authenticated users can read data, admins can read all user profiles, and users can only modify their own data.

**Password Security:** Firebase handles all password hashing automatically. Plain-text passwords are never stored locally or transmitted insecurely.

**Session Management:** Firebase manages JWT tokens automatically with background refresh. Secure logout clears all authentication state.

**Audit Trail:** Every password change, user creation, and admin action is recorded with timestamp and actor for compliance.

---

## 📱 Responsive UI Design

The app uses Material Design 3 with adaptive layouts that work on phones and tablets. Custom theme implementation provides consistent styling with rounded corners, proper elevation, and color harmony. Theme can be customized without code changes.

---

## 🚀 App Lifecycle

**Startup:** Flutter bindings initialize → Firebase initializes → App checks for admin accounts → Theme loads from preferences → App displays appropriate screen based on auth status.

**Runtime:** Theme changes update immediately, telemetry updates in real-time, user session persists until logout.

---

## 📋 Key Screens

| Screen | Purpose |
|--------|---------|
| Opening Screen | App entry point, routing |
| Login Screen | User authentication |
| Register Screen | New account creation |
| Admin Setup Screen | Initial admin account creation |
| Dashboard Screen | Real-time telemetry & robot status |
| Manual Drive Screen | Direct robot control |
| Person Follow Screen | Autonomous person tracking |
| AI Chat Screen | AI-powered help & support |
| Admin User Management | User administration |
| Settings Screen | App configuration |
| Profile Screen | User profile management |

---

## 🔗 Integration Points

**Firebase:** Handles authentication, user data storage, and real-time updates.

**Robot API:** HTTP requests retrieve telemetry, send control commands, and receive status updates.

**Local Storage:** Device storage maintains configuration and preferences for fast access.

---

## 🎯 Best Practices Implemented

✅ **Separation of Concerns** - Clean separation between UI, logic, and data layers  
✅ **Error Handling** - Try-catch blocks with user-friendly messages  
✅ **Security** - Multi-layer access control, audit trails, secure authentication  
✅ **Performance** - Lazy loading, local caching, singleton services  
✅ **Type Safety** - Strong typing, enums, null safety  
✅ **Scalability** - Service-based architecture, modular design  

---

## 📦 Dependencies

| Package | Purpose |
|---------|---------|
| flutter | UI Framework |
| firebase_core | Firebase initialization |
| firebase_auth | Authentication |
| cloud_firestore | Real-time database |
| firebase_functions | Cloud Functions client |
| http | REST API requests |
| webview_flutter | Embedded web content |
| shared_preferences | Local storage |

---

## ☁️ Cloud Functions Setup

The project includes Cloud Functions for server-side operations. The `functions/` directory contains TypeScript code that runs on Firebase's servers.

### Key Cloud Function: deleteUser

Securely deletes users from both Firebase Authentication and Firestore:
- Validates admin privileges
- Deletes from Auth (permanently removes user account)
- Deletes from Firestore profile
- Handles edge cases gracefully

### Deployment Instructions

```bash
# Navigate to functions directory
cd functions

# Install dependencies
npm install

# Build TypeScript
npm run build

# Deploy to Firebase
npm run deploy
```

**Important:** Cloud Functions must be deployed before user deletion works correctly. Until deployment, deleting users will fail because the client-side code calls the Cloud Function.

### Local Testing

```bash
# Start Firebase emulator
npm run serve

# Or use functions shell
npm run shell
```

For detailed instructions, see `functions/README.md`.

---

## 🔮 Advanced Concepts

**Real-Time Sync:** Firestore listeners update data automatically, UI rebuilds on changes.

**Conditional Rendering:** Screens display different content based on auth status and user role.

**Flexible API Handling:** Telemetry parser handles multiple data formats from robot API gracefully.

---

## 📚 Summary

AIDE is a professionally-built Flutter application demonstrating:
- Secure Firebase authentication and authorization
- Role-based access control for multi-user systems
- Real-time robot telemetry integration
- Dynamic theming and customization
- Complete audit trails for compliance
- Service-oriented, maintainable architecture
- Strong error handling and type safety

**Last Updated:** May 2026 | **Platform:** Flutter (iOS, Android, Web)
