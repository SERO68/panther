# Project Reorganization Plan

## Current Structure Analysis

The current project structure has several issues:

1. Inconsistent naming conventions (mixed case in folder names like `Ui`, `Data`, `Routes`)
2. Lack of clear separation between features and core functionality
3. Connection-related code is scattered across different directories
4. No clear organization for services, models, and UI components

## Proposed Structure

```
lib/
├── core/                  # Core functionality used across the app
│   ├── constants/         # App-wide constants
│   ├── routes/            # Navigation and routing
│   ├── theme/             # App theme and styling
│   └── utils/             # Utility functions
│
├── data/                  # Data layer
│   ├── models/            # Data models
│   ├── repositories/      # Data repositories
│   └── services/          # Services for external communication
│       └── socket/        # Socket connection services
│
├── features/              # Feature modules
│   ├── connection/        # Connection feature
│   │   ├── screens/       # Connection screens
│   │   └── widgets/       # Connection-specific widgets
│   ├── control/           # Robot control feature
│   │   ├── screens/       # Control screens
│   │   └── widgets/       # Control-specific widgets
│   └── home/              # Home feature
│       ├── screens/       # Home screens
│       └── widgets/       # Home-specific widgets
│
├── shared/                # Shared components
│   └── widgets/           # Reusable widgets used across features
│
└── main.dart             # App entry point
```

## Implementation Steps

1. Create the new directory structure
2. Move files to their appropriate locations
3. Update import paths in all files
4. Ensure consistent naming conventions
5. Test the application to ensure everything works correctly

## Benefits of New Structure

- **Feature-based organization**: Related code is grouped together
- **Improved maintainability**: Clear separation of concerns
- **Better scalability**: Easy to add new features
- **Consistent naming**: Follows Flutter community best practices
- **Clear dependencies**: Dependencies between modules are explicit