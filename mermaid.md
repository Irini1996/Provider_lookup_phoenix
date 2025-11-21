# Provider-Lookup
```mermaid
flowchart LR

%% Step 1: Download raw NPPES dataset
A[Download NPPES CSV data] --> B[Create Django project and providers app]

%% Step 2: Start the Django project structure
B --> C[Design database models]

%% Step 3: Prepare PostgreSQL schemas and run migrations
C --> D[Create and run migrations]

%% Step 4: Import taxonomy codes from NUCC CSV
D --> E[Import taxonomy codes]

%% Step 5: Import NPPES provider records (massive dataset)
E --> F[Import provider records]

%% Step 6: Link provider entries with taxonomy codes
F --> G[Link providers to taxonomy codes]

%% Step 7: Add essential indexes to optimize queries
G --> H[Add database indexes]

%% Step 8: Create serializers (DRF or Django-native)
H --> I[Implement serializers]

%% Step 9: Create views and search logic (filtering, lookup)
I --> J[Implement views and search logic]

%% Step 10: Build UI for searching providers
J --> K[Create HTML search page and results template]

%% Step 11: Add pagination + optimize query performance
K --> L[Add pagination and performance optimizations]

%% Step 12: Improve design (UI/UX)
L --> M[Redesign UI]

%% Step 13: Clean up repository
M --> N[Fix gitignore and remove large files]

%% Step 14: Final push to GitHub
N --> O[Push final project to GitHub]
```
