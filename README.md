# Welcome To Team7C's SETaP Coursework

A task management tool to help with the running and coordination of projects, and tasks within them.

- Frontend: Flutter/Dart
- Backend: Flask/Postgres

## Installation

1. Clone the repository
2. `cd` into the directory
3. Run `flutter run`

**Note**: You also need to download and install the backend.

## Project Structure

* **Feature-first folders**: Each functionality (login, tasks, kanban, etc.) has its own directory
* **Technical components**: Models, services, and providers in dedicated folders
* **Shared elements**: Common widgets and utilities centralized in the shared folder
* **Offline support**: Mock data available when no connection is detected

### Exploring the project:

```
Team7CIteration2/
│
├── lib/                      # Main application code
│   ├── main.dart             # Entry point
│   ├── chat/                 # Chat functionality
│   ├── contribution_report/  # Contribution tracking
│   ├── home/                 # Home screen
│   ├── kanban/               # Kanban board views
│   ├── login/                # Login screens
│   ├── models/               # Data models
│   ├── services/             # API services
│   ├── shared/               # Shared components
│   └── [other feature folders]
│
├── assets/                   # Static resources
└── database/                 # SQL files and schema
```

**Commenting**: Project-wide commenting style has been adopted for easy understanding of the code. Concise comments are paired with additional details in square brackets where useful.

