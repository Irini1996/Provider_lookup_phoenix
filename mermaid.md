```mermaid
flowchart TD

A[Download NPPES CSV data] --> B[Create Django project & providers app]

B --> C[Design database models\nProvider, Taxonomy, ProviderTaxonomy]
C --> D[Create and run migrations\nPostgreSQL schema]

D --> E[Import taxonomy codes\nfrom CSV]
E --> F[Import provider records\n(batch loading)]
F --> G[Link providers to taxonomy codes]

G --> H[Update provider addresses\nwith cleaned data]
H --> I[Add database indexes\nNPI, name, taxonomy, ZIP, state]

I --> J[Implement serializers]
J --> K[Implement views & search logic]

K --> L[Create HTML search page\nand results template]
L --> M[Add pagination & performance optimizations]

M --> N[Redesign UI\ngradients, layout, colours]
N --> O[Fix .gitignore & remove large files]

O --> P[Push final project to GitHub]
```
