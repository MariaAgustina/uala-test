# SmartCity — iOS

Fast, offline-first city search and map browsing with favorites.

## Tech stack

- **Language & Concurrency:** Swift 6, **Swift Concurrency** (`async/await`)
- **Architecture & Patterns:** **Clean Architecture** (UI → Domain → Data), **MVVM**, DI (composition root)
- **UI:** **SwiftUI** (state-driven, `NavigationStack`, bottom sheets)
- **Maps:** **MapKit** (annotations + clustering)
- **Persistence:** **Core Data** (SQLite) as on-device **source of truth**  
  - Normalized field `nameFolded` (lowercase, no diacritics)  
  - Composite index for prefix queries `(nameFolded, country)`
- **Networking:** **URLSession** (`async/await`), JSON
- **Reactive input:** **Combine** (debounced, cancellable search input)
- **Observability:** Firebase **Analytics** & **Crashlytics**
- **CI/CD:** GitHub Action

> Default minimum deployment target: **iOS 18** (adjust to iOS 17 if needed).

## Requirements

- **Xcode 16.x**
- **iOS 18 simulator** (or iOS 17 if you lower the target)
- Internet access for the initial dataset download (app works offline after first load)

## Getting started

1. **Clone the repository**
   ```bash
   git clone https://github.com/MariaAgustina/uala-test.git
   cd uala-test
   ```
   
## Scope

- **Implemented:** City search with efficient, index-backed prefix queries against the local store.
- **Known TODOs in code:** 
  - Localization (i18n/l10n).
  - Time-based refresh (TTL) for the full dataset request from the server.
- **Not yet implemented:**
  - Add-to-favorites functionality (design documented in the team deliverable under **“Favorites — end to end”**).
  - Improved dynamic UI adaptation for **landscape**.
  - Observability & automation: **Firebase Analytics**, **Crashlytics**, **GitHub Actions** for CI/CD, a structured logging utility, and a more robust networking module (e.g., adopting **Alamofire**).

## Opportunities for improvement

- **To paginate the cities API** to make the dataset scalable as it grows (server paging + client-side incremental loading).

- **To request the user’s location** (When In Use) so the map can recenter on current position at app launch (graceful degradation if denied).

- **To map country codes to human-readable names** (e.g., ISO 3166 → localized display names) so city rows show clear country labels.

- **To improve the refresh mechanism** by moving from a client-side TTL to server-driven freshness via lightweight metadata

- **To add user accounts** so favorites can be stored server-side and synced across devices (survive reinstall, consistent multi-device experience).
