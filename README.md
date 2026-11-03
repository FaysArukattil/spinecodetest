# Plantlets - Vegetable Ordering Management System

A robust, cross-platform mobile application developed with **Flutter** for managing vegetable supply chain operations between a central store (admin panel) and registered customer retail shops (user panel).

Built following strict **Clean Architecture** principles, **Provider** state management, and **Firebase** backend services.

---

## 📱 Features Overview

### 1. Store Module (Admin Panel)
- **Authentication**: Secure email and password authentication with persistent session via `SharedPreferences`.
- **Dashboard**: Real-time summary metrics for Pending, Total, and Completed orders, with quick access to recent orders, vegetables, and shops.
- **Vegetable Catalog Management**:
  - Add, edit, delete vegetable items.
  - Automatic sort ordering, pricing per unit (Kg / Piece).
  - Non-negative stock quantity tracking and real-time status toggling (Available / Out of Stock).
- **Shop Management**:
  - Add registered retail shops (creates Firebase Auth account via secondary isolated Firebase instance without disrupting store session).
  - Edit shop details (owner, mobile number, address).
  - Block / Activate shop access with immediate login prevention.
  - Delete shop account and clean up profile records.
- **Order Management**:
  - View all orders filtered by status tabs (All, Pending, Approved, Rejected, Completed, Cancelled).
  - Inspect detailed line items, unit quantities, and order totals.
  - Transition order statuses (Approve, Reject with auto-restock, Mark as Completed).

### 2. Shop Module (Customer Panel)
- **Authentication**: Secure login with auto-verification against blocked status.
- **Live Vegetable Ordering**:
  - Browse available vegetables with real-time stock availability.
  - Search vegetables by name.
  - Add items to shopping cart and control quantities (`[-] qty [+]`).
  - Stock limits enforced (prevents ordering beyond available inventory).
- **Shopping Cart & Checkout**:
  - Itemized cart with subtotals and grand total calculations.
  - Atomic transaction checkout (deducts stock atomically, verifies availability, creates order).
  - Duplicate submission guard.
- **Order History & Tracking**:
  - View historical orders filtered by status chips.
  - Inspect order details with live status updates.
  - Cancel Pending orders (atomically restores reserved inventory).

---

## 🏗️ Architecture & Folder Structure

The project strictly follows **Clean Architecture** with separation of concerns:

```
lib/
├── core/
│   ├── constants/        # Global constants, Firestore keys, SharedPreferences keys
│   ├── errors/           # Domain Failure models and Exception wrappers
│   ├── routes/           # AppRoutes and RouteGenerator navigation mapping
│   ├── theme/            # AppColors, ShopColors, typography, and Material 3 ThemeData
│   ├── utils/            # Validators, Currency/Quantity Formatters, Date helpers
│   └── widgets/          # Shared reusable UI components (Buttons, TextFields, Dialogs, States)
├── features/
│   ├── auth/             # Login, Splash, Profile, Session management
│   │   ├── data/         # AuthLocalDataSource (prefs), AuthRemoteDataSource (firebase)
│   │   ├── domain/       # UserEntity, LoginUseCase, LogoutUseCase, GetSessionUseCase
│   │   └── presentation/ # AuthProvider, LoginPage, SplashPage, ProfilePage
│   ├── vegetable/        # Vegetable CRUD & catalog
│   │   ├── data/         # VegetableRemoteDataSource, VegetableModel
│   │   ├── domain/       # VegetableEntity, CRUD Use Cases
│   │   └── presentation/ # VegetableProvider, VegetableListPage, AddEditVegetablePage
│   ├── shop/             # Shop registration & management
│   │   ├── data/         # ShopRemoteDataSource, ShopModel
│   │   ├── domain/       # ShopEntity, Shop CRUD Use Cases, ToggleStatusUseCase
│   │   └── presentation/ # ShopProvider, ShopListPage, AddEditShopPage
│   ├── cart/             # Shopping cart state & stepper
│   │   ├── domain/       # CartItemEntity
│   │   └── presentation/ # CartProvider, CartPage, CartItemTile, QuantityStepper
│   ├── order/            # Order placement & fulfillment
│   │   ├── data/         # OrderRemoteDataSource (Firestore transactions)
│   │   ├── domain/       # OrderEntity, OrderItemEntity, Order Use Cases
│   │   └── presentation/ # OrderProvider, StoreOrderListPage, ShopOrderHistoryPage, Detail pages
│   ├── store_home/       # Store dashboard and menu navigation
│   └── shop_home/        # Shop home with bottom navigation
├── app.dart              # MultiProvider setup & root MaterialApp
├── firebase_options.dart # Generated Firebase configuration
└── main.dart             # App entry point & initialization
```

---

## 🔐 Firebase Setup & Configuration

### 1. Prerequisites
- Create a project on the [Firebase Console](https://console.firebase.google.com/).
- Enable **Email/Password** under **Authentication > Sign-in method**.
- Enable **Cloud Firestore** in production or test mode.

### 2. Firestore Collections & Schema
- `users/{uid}`:
  - `role`: `'store'` | `'shop'`
  - `name`: string
  - `email`: string
  - `createdAt`: timestamp
- `shops/{uid}`:
  - `shopName`: string
  - `ownerName`: string
  - `email`: string
  - `phone`: string (10 digits)
  - `address`: string
  - `status`: `'Active'` | `'Blocked'`
  - `createdAt`: timestamp
- `vegetables/{id}`:
  - `name`: string
  - `sortNumber`: number
  - `unit`: `'Kg'` | `'Piece'`
  - `price`: number
  - `stockQuantity`: number
  - `status`: `'Available'` | `'Out of Stock'`
  - `createdAt`: timestamp
- `orders/{id}`:
  - `shopId`: string
  - `shopName`: string
  - `items`: array of `{ vegetableId, name, unit, price, quantity, lineTotal }`
  - `totalAmount`: number
  - `status`: `'Pending'` | `'Approved'` | `'Rejected'` | `'Completed'` | `'Cancelled'`
  - `createdAt`: timestamp

### 3. Deploy Security Rules
Deploy the included [`firestore.rules`](file:///Users/faysarukattil/Desktop/Personal%20Projects/spinecodetest/firestore.rules) via Firebase CLI:
```bash
firebase deploy --only firestore:rules
```

### 4. Seed Store Admin Account
To create the initial store admin account in Firebase:
1. In Firebase Console > Authentication, create a user:
   - **Email:** `store@test.com`
   - **Password:** `123456`
2. In Firestore > `users` collection, create a document with the user's `UID`:
   ```json
   {
     "role": "store",
     "name": "Fresh Vegetables Store",
     "email": "store@test.com",
     "createdAt": "2026-11-03T00:00:00Z"
   }
   ```
3. You can now log into the Store Admin Panel. Shop customer accounts are created directly from the Store app (`Shops > + Add New Shop`).

---

## 🚀 Setup & Execution

### Install Dependencies
```bash
flutter pub get
```

### Run Static Analysis
```bash
flutter analyze
```

### Run the Application
```bash
# Debug mode
flutter run

# Build Android APK (Release)
flutter build apk --release
```
The generated APK will be located at:
`build/app/outputs/flutter-apk/app-release.apk`
