# Universities Browser

A small, production-quality iOS app that lists universities for a country, caches them
locally, and shows a details screen for a selected item. Built with **VIPER + Clean
Architecture**, modularised into local Swift Packages.

The focus is on architecture, modularization, and code quality, not visual polish.

---

## How to run

Requirements: **Xcode 15+** (developed on Xcode 26.3 / Swift 6.2), iOS **15.1+**.

```bash
open UniversitiesBrowser.xcodeproj
# Select the "UniversitiesBrowser" scheme + any iOS Simulator, then ⌘R
```

Or from the command line:

```bash
xcodebuild -project UniversitiesBrowser.xcodeproj \
  -scheme UniversitiesBrowser \
  -destination 'generic/platform=iOS Simulator' \
  build
```

### Running the tests

Each package owns its own unit tests. Pure packages run on the host:

```bash
swift test --package-path Packages/DomainKit
swift test --package-path Packages/NetworkKit
swift test --package-path Packages/PersistenceKit
```

The feature packages link UIKit/SwiftUI, so they run on a simulator:

```bash
cd Packages/ListingFeature && xcodebuild test -scheme ListingFeature \
  -destination 'platform=iOS Simulator,name=iPhone 16'
cd Packages/DetailsFeature && xcodebuild test -scheme DetailsFeature \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

> The `UniversitiesBrowser.xcodeproj` is committed and can be opened directly in Xcode.

---

## Architecture

Clean Architecture in three layers, with each screen implemented as a **VIPER** module.

```
                       ┌──────────────────────────────────────────────┐
   Presentation        │  ListingFeature (VIPER)   DetailsFeature (VIPER)│
   (per-screen VIPER)   │  V·I·P·E·R                V·I·P·E·R            │
                       └───────────────┬──────────────────┬────────────┘
                                       │ depends on        │
                       ┌───────────────▼──────────────────▼────────────┐
   Domain              │  DomainKit: University, UniversityRepository,   │
   (pure, no I/O)       │  FetchUniversitiesUseCase, RefreshSelectedUniversity│
                       └───────────────▲──────────────────▲────────────┘
                                       │ implemented by    │
                       ┌───────────────┴──────────────────┴────────────┐
   Data                │  Composition root: UniversityRepositoryImpl     │
   (app target)         │      ├── NetworkKit  (remote)                  │
                       │      └── PersistenceKit (Core Data cache)      │
                       └────────────────────────────────────────────────┘
```

### VIPER per the brief

- **View**: SwiftUI, hosted inside a `UIViewController` via `UIHostingController`.
- **Interactor**: business logic; talks to the use case. No UIKit.
- **Presenter**: an `ObservableObject` the SwiftUI view observes directly. `@MainActor`,
  publishes a single `state` value (the MVI source of truth for the screen).
- **Entity**: the shared `University` domain model in `DomainKit`.
- **Router**: the only place aware of `UINavigationController`; performs push/pop.

Navigation is **UIKit-driven** (`UINavigationController` push/pop). There is no SwiftUI
`NavigationStack` routing anywhere.

---

## Modules (SPM packages)

| Package | Layer | Responsibility | Depends on |
|---|---|---|---|
| **`DomainKit`** | Domain | `University` entity, `UniversityRepository` protocol, `FetchUniversitiesUseCase` (remote-first / cache-fallback policy), `RefreshSelectedUniversity` hook. Pure Swift, no I/O. | none |
| **`NetworkKit`** | Data | Custom network layer: `HTTPClient` seam, `URLSession` transport, `Endpoint` builder, `APIClient` (status validation + JSON decoding), typed `NetworkError`. Domain-agnostic. | none |
| **`PersistenceKit`** | Data | Local database: programmatic Core Data stack + `UniversityCache` (replace-on-success / read-on-failure). | `DomainKit` |
| **`CommonUI`** | Presentation | Shared SwiftUI states: `LoadingStateView` (shimmer), `ErrorStateView` (retry), `EmptyStateView`. Consumed by both features; no duplication. | none |
| **`ListingFeature`** | Presentation | Module A (VIPER). | `DomainKit`, `CommonUI` |
| **`DetailsFeature`** | Presentation | Module B (VIPER). | `DomainKit`, `CommonUI` |
| **App target** | Composition | Composition root: `UniversityDTO` mapping, `UniversityRemoteDataSource`, `UniversityRepositoryImpl` (the only type that knows both Network + Persistence), DI wiring, `AppDelegate`/`SceneDelegate`. | everything |

The features depend **only on `DomainKit` + `CommonUI`**, never on `NetworkKit`,
`PersistenceKit`, or each other. The concrete repository and all wiring live in the app's
composition root, so each module stays independently buildable and testable.

---

## Navigation & data flow

1. The app launches on the **Listing** screen.
2. Listing fetches from the API and **caches** the result in Core Data.
3. On API failure it **falls back to the cache**; if the cache is empty too, it shows the
   shared `ErrorStateView` with **Try Again**. (Policy lives in `FetchUniversitiesUseCase`.)
4. Selecting a row **pushes Details** via the Router. The selected `University` is **passed
   across the package boundary**, so **Details makes no API call** on entry.
5. Details has a UIKit **Refresh** bar-button. Pressing it triggers a network request
   *owned by Listing* (via the injected `RefreshSelectedUniversity` closure), which:
   - re-fetches from the API and **updates the cache**,
   - **updates the Listing** list, and
   - returns the refreshed selected item so **Details updates** too.
   Details never imports the network layer; it just awaits a closure.

```
Listing.Presenter ──makeRefreshHook(for: selected)──▶ Router ──▶ DetailsBuilder
                                                                    │
Details Refresh tap ──▶ DetailsInteractor ──await hook()──▶ Listing re-fetch + cache
                                                              │
                          updated University ◀────────────────┘ (list + details both refresh)
```

---

## Concurrency

- `async/await` throughout for network and database access.
- Presenters are `@MainActor` `ObservableObject`s, so UI state mutation is always on the main
  actor, and the published `state` is the single source of truth per screen.
- Combine is used in `DetailsViewController` to bind the Presenter's `isRefreshing` to the
  bar-button's spinner.

---

## Testing

24 unit tests covering the parts where the logic lives:

- **DomainKit**: the remote-first / cache-fallback / refresh policy.
- **NetworkKit**: URL/query building, status-code validation, decoding, error mapping
  (against a stubbed `HTTPClient`).
- **PersistenceKit**: cache round-trip, per-country scoping, replace semantics, sorting
  (against an in-memory Core Data store).
- **ListingFeature / DetailsFeature**: presenter state transitions and the refresh wiring
  (against fakes), no real network or DB.

---

## Trade-offs & notes

- **Programmatic Core Data model.** Defined in Swift rather than an `.xcdatamodeld` so the
  package is fully self-contained (no resource bundle to load by name). For a larger schema
  a visual model + migrations would be worth the resource.
- **DTO in the composition root.** `NetworkKit` is deliberately domain-agnostic, so the
  `UniversityDTO` ↔ `University` mapping lives in the app. This keeps the networking package
  reusable; the cost is one small mapping type in the app target.
- **Details = UIViewController + SwiftUI + UIKit Refresh.** The brief states both "Details:
  UIKit `UIViewController` … + Refresh button" and "Module B UI built with SwiftUI". Both are
  honoured: the content is SwiftUI embedded via `UIHostingController`, while Refresh is a
  genuine UIKit `UIBarButtonItem`.
- **HTTP endpoint.** The API is HTTP-only, so `universities.hipolabs.com` is explicitly
  allow-listed in `Info.plist` via an ATS exception rather than disabling ATS globally.
- **Synthetic identity.** The API returns no stable id, so `University.id` is derived from
  `name + country`. This is what lets Details re-resolve its item after a refresh.
