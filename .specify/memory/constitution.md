# Red Panda Tracker Constitution

## Core Principles

### I. User-Centric Wildlife Tracking
Every feature must prioritize user engagement in red panda conservation. Features must directly support wildlife observation, tracking, and data collection activities. Features should be intuitive for both casual users and wildlife professionals.

### II. Data Integrity and Persistence
All tracked data must be reliably persisted locally using Hive database. Data synchronization must handle offline scenarios gracefully. User data is sacred—no data loss is acceptable. Complete audit trails for all observations.

### III. Mobile-First Responsive Design
Application must work flawlessly on iOS and Android. UI must be responsive and accessible. Fast load times and smooth animations required. Support both light and dark themes using Material Design 3.

### IV. Test-First Development (NON-NEGOTIABLE)
TDD mandatory: Widget tests → User approval → Tests fail → Implementation. Unit tests for business logic, widget tests for UI, integration tests for data persistence. Red-Green-Refactor cycle strictly enforced. Aim for >80% code coverage.

### V. Clean Architecture
Separation of concerns: UI layer, business logic layer, data layer. Provider pattern for state management. Clear dependency injection. Testable components at every level.

## Technology Stack & Constraints

- **Framework**: Flutter (stable channel, Dart 3.10+)
- **State Management**: Provider for simplicity and testability
- **Local Database**: Hive for offline-first data persistence
- **UI**: Material Design 3, Google Fonts
- **Target Platforms**: iOS 12.0+, Android 5.0+
- **Development Environment**: Spec-Driven Development workflow

## Development Workflow

1. **Specification Phase**: Define features using Spec-Driven Development
2. **Planning Phase**: Create technical implementation plans aligned with Flutter best practices
3. **Task Breakdown**: Atomize work into testable, independently reviewable units
4. **Implementation**: Follow TDD rigorously; tests must pass before feature completion
5. **Quality Gates**: Code review, test coverage verification, performance validation

## Quality Standards

- **Code Style**: Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- **Testing**: Every feature requires tests; no exceptions
- **Performance**: App startup <2s, list scrolling at 60 FPS minimum
- **Accessibility**: Support screen readers, high contrast modes
- **Documentation**: Code comments for complex logic; README for setup

## Governance

Constitution supersedes all other practices. All PRs must verify compliance with these principles. Complexity must be justified with business value. Use Spec-Kit memory artifacts for runtime development guidance.

**Version**: 1.0.0 | **Ratified**: 2026-01-04 | **Last Amended**: 2026-01-04
