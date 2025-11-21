```mermaid
flowchart TD

A[Download NPPES CSV data] --> B[Create Django project & providers app]

B --> C[Design database models<br/>Provider, Taxonomy, ProviderTaxonomy]
C --> D[Create and run migrations<br/>PostgreSQL schema]

D --> E[Import taxonomy codes<br/>from CSV]
E --> F[Import provider records<br/>(batch loading)]
F --> G[Link providers to taxonomy codes]

G --> H[Update provider addresses<br/>with cleaned data]
H --> I[Add database indexes<br/>NPI, name, taxonomy, ZIP, state]

I --> J[Implement serializers]
J --> K[Implement views & search logic]

K --> L[Create HTML search page<br/>and results template]
L --> M[Add pagination & performance optimizations]

M --> N[Redesign UI<br/>gradients, layout, colours]
N --> O[Fix .gitignore & remove large files]

O --> P[Push final project to GitHub]
```
