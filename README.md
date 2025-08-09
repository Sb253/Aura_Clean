Aura Clean - Full Project Documentation
This document provides a complete overview of the Aura Clean application, from its architecture and features to the steps required for deployment.
1. README.md
   Aura Clean
   Aura Clean is an ultra-modern, cross-platform mobile app built with Flutter designed to help users clean and manage their phone's photo library to free up storage. It features a sleek, minimalist design, multiple review modes, and a tiered freemium monetization model.
   Features
   Intelligent Photo Analysis: Scans for duplicates, visually similar photos, screenshots, and large video files.
   Dual Review Modes:
   Category Review: A traditional, organized review of photos grouped by category.
   Quick Swipe Review: A fast, Tinder-style swipe interface for rapid decision-making.
   Smart Select: An AI-powered feature (premium) to automatically select the worst photos in a group for deletion.
   Freemium Model:
   Free Tier: Allows full analysis and a daily limit of 15 manual deletions. Supported by banner ads.
   Pro Tiers: Unlocks unlimited deletions, Smart Select, Quick Swipe, and an ad-free experience via monthly, annual, or lifetime subscriptions.
   Dynamic Theming: A fully functional light and dark mode that persists across app sessions.
   Project Setup
   Clone the Repository:
   git clone <your-repo-url>
   cd aura_clean


Install Dependencies:
flutter pub get


Run the App:
flutter run


Project Structure
The project follows the BLoC (Business Logic Component) pattern to ensure a clean separation of concerns.
lib/
├── app/              # Core app setup (routing, theming)
├── blocs/            # All business logic components
├── main.dart         # App entry point
├── models/           # Data models (e.g., PhotoAsset)
├── repositories/     # Data providers (e.g., PhotoRepository)
├── screens/          # All UI screens
└── widgets/          # Reusable UI components


2. Architecture Overview
   Aura Clean is built on a modern, scalable architecture designed for maintainability.
   Data Flow
   The app's data flow is unidirectional and managed by the BLoC pattern:
   UI Event: A user interacts with a screen (e.g., taps the "Analyze Photos" button).
   BLoC Event: The UI dispatches an event to the corresponding BLoC (e.g., StartAnalysisEvent is sent to PhotoCleanerBloc).
   Repository Interaction: The BLoC calls a method in the PhotoRepository to perform the necessary logic (e.g., fetching and analyzing photos).
   BLoC State Emission: The BLoC receives data from the repository and emits a new state (e.g., AnalysisComplete).
   UI Rebuild: The UI listens for state changes and rebuilds itself to reflect the new state (e.g., displaying the summary cards with analysis results).
   Key Architectural Patterns
   BLoC (Business Logic Component): Used to separate UI from business logic. The app contains three main BLoCs:
   PhotoCleanerBloc: Manages all logic related to photo analysis and deletion.
   ThemeBloc: Manages the app's light and dark theme state.
   PurchaseBloc: Manages all in-app purchase logic.
   Repository Pattern: The PhotoRepository abstracts the data source (the device's photo library) from the rest of the app. This makes the BLoCs independent of the specific data-fetching implementation (photo_manager package) and easier to test.
3. State Management (BLoCs)
   PhotoCleanerBloc
   Purpose: Handles the core functionality of analyzing the photo library and deleting selected items.
   Events:
   StartAnalysisEvent: Triggered to begin scanning the user's photos.
   DeleteSelectedPhotosEvent: Triggered to delete a list of user-selected photos.
   States:
   PhotoCleanerInitial: The default state.
   AnalysisInProgress: Emitted while the app is scanning photos.
   AnalysisComplete: Emitted when analysis is done, containing lists of duplicates, similar photos, etc.
   DeletionInProgress: Emitted during the deletion process.
   DeletionSuccess: Emitted after a successful deletion.
   FreeTierLimitReached: Emitted when a free user exceeds the daily deletion limit.
   ThemeBloc
   Purpose: Manages the app's theme and persists the user's choice.
   Events:
   ThemeChanged: Triggered by the dark mode toggle in settings.
   States:
   ThemeState: Contains the current ThemeData (either light or dark).
   PurchaseBloc
   Purpose: Manages all interactions with the in_app_purchase library.
   Events:
   LoadProducts: Fetches available subscription plans from the app stores.
   BuyProduct: Initiates the purchase flow for a selected product.
   RestorePurchases: Restores a user's previous purchases.
   States:
   PurchaseState: Contains the list of available products, the user's premium status (isPremium), and the current purchase status.
4. Monetization & Feature Gating
   The freemium model is enforced throughout the app by checking the isPremium state from the PurchaseBloc.
   Daily Deletion Limit: The PhotoCleanerBloc checks isPremium before processing a DeleteSelectedPhotosEvent. If the user is not premium, it consults shared_preferences to check and update their daily deletion count. If the limit is exceeded, it emits a FreeTierLimitReached state, which triggers a paywall prompt on the UI.
   Gated Features: Premium features like "Quick Swipe" (SwipeReviewScreen) and "Smart Select" are gated directly in the UI. The onPressed callbacks for these features first check the isPremium status. If false, they navigate the user to the PaywallScreen.
   Ads: The DashboardScreen contains a BannerAd. Its visibility is tied to the isPremium status. The ad is only loaded and displayed if the user is not a premium subscriber.
5. Building for Production
   To build and deploy Aura Clean, follow the platform-specific instructions.
   General Requirements
   App Icon: A 1024x1024 pixel app icon.
   Screenshots: Multiple high-quality screenshots for phone and tablet.
   Privacy Policy: A public URL hosting your privacy policy.
   Google Play Store (Android)
   Register: Sign up for a Google Play Developer account ($25 one-time fee).
   Sign the App: Generate a private upload key using keytool and configure android/app/build.gradle to use it for release builds.
   Build the App Bundle:
   flutter build appbundle


Upload to Play Console: Create a new app listing, fill out all the details, and upload the generated .aab file (build/app/outputs/bundle/release/app-release.aab).
Submit for Review.
Apple App Store (iOS)
Register: Enroll in the Apple Developer Program ($99 annual fee).
Configure in Xcode:
Open the project in Xcode (open ios/Runner.xcworkspace).
In "Signing & Capabilities," set your team and a unique Bundle Identifier.
Build the IPA:
flutter build ipa


Upload to App Store Connect: Create a new app listing, fill out all details, and use Xcode or the Transporter app to upload the build archive.
Submit for Review.
