```mermaid
flowchart LR

A[Download NPPES CSV data] --> B[Create Django project and providers app]
B --> C[Design database models]
C --> D[Create and run migrations]

D --> E[Import taxonomy codes]
E --> F[Import provider records]
F --> G[Link providers to taxonomy codes]

G --> H[Add database indexes]
H --> I[Implement serializers]
I --> J[Implement views and search logic]

J --> K[Create HTML search page and results template]
K --> L[Add pagination and performance optimizations]

L --> M[Redesign UI]
M --> N[Fix gitignore and remove large files]

N --> O[Push final project to GitHub]
```
