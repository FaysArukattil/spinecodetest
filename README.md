# 🥬 Plantlets — Vegetable Ordering & Supply Chain Management System

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture-success)](https://blog.cleancoder.com)
[![State Management](https://img.shields.io/badge/State-Provider-blue)](https://pub.dev/packages/provider)
[![Backend](https://img.shields.io/badge/Backend-Firebase-FFCA28?logo=firebase)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A production-grade, responsive cross-platform mobile application built with **Flutter**, **Firebase Cloud Firestore**, and **Firebase Authentication**. The system manages end-to-end B2B vegetable supply operations between a central store distributor (**Admin Panel**) and registered retail customer shops (**User Panel**).

Designed strictly in accordance with the **Figma Design Specifications**, **Clean Architecture (Domain / Data / Presentation)**, and the **Machine Test Requirements**.

---

## 📸 Modules & Features

### 🏢 1. Store Module (Admin Panel) 
- **Dashboard & Metrics:** Real-time summary tiles showing *Pending Orders*, *Total Orders*, *Completed Orders*, and fast navigation to vegetables, shops, and staff.
- **Vegetable Catalog Management:**
  - Full CRUD operations with instant Firestore synchronization.
  - Sort ordering, unit selection (*Kg*, *Piece*, *Box*, *Bag*, *Packet*), live price per unit, and non-negative stock tracking.
  - Instant status toggle (*Available* / *Out of Stock*).
- **Shop Customer Management:**
  - Register new retail shops (automatically creates isolated Firebase Auth credentials without disrupting the active store session).
  - Edit shop details (Shop name, Owner name, 10-digit Phone, Address).
  - One-tap **Block / Activate** toggle with immediate login revocation.
  - Delete shop account and cascade cleanup.
- **Order Processing & Fulfillment:**
  - Order tabs filter: *All*, *Pending*, *Approved*, *Rejected*, *Completed*, *Cancelled*.
  - Status transition state-machine: `Pending` $\rightarrow$ `Approved` / `Rejected` / `Cancelled`, and `Approved` $\rightarrow$ `Completed`.
  - Rejection / Cancellation triggers atomic inventory restock transaction.
  - Edit line-item quantities during fulfillment review.
- **Invoice Generation & Printing:**
  - One-tap **Print Invoice** powered by `pdf` and `printing` packages.
  - Generates itemized tax invoice PDF with brand header, subtotal, free delivery, and grand total.
  - Direct integration with native Android / iOS print dialogs and "Save as PDF".
- **Staff Management:**
  - Add, inspect, and remove warehouse and operations staff.

---

### 🛒 2. Shop Module (Customer Panel) 
- **Dual Authentication Modes:**
  - **Email + Password Login:** Secure login with automatic role detection and blocked status check.
  - **Mobile Phone OTP Login:** Clean 6-circle PIN entry matching Figma. Only authorized active shops can log in; unauthorized numbers are rejected before SMS dispatch.
- **Live Vegetable Ordering:**
  - Browse available catalog items with real-time stock levels.
  - Real-time search filter by vegetable name.
  - Interactive stepper (`[-] qty [+]`) with real-time quantity validation preventing over-ordering beyond inventory.
- **Shopping Cart & Checkout:**
  - Real-time itemized cart with subtotal and grand total calculations.
  - **Atomic Firestore Transactions:** Deducts stock atomically, validates availability under race conditions, and writes order records.
  - Duplicate checkout submission guard.
- **Order Tracking & History:**
  - Live order status tracking chips (*Pending*, *Approved*, *Rejected*, *Completed*, *Cancelled*).
  - Cancel *Pending* orders (atomically restores inventory to catalog).
  - Customer invoice print/export for completed orders.

---

### 🌐 3. Global App Enhancements
- **Internet Connectivity Watcher:**
  - Real-time network detection via `connectivity_plus`.
  - Automatic top alert banner and floating SnackBar when offline (`No Internet Connection`), with automatic `Back Online` notification upon reconnection.
- **Custom Brand App Icons:**
  - Branded Plantlets vector logo centered on pure white background across all Android densities (`ic_launcher` and `ic_launcher_round`), iOS, and Web.
- **Zero Overflow Layouts:**
  - Tested across compact 360px screens, tablets, and landscape orientations with soft keyboard handling.

---

## ⚡ Quick Start: Clone & Run in 3 Minutes

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`^3.13.5` or later, Dart 3 compatible).
- Android Studio / Xcode / VS Code with Flutter extension.
- Connected Android/iOS device or active Emulator/Simulator.

### 1. Clone the Repository
```bash
git clone https://github.com/faysarukattil/spinecodetest.git
cd spinecodetest
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Verify Code Quality (0 Errors)
```bash
flutter analyze
```

### 4. Run the Application
```bash
flutter run
```

---

## 🔐 Firebase Configuration & Credentials

The project is already pre-configured with Firebase (`google-services.json` and `lib/firebase_options.dart`).

### 1. Test Accounts (Ready to Test)

| Role | Login Method | Identifier | Password / Code | Destination |
| :--- | :--- | :--- | :--- | :--- |
| **Store Admin** | Email + Password | `store@test.com` | `123456` | Store Dashboard (`/store-home`) |
| **Shop Customer** | Email + Password | Create from Store Panel | `123456` | Shop Home (`/shop-home`) |
| **Shop Customer** | Phone Number OTP | Registered Shop Mobile | Firebase SMS / Test OTP | Shop Home (`/shop-home`) |

> [!TIP]
> **How to create a Shop test account:**
> 1. Log in as Store Admin (`store@test.com` / `123456`).
> 2. Go to **Menu > Shops > + Add New Shop**.
> 3. Enter Shop Name, Owner, Phone (e.g. `9876543210`), Email (`shop1@test.com`), and Password (`123456`).
> 4. You can now log into that shop via **Email + Password** OR via **Mobile Number OTP**!

---

### 2. Android Client Fingerprints (SHA-1 / SHA-256)

If you are configuring your own Firebase project or running Phone Auth on Android devices, register these SHA fingerprints under **Firebase Console > Project Settings > General > Your apps (`com.example.spinecodetest`)**:

```text
SHA-1:   02:73:AE:E0:66:46:92:99:0A:74:1E:E6:35:1E:BF:82:B8:0B:E6:B1
SHA-256: 96:A0:ED:E2:4F:F5:43:87:7E:C2:71:71:E2:A1:6C:03:D6:E2:D2:8D:35:F6:AC:62:57:E4:B5:AE:35:96:C3:5D
```

### 3. Fast Emulator / Local Phone Auth Testing
To test Phone OTP without SMS carrier delays or SMS quotas:
1. Go to **Firebase Console > Authentication > Sign-in method > Phone**.
2. Expand **Phone numbers for testing**.
3. Add:
   - **Phone number:** `+91 9876543210`
   - **Verification code:** `123456`

---

## 🛡️ Cloud Firestore Security Rules

Deploy via Firebase CLI:
```bash
firebase deploy --only firestore:rules
```

Or copy-paste into **[Firebase Console > Firestore Database > Rules](https://console.firebase.google.com/project/spinecodetest/firestore/rules)**:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    function isAuthenticated() {
      return request.auth != null;
    }

    function isStore() {
      return isAuthenticated() &&
        exists(/databases/$(database)/documents/users/$(request.auth.uid)) &&
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'store';
    }

    function isShop() {
      return isAuthenticated() &&
        exists(/databases/$(database)/documents/users/$(request.auth.uid)) &&
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'shop';
    }

    function isActiveShop() {
      return isShop() &&
        exists(/databases/$(database)/documents/shops/$(request.auth.uid)) &&
        get(/databases/$(database)/documents/shops/$(request.auth.uid)).data.status == 'Active';
    }

    // 1. Users collection
    match /users/{userId} {
      allow read: if isStore() || (isAuthenticated() && request.auth.uid == userId);
      allow create, update, delete: if isStore();
    }

    // 2. Shops collection (public read for phone lookup before login)
    match /shops/{shopId} {
      allow read: if true;
      allow create, update, delete: if isStore();
    }

    // 3. Vegetables collection
    match /vegetables/{vegId} {
      allow read: if isStore() || isActiveShop();
      allow create, delete: if isStore();
      allow update: if isStore() || (
        isActiveShop() &&
        request.resource.data.diff(resource.data).affectedKeys().hasOnly(['stockQuantity', 'status']) &&
        request.resource.data.stockQuantity >= 0 &&
        request.resource.data.name == resource.data.name &&
        request.resource.data.price == resource.data.price &&
        request.resource.data.unit == resource.data.unit
      );
    }

    // 4. Orders collection
    match /orders/{orderId} {
      allow read: if isStore() || (isActiveShop() && resource.data.shopId == request.auth.uid);
      allow create: if isActiveShop() &&
        request.resource.data.shopId == request.auth.uid &&
        request.resource.data.status == 'Pending' &&
        request.resource.data.totalAmount > 0;
      allow update: if isStore() || (
        isActiveShop() &&
        resource.data.shopId == request.auth.uid &&
        resource.data.status == 'Pending' &&
        request.resource.data.status == 'Cancelled' &&
        request.resource.data.diff(resource.data).affectedKeys().hasOnly(['status'])
      );
      allow delete: if false; // Audit trail preservation
    }

    // 5. Staff collection
    match /staff/{staffId} {
      allow read, write: if isStore();
    }
  }
}
```

---

## 🏗️ Architecture & Directory Structure

```
lib/
├── app.dart                   # Root MaterialApp, MultiProvider & ConnectivityWatcher
├── firebase_options.dart      # Generated Firebase SDK configuration
├── main.dart                  # Application entrypoint & initialization
├── core/
│   ├── constants/             # AppConstants, FirestoreKeys, StorageKeys
│   ├── errors/                # Failure & AppException domain abstractions
│   ├── routes/                # AppRoutes & RouteGenerator declarative router
│   ├── theme/                 # AppColors, ShopColors, typography, Material 3 ThemeData
│   ├── utils/                 # Formatters, DateFormatter, Validators, InvoicePrinter
│   └── widgets/               # AppLogo, AppIcon, CustomButton, InternetConnectivityWatcher
└── features/
    ├── auth/                  # Authentication & Session Management
    │   ├── data/              # AuthRemoteDataSource (Firebase), AuthLocalDataSource (Prefs)
    │   ├── domain/            # UserEntity, LoginUseCase, VerifyPhoneUseCase, CheckShopPhoneUseCase
    │   └── presentation/      # AuthProvider, LoginPage, OtpVerificationPage, SplashPage
    ├── vegetable/             # Vegetable Catalog Management
    │   ├── data/              # VegetableRemoteDataSource, VegetableModel
    │   ├── domain/            # VegetableEntity, CRUD Use Cases
    │   └── presentation/      # VegetableProvider, VegetableListPage, AddEditVegetablePage
    ├── shop/                  # Customer Retail Shop Management
    │   ├── data/              # ShopRemoteDataSource, ShopModel
    │   ├── domain/            # ShopEntity, Shop CRUD & ToggleStatus Use Cases
    │   └── presentation/      # ShopProvider, ShopListPage, AddEditShopPage
    ├── cart/                  # Shopping Cart & Stepper State
    │   ├── domain/            # CartItemEntity
    │   └── presentation/      # CartProvider, CartPage, QuantityStepper
    ├── order/                 # Order Placement, Transactions & Fulfillment
    │   ├── data/              # OrderRemoteDataSource (ACID transactions)
    │   ├── domain/            # OrderEntity, OrderItemEntity, Order Use Cases
    │   └── presentation/      # OrderProvider, StoreOrderDetailPage, ShopOrderDetailPage
    ├── store_home/            # Admin Panel Home & Bottom Tabs
    └── shop_home/             # Customer Panel Home & Bottom Tabs
```

---

## 📦 Production Build Commands

```bash
# Build Android APK (Release)
flutter build apk --release

# Build Android App Bundle (for Google Play Store)
flutter build appbundle --release

# Build iOS Archive (macOS only)
flutter build ipa --release

# Build Web Single Page App
flutter build web --release
```

The output Android release APK is generated at:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## 🧪 Testing & Verification

- **Unit Tests:** `test/order_entity_test.dart`
- **Static Analysis:** `flutter analyze` $\rightarrow$ **0 issues found**.
- **Formatted Code:** `dart format .` $\rightarrow$ **100% formatted**.
