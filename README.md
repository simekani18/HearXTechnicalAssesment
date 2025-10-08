# HearX Technical Assessment

A native iOS hearing test application built with SwiftUI that implements the Digits-in-Noise (DiN) test methodology. This project demonstrates clean architecture principles, SOLID design, and modern iOS development practices.

## Architecture & Design Philosophy

### Clean Architecture Layers

The application is structured into three distinct layers, each with clear responsibilities and boundaries:

#### 1. Core Layer
The foundational layer containing domain-agnostic, reusable services that can be composed for various use cases.

**Audio Module** ([HearX/Core/Audio](HearX/Core/Audio))
- **Thought Process**: Audio playback is a technical concern that shouldn't be mixed with business logic. By abstracting it behind `AudioServiceProtocol`, the implementation can be swapped (e.g., for testing or alternative audio engines) without affecting higher layers.
- **Implementation**: `AVAudioPlayerService` manages audio session configuration, triplet playback sequencing, and precise timing control for the DiN test.
- **Key Design Decision**: Audio players are managed independently for noise and digits, allowing overlapping playback while maintaining precise control over each layer.

**Storage Module** ([HearX/Core/Storage](HearX/Core/Storage))
- **Thought Process**: Persistence is optional (the app works without it), so it's treated as a cross-cutting concern. The protocol-based design allows the feature layer to work with or without storage availability.
- **Implementation**: `CoreDataStorageService` provides CoreData-based persistence for test sessions with sorting and deletion capabilities. Uses a mapping pattern to separate domain models (pure Swift structs) from persistence models (NSManagedObject entities).
- **Key Design Decision**:
  - Storage service is optional throughout the app, gracefully degrading when unavailable rather than crashing.
  - Domain models remain pure Swift structs, completely independent from CoreData, following the Dependency Inversion Principle.
  - `CoreDataStack` manages the persistent container as a singleton, ensuring proper initialization and context management.
  - Mapping layer converts between domain models and CoreData entities, maintaining clean separation of concerns.

**Networking Module** ([HearX/Core/Networking](HearX/Core/Networking))
- **Thought Process**: API communication is an infrastructure concern. Protocol abstraction enables easy mocking for tests and potential API changes without touching business logic.
- **Implementation**: `URLSessionNetworkService` handles HTTP communication with proper error handling and JSON encoding.
- **Key Design Decision**: Network models (`TestResult`, `RoundResult`) are separate from domain models, allowing API changes without affecting the core domain.

**Triplet Generator Module** ([HearX/Core/TripletGenerator](HearX/Core/TripletGenerator))
- **Thought Process**: Triplet generation is pure business logic with specific constraints (no repeats, no same-position digits). Isolating this as a standalone service makes it highly testable and reusable.
- **Implementation**: `RandomTripletGenerator` ensures triplets are unique and validates consecutive triplets don't share digits in the same position.
- **Key Design Decision**: Uses a retry mechanism with a maximum attempt limit to handle edge cases when constraint satisfaction becomes difficult.

#### 2. Features Layer
Contains feature-specific business logic organized by domain boundaries.

**Hearing Test Feature** ([HearX/Features/HearingTest](HearX/Features/HearingTest))
- **Thought Process**: The test workflow is complex (countdown → audio playback → user input → difficulty adjustment → results upload). The Repository pattern coordinates multiple Core services while keeping the ViewModel focused on UI state management.
- **Architecture**:
  - **ViewModel** ([HearingTestViewModel.swift](HearX/Features/HearingTest/ViewModels/HearingTestViewModel.swift:1)): Manages UI state, user interactions, and test flow. Single Responsibility: UI state management.
  - **Repository** ([HearingTestRepository.swift](HearX/Features/HearingTest/Repositories/HearingTestRepository.swift:1)): Coordinates Core services (audio, triplet generation, networking, storage). Single Responsibility: orchestrating domain operations.
  - **Models**: Domain-specific models (`TestState`, `Round`) that represent the test workflow.
- **Key Design Decision**: Difficulty adjustment is handled in the ViewModel since it's part of the test flow logic, while audio/network operations are delegated to the repository.

**History Feature** ([HearX/Features/History](HearX/Features/History))
- **Thought Process**: Session history is a separate feature with its own data access patterns. Isolating it prevents coupling with the active test feature.
- **Architecture**: Similar MVVM + Repository pattern for consistency, with focused responsibility on historical data retrieval and deletion.

**Home Feature** ([HearX/Features/Home](HearX/Features/Home))
- **Thought Process**: Navigation hub that composes other features. Minimal business logic, focused on routing.

#### 3. Application Layer
Root-level composition and dependency injection.

**HearXApp** ([HearXApp.swift](HearX/HearXApp.swift:1))
- **Thought Process**: Dependency Injection at the app entry point ensures all dependencies are created once and injected down. This follows the Dependency Inversion Principle (depend on abstractions, not concretions).
- **Key Design Decision**: All services are instantiated here and injected into repositories, which are then injected into ViewModels. This creates a clear dependency graph and makes testing easier.

### SOLID Principles Implementation

**Single Responsibility Principle**
- Each service has one reason to change: `AVAudioPlayerService` changes only for audio playback logic, `URLSessionNetworkService` only for network concerns.
- ViewModels manage UI state; Repositories coordinate services; Services handle specific technical concerns.

**Open/Closed Principle**
- Protocol-based architecture allows extending behavior without modifying existing code.
- Example: Adding a new storage provider (e.g., CloudKit) only requires implementing `StorageServiceProtocol`.

**Liskov Substitution Principle**
- Any implementation of `AudioServiceProtocol` can replace `AVAudioPlayerService` without breaking the `HearingTestRepository`.
- Mock implementations in tests prove this substitutability.

**Interface Segregation Principle**
- Protocols are focused: `TripletGeneratorProtocol` only exposes triplet generation; `StorageServiceProtocol` only exposes persistence operations.
- Clients depend only on the methods they use.

**Dependency Inversion Principle**
- High-level modules (ViewModels, Repositories) depend on abstractions (Protocols), not concrete implementations.
- All Core services are injected via protocols, making the system flexible and testable.

### Design Patterns

**Repository Pattern**
- Repositories abstract data access and service coordination from ViewModels
- Provides a clean API for feature-specific operations while hiding infrastructure complexity

**Data Mapper Pattern**
- Separate domain models (pure Swift structs) from persistence models (CoreData entities)
- Mapping layer in `CoreDataStorageService` handles conversion between layers
- Maintains persistence independence in the domain layer

**Dependency Injection**
- Constructor injection throughout the app
- Enables testing with mock implementations
- Creates explicit, traceable dependency graphs

**Protocol-Oriented Programming**
- Swift's protocol-first approach for abstraction
- Enables compile-time polymorphism and clear contracts

**MVVM (Model-View-ViewModel)**
- ViewModels are `@MainActor` bounded, ensuring UI updates happen on the main thread
- `@Published` properties drive reactive UI updates
- Clear separation between view logic and business logic

### Testing Strategy

**Unit Tests** ([UnitTests/](UnitTests/))
- Mock implementations for all protocols enable isolated unit testing
- ViewModels and repositories are tested independently
- Tests verify business logic without touching infrastructure (no actual network calls, no real audio playback)

### Key Technical Decisions

1. **SwiftUI + CoreData**: Modern declarative UI with proven persistence framework for iOS 15+ compatibility
2. **Async/Await**: All asynchronous operations use structured concurrency for clarity and safety
3. **@MainActor**: UI components and ViewModels are main-actor bounded to prevent threading issues
4. **Protocol Abstraction**: Every service has a protocol to enable testing and flexibility
5. **Optional Storage**: The app gracefully handles storage unavailability rather than requiring it
6. **Validation**: Audio asset validation on app launch ensures audio files are present and accessible

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.0+

## Project Structure

```
HearX/
├── Core/                          # Reusable infrastructure services
│   ├── Audio/                    # Audio playback management
│   ├── Networking/               # API communication
│   ├── Storage/                  # Local persistence with CoreData
│   └── TripletGenerator/         # Triplet generation logic
├── Features/                      # Feature modules
│   ├── HearingTest/              # DiN test implementation
│   ├── History/                  # Test history viewing
│   └── Home/                     # Navigation hub
├── Resources/                     # Audio assets and resources
└── HearXApp.swift                # App entry point and DI

UnitTests/                         # Unit tests with mocks
├── Mocks/                        # Protocol mock implementations
├── ViewModels/                   # ViewModel tests
└── Models/                       # Model tests
```

## Installation

1. Clone the repository
   ```bash
   git clone <repository-url>
   cd HearXTechnicalAssesment
   ```
2. Open `HearX.xcodeproj` in Xcode
3. Select a target device or simulator (iOS 15.0+)
4. Build and run the project (⌘R)

## Running Tests

1. Open the project in Xcode
2. Press ⌘U to run all unit tests
3. View test results in the Test Navigator (⌘6)

## Features

- **Adaptive Difficulty**: Difficulty adjusts based on user performance (1-10 scale)
- **Audio Playback**: Precise timing control for noise and digit playback
- **Session Persistence**: Optional local storage of test results using CoreData with mapping pattern
- **Results Upload**: Automatic upload of test results to remote API
- **Test History**: View and manage past test sessions (sort by score/date, swipe to delete)
- **Graceful Degradation**: App functions even if storage or network is unavailable
- **Audio Validation**: Startup validation ensures all required audio files are present

## Technical Highlights

### CoreData Implementation
- **Mapping Pattern**: Domain models remain pure Swift structs, completely independent from persistence
- **Entity Separation**: `TestSessionEntity` and `StoredRoundEntity` handle persistence
- **Context Management**: `CoreDataStack` manages persistent container and contexts
- **Migration Ready**: Clean separation allows easy persistence layer swapping

### Concurrency
- **Structured Concurrency**: All async operations use async/await
- **Main Actor**: UI-related code properly bounded to main thread
- **Background Operations**: Audio playback and network calls run asynchronously

### Error Handling
- **Typed Errors**: Domain-specific error types (`AudioError`, `StorageError`, `NetworkError`)
- **Graceful Failures**: App continues functioning when non-critical services fail
- **User Feedback**: Clear error messages presented to users

## License

This is a technical assessment project for HearX.
