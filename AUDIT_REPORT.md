# Plantlets Vegetable Ordering Management System - Audit Report

**Date:** November 3, 2026  
**Auditor:** Antigravity AI Coding Assistant  
**Status:** Phase 1 Complete (Read-Only Audit)  

---

## 1. Executive Summary

This audit compares the codebase of the **Vegetable Ordering Management System** with:
1. `FLUTTER_MACHINE_TEST_DOCUMENT.docx` (functional source of truth).
2. The provided Figma design boards for the **Store (Admin)** and **Shop (Customer)** modules.

### Classification Summary:
- **Total Screens / Flows Audited:** 22
- **Implemented Screens:** 15
- **Partially Implemented Screens:** 3
- **Out of Scope (per Section 1B):** 4 (Staff Management, Sales Reports, SMS OTP Verification, Schedule Order / Multi-store flow)
- **Compilation / Static Analysis:** **0 Errors, 0 Warnings** (`flutter analyze` clean).

---

## 2. Store Module Audit (Admin Panel)

| Element | Figma Specification | Code Status | File:Line Reference | Gap Description | Priority |
|---|---|---|---|---|---|
| **Splash Screen** | Centered "Plantlets" logo on light/white background | **IMPLEMENTED** | [`lib/features/auth/presentation/pages/splash_page.dart:36-47`](file:///Users/faysarukattil/Desktop/Personal%20Projects/spinecodetest/lib/features/auth/presentation/pages/splash_page.dart#L36-L47) | Matches Figma splash screen with `assets/images/splash.png` fallback to `AppLogo`. | - |
| **Login Background** | Rolling green hill with blue sky & clouds | **IMPLEMENTED** | [`lib/features/auth/presentation/pages/login_page.dart:133-149`](file:///Users/faysarukattil/Desktop/Personal%20Projects/spinecodetest/lib/features/auth/presentation/pages/login_page.dart#L133-L149) | Uses `assets/images/login_bg.png` matching Figma wallpaper. | - |
| **Login Form** | Logo, prompt text, form inputs, full-width button | **IMPLEMENTED** | [`lib/features/auth/presentation/pages/login_page.dart:76-120`](file:///Users/faysarukattil/Desktop/Personal%20Projects/spinecodetest/lib/features/auth/presentation/pages/login_page.dart#L76-L120) | Visual spacing, text styling, and button match Figma. (Uses Email/Password per test doc). | - |
| **Login Auth Method** | Mobile number + 6-digit OTP | **OUT OF SCOPE** | [`lib/features/auth/data/datasources/auth_remote_datasource.dart:19`](file:///Users/faysarukattil/Desktop/Personal%20Projects/spinecodetest/lib/features/auth/data/datasources/auth_remote_datasource.dart#L19) | Intentionally implemented as Email & Password per Section 1B of test document. | OUT OF SCOPE |
| **Dashboard Header** | Dark bar (`0xFF2B2726`), Store Name, "Fresh Vegetables Store", Menu & Profile icons | **IMPLEMENTED** | [`lib/features/store_home/presentation/pages/store_dashboard_page.dart:88-124`](file:///Users/faysarukattil/Desktop/Personal%20Projects/spinecodetest/lib/features/store_home/presentation/pages/store_dashboard_page.dart#L88-L124) | Perfectly matches Figma colors, typography, and actions. | - |
| **Dashboard Stat Tiles** | 3 tiles: Orange "Scheduled", Yellow "Order", Green "Completed" | **PARTIAL** | [`lib/features/store_home/presentation/pages/store_dashboard_page.dart:129-136`](file:///Users/faysarukattil/Desktop/Personal%20Projects/spinecodetest/lib/features/store_home/presentation/pages/store_dashboard_page.dart#L129-L136) | Tile 1 is labeled "Pending" in code (since order scheduling is out of scope). Colors match Figma hex codes. | P1 |
| **Dashboard Orders Header** | "Orders" title with "View All" link | **IMPLEMENTED** | [`lib/features/store_home/presentation/pages/store_dashboard_page.dart:181-190`](file:///Users/faysarukattil/Desktop/Personal%20Projects/spinecodetest/lib/features/store_home/presentation/pages/store_dashboard_page.dart#L181-L190) | Clicking "View All" navigates to full Orders tab. | - |
| **Dashboard Order Cards** | Numbered order cards with item rows, quantity, date | **IMPLEMENTED** | [`lib/features/order/presentation/widgets/order_card.dart:30-81`](file:///Users/faysarukattil/Desktop/Personal%20Projects/spinecodetest/lib/features/order/presentation/widgets/order_card.dart#L30-L81) | Formats as `"1. Shop name"` + item rows + compact date. | - |
| **Dashboard Bottom Nav** | Home, Vegetables, Orders (selected state dark) | **IMPLEMENTED** | [`lib/features/store_home/presentation/pages/store_dashboard_page.dart:58-82`](file:///Users/faysarukattil/Desktop/Personal%20Projects/spinecodetest/lib/features/store_home/presentation/pages/store_dashboard_page.dart#L58-L82) | Bottom navigation includes Home, Vegetables, Shops, Orders with active dark charcoal indicator. | - |
| **Vegetables Segmented Control** | Available N / Unavailable N pill toggle | **IMPLEMENTED** | [`lib/features/vegetable/presentation/pages/vegetable_list_page.dart:132-159`](file:///Users/faysarukattil/Desktop/Personal%20Projects/spinecodetest/lib/features/vegetable/presentation/pages/vegetable_list_page.dart#L132-L159) | Labeled "Available N" / "Out of Stock N" with real-time counts. | - |
| **Vegetable Card** | Image/icon, name, price/unit, stock, Edit button, status toggle | **IMPLEMENTED** | [`lib/features/vegetable/presentation/widgets/vegetable_card.dart:24-86`](file:///Users/faysarukattil/Desktop/Personal%20Projects/spinecodetest/lib/features/vegetable/presentation/widgets/vegetable_card.dart#L24-L86) | Icon placeholder used (no paid Storage); toggle pill matches Figma green/red styling. | - |
| **Vegetables Add Button** | "+ Add New Vegetable" pinned at bottom | **IMPLEMENTED** | [`lib/features/vegetable/presentation/pages/vegetable_list_page.dart:95-101`](file:///Users/faysarukattil/Desktop/Personal%20Projects/spinecodetest/lib/features/vegetable/presentation/pages/vegetable_list_page.dart#L95-L101) | Fixed bottom button triggers add modal/page. | - |
| **Vegetable Toggle Dialog** | "Available" (green) / "Unavailable" (red) confirm | **IMPLEMENTED** | [`lib/features/vegetable/presentation/pages/vegetable_list_page.dart:31-48`](file:///Users/faysarukattil/Desktop/Personal%20Projects/spinecodetest/lib/features/vegetable/presentation/pages/vegetable_list_page.dart#L31-L48) | ConfirmDialog shows matching color, title, and buttons. | - |
| **Add/Edit Vegetable Form** | Sort number, Name, Unit dropdown/chips, Price, Stock | **IMPLEMENTED** | [`lib/features/vegetable/presentation/pages/add_edit_vegetable_page.dart:112-166`](file:///Users/faysarukattil/Desktop/Personal%20Projects/spinecodetest/lib/features/vegetable/presentation/pages/add_edit_vegetable_page.dart#L112-L166) | Form supports auto-sort number, Kg/Piece unit selector, price, and non-negative stock validation. | - |
| **Add/Edit Action Buttons** | Outlined "Cancel" & filled "Submit" pinned at bottom | **IMPLEMENTED** | [`lib/features/vegetable/presentation/pages/add_edit_vegetable_page.dart:168-185`](file:///Users/faysarukattil/Desktop/Personal%20Projects/spinecodetest/lib/features/vegetable/presentation/pages/add_edit_vegetable_page.dart#L168-L185) | Side-by-side bottom buttons with loading indicator. | - |
| **Orders Tab Filter Chips** | Pending, Approved, Rejected, Completed chips | **IMPLEMENTED** | [`lib/features/order/presentation/pages/store_order_list_page.dart:34-70`](file:///Users/faysarukattil/Desktop/Personal%20Projects/spinecodetest/lib/features/order/presentation/pages/store_order_list_page.dart#L34-L70) | Features All, Pending, Approved, Rejected, Completed, Cancelled tabs. | - |
| **Order Details Screen** | Centered title, tinted info card, items list, Total bar | **IMPLEMENTED** | [`lib/features/order/presentation/widgets/order_detail_body.dart:16-65`](file:///Users/faysarukattil/Desktop/Personal%20Projects/spinecodetest/lib/features/order/presentation/widgets/order_detail_body.dart#L16-L65) | Tinted lavender info card (`#EEF0FF`) with accent ID, status chip, shop name, items table. | - |
| **Order Action Buttons** | Reject (red outline), Approve (primary), Completed | **IMPLEMENTED** | [`lib/features/order/presentation/pages/store_order_detail_page.dart:67-99`](file:///Users/faysarukattil/Desktop/Personal%20Projects/spinecodetest/lib/features/order/presentation/pages/store_order_detail_page.dart#L67-L99) | Pending orders show Reject & Approve; Approved shows Complete. | - |
| **Shops List Screen** | Cards with Contact Person, Phone, Email, Location, Added Date, Edit, Toggle | **IMPLEMENTED** | [`lib/features/shop/presentation/widgets/shop_card.dart:26-74`](file:///Users/faysarukattil/Desktop/Personal%20Projects/spinecodetest/lib/features/shop/presentation/widgets/shop_card.dart#L26-L74) | Full shop details card with Active/Blocked toggle and delete action. | - |
| **Add/Edit Shop Form** | Store Name, Contact Person, Phone, Email, Password, Address | **IMPLEMENTED** | [`lib/features/shop/presentation/pages/add_edit_shop_page.dart:90-168`](file:///Users/faysarukattil/Desktop/Personal%20Projects/spinecodetest/lib/features/shop/presentation/pages/add_edit_shop_page.dart#L90-L168) | Full validation (10-digit mobile, valid email, min 6 char password). Uses secondary Firebase app so admin is not logged out. | - |
| **Profile Screen** | Dark header, avatar with initials, Active badge, info tiles, Logout | **IMPLEMENTED** | [`lib/features/auth/presentation/pages/profile_page.dart:43-177`](file:///Users/faysarukattil/Desktop/Personal%20Projects/spinecodetest/lib/features/auth/presentation/pages/profile_page.dart#L43-L177) | Charcoal header, initials circle, account info tiles, red logout button with confirmation dialog. | - |
| **Menu Screen** | Staff Management, Shops, Sales Reports tiles | **PARTIAL** | [`lib/features/store_home/presentation/pages/menu_page.dart:13-26`](file:///Users/faysarukattil/Desktop/Personal%20Projects/spinecodetest/lib/features/store_home/presentation/pages/menu_page.dart#L13-L26) | "Shops" tile is implemented. Staff & Sales Reports are out of scope. | OUT OF SCOPE |
| **Staff Management** | Staff list, Add Staff, Edit, Role picker | **OUT OF SCOPE** | - | Not requested in test document (Section 1B). | OUT OF SCOPE |
| **Sales Reports** | Filter by shop/date, order metrics, date range picker | **OUT OF SCOPE** | - | Not requested in test document (Section 1B). | OUT OF SCOPE |

---

## 3. Shop Module Audit (User Panel)

| Element | Figma Specification | Code Status | File:Line Reference | Gap Description | Priority |
|---|---|---|---|---|---|
| **Shop Header** | Indigo bar (`0xFF5B72F5`), shop name, "Fresh Vegetables Store", cart badge, profile | **IMPLEMENTED** | [`lib/features/shop_home/presentation/pages/shop_home_page.dart:116-179`](file:///Users/faysarukattil/Desktop/Personal%20Projects/spinecodetest/lib/features/shop_home/presentation/pages/shop_home_page.dart#L116-L179) | Features live cart badge count and profile navigation. | - |
| **Vegetables Search** | Search input with search icon | **IMPLEMENTED** | [`lib/features/vegetable/presentation/pages/shop_vegetable_list_page.dart:34-44`](file:///Users/faysarukattil/Desktop/Personal%20Projects/spinecodetest/lib/features/vegetable/presentation/pages/shop_vegetable_list_page.dart#L34-L44) | Real-time name filtering with empty match state. | - |
| **Vegetable Cards** | Image, name, unit chip (indigo border), price, stock quantity, Add / Stepper | **IMPLEMENTED** | [`lib/features/vegetable/presentation/pages/shop_vegetable_list_page.dart:68-165`](file:///Users/faysarukattil/Desktop/Personal%20Projects/spinecodetest/lib/features/vegetable/presentation/pages/shop_vegetable_list_page.dart#L68-L165) | In stock: Add button or QuantityStepper; Out of stock: grey badge. Enforces max stock limits. | - |
| **Bottom Place Order Bar** | Pinned button with item count | **IMPLEMENTED** | [`lib/features/shop_home/presentation/pages/shop_home_page.dart:68-83`](file:///Users/faysarukattil/Desktop/Personal%20Projects/spinecodetest/lib/features/shop_home/presentation/pages/shop_home_page.dart#L68-L83) | Dynamic label: `"Place Order (N items)"`. | - |
| **Bottom Navigation** | Vegetables, Orders (indigo selected color) | **IMPLEMENTED** | [`lib/features/shop_home/presentation/pages/shop_home_page.dart:88-111`](file:///Users/faysarukattil/Desktop/Personal%20Projects/spinecodetest/lib/features/shop_home/presentation/pages/shop_home_page.dart#L88-L111) | Two tabs matching customer navigation model. | - |
| **Cart Screen** | Item list, unit badge, price, line total, remove icon, stepper, summary bar | **IMPLEMENTED** | [`lib/features/cart/presentation/pages/cart_page.dart:121-181`](file:///Users/faysarukattil/Desktop/Personal%20Projects/spinecodetest/lib/features/cart/presentation/pages/cart_page.dart#L121-L181) | Includes live stock validation (`_problem` check) and duplicate-submit prevention. | - |
| **Order Placed Dialog** | Success card with check icon, confirmation title & subtitle, Done button | **IMPLEMENTED** | [`lib/features/cart/presentation/pages/cart_page.dart:81-110`](file:///Users/faysarukattil/Desktop/Personal%20Projects/spinecodetest/lib/features/cart/presentation/pages/cart_page.dart#L81-L110) | Centered check icon, success headline, clears cart on done. | - |
| **Order History Screen** | Status filter chips (All, Pending, Approved, Rejected, Cancelled), Order cards | **IMPLEMENTED** | [`lib/features/order/presentation/pages/shop_order_history_page.dart:35-89`](file:///Users/faysarukattil/Desktop/Personal%20Projects/spinecodetest/lib/features/order/presentation/pages/shop_order_history_page.dart#L35-L89) | Realtime listener filtered by logged-in shop UID. | - |
| **Shop Order Details** | Tinted order summary card, items breakdown, pending notice, cancel button | **IMPLEMENTED** | [`lib/features/order/presentation/pages/shop_order_detail_page.dart:45-80`](file:///Users/faysarukattil/Desktop/Personal%20Projects/spinecodetest/lib/features/order/presentation/pages/shop_order_detail_page.dart#L45-L80) | Yellow note shown for pending status. Red outlined "Cancel Order" shown only when status is Pending. | - |
| **Cancel Order Dialog** | Confirm Cancel dialog with red title and confirmation action | **IMPLEMENTED** | [`lib/features/order/presentation/pages/shop_order_detail_page.dart:19-27`](file:///Users/faysarukattil/Desktop/Personal%20Projects/spinecodetest/lib/features/order/presentation/pages/shop_order_detail_page.dart#L19-L27) | Dialog prompts user before cancelling. | - |
| **Banners (Advance/Repeat)** | "Order in advance", "Repeat last order", "Change store" | **OUT OF SCOPE** | - | Excluded per Section 1B. | OUT OF SCOPE |
| **Scheduled Orders Tab** | Scheduled N / Order N segmented control | **OUT OF SCOPE** | - | Excluded per Section 1B. | OUT OF SCOPE |

---

## 4. Known Intentional Differences (Out of Scope per Section 1B)

1. **Authentication:** Email & Password used instead of SMS OTP (per machine test requirement document).
2. **Vegetable Photos:** Icons used instead of Cloud Storage image upload (avoids paid tier requirement).
3. **Cart Flow:** Direct Cart -> Place Order flow used instead of Schedule Order date-picker, Summary, and Previous Orders flows.
4. **Units:** Single unit per vegetable (Kg or Piece) rather than dynamic multi-unit packaging per item.
5. **Staff Management & Sales Reports:** Excluded from the machine test document scope.

---

## 5. Code Quality & Architecture Audit (Section 3H)

1. **Static Analysis:**
   - Errors: **0**
   - Warnings: **0**
   - Lint Infos: **0**
2. **Layer Separation (Clean Architecture):**
   - Presentation widgets communicate solely with Providers.
   - Providers execute Domain Use Cases (`LoginUseCase`, `PlaceOrderUseCase`, `GetVegetablesUseCase`, etc.).
   - Use Cases communicate with Data Repositories and Data Sources.
   - **Zero Firebase calls in widgets or pages.**
3. **Data Integrity & Concurrency:**
   - Stock deduction & restoration use atomic Firestore transactions in `order_remote_datasource.dart`.
   - Prevent ordering more than stock is enforced in UI, Provider, and atomic Firestore write.
   - Duplicate order submission is prevented via transaction check and checkout ID tagging.
4. **Session Management:**
   - SharedPreferences correctly handles `isLoggedIn`, `userId`, `userRole`, `userEmail`, `userName`.
   - Auto-login validates role and blocked status upon app cold start.
5. **Android Configuration:**
   - `android.permission.INTERNET` is present in `android/app/src/main/AndroidManifest.xml`.
6. **Code Smells & Missing Elements:**
   - **Missing `firestore.rules`:** A local `firestore.rules` file is missing from the repository root (needed for Section 3G testing).
   - **Default `README.md`:** `README.md` contains default template text instead of setup and architecture documentation.
   - **Font integration:** `google_fonts` package is present in `pubspec.yaml`, but the Inter/Poppins font theme is not wired up in `app_theme.dart`.

---

## 6. Top 10 Prioritized Fixes for Phase 2

1. **[P0] Create `firestore.rules`**: Implement and document full security rules matching Section 3G requirements (role checks, shop immutability, stock transaction constraints, blocked shop rules).
2. **[P0] Comprehensive `README.md`**: Author complete setup guide, Firebase configuration, collection schema, default credentials, and Clean Architecture overview.
3. **[P1] Apply App Font via `google_fonts`**: Apply `GoogleFonts.interTextTheme()` (or Poppins) in `app_theme.dart` and `shop_theme.dart` to match Figma typography.
4. **[P1] Dashboard Stat Tile Labels**: Label tiles "Pending", "Total Orders", "Completed" with clean subtitles matching Figma metrics.
5. **[P1] Add Vegetable Form Image Area**: Add clean visual image placeholder container in `add_edit_vegetable_page.dart` matching Figma card layout.
6. **[P1] Realtime Blocked Shop Auto-Logout**: Add active listener in `AuthProvider` / `ShopHomePage` to instantly detect if admin blocks shop account while logged in.
7. **[P1] Responsive & Text-Scaling Checks**: Verify layout safety across 360x640, 411x891, safe areas, and 1.3x text scale.
8. **[P1] Input Field Styling Polish**: Ensure input field heights, borders, and hint colors match Figma specs.
9. **[P1] Status Chips Polish**: Verify chip background opacities and typography across all status states.
10. **[P1] Dialog Layout Consistency**: Ensure dialog radius (16px), button heights, and confirmation accent colors strictly mirror Figma modals.

