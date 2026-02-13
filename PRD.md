Here are concrete, buildable specs for the “UAE SME Invoice Copilot” project: a multi-tenant web app that ingests invoices/receipts/contracts, extracts structured fields, indexes content for search, and provides a chat/Q&A experience over the user’s own documents using RAG. It’s designed to map tightly to AI-102 skills like Azure AI Search (including semantic/vector) and Azure Document Intelligence. [learn.microsoft](https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/ai-102)

## Product scope
Target users: UAE SMEs (owner, accountant) who handle high document volume and want faster bookkeeping, validation, and retrieval.  
Core outcomes: (1) reliable field extraction, (2) searchable knowledge base, (3) “ask my documents” chat, (4) audit trail + export.

## Functional requirements
- Tenant management: org signup, users/roles (Owner, Accountant, Viewer), per-tenant data isolation.  
- Document intake: upload PDF/JPG/PNG; store original + processing status; support re-processing.  
- Extraction: run Azure Document Intelligence prebuilt invoice/receipt model first; allow “custom model” option as a stretch goal (training set + labeling). [learn.microsoft](https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/ai-102)
- Validation UI: show extracted fields (vendor, invoice no, date, line items, totals, currency, tax/VAT) with confidence scores and manual correction.  
- Knowledge mining: index full text + key fields into Azure AI Search; support filters (vendor/date/amount) and semantic + vector retrieval for RAG. [learn.microsoft](https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/ai-102)
- Chat (RAG): “Ask questions about my docs” (e.g., “Show unpaid invoices last 30 days”, “What VAT did we pay in Q4?”) with citations to the source documents/chunks returned from AI Search. [learn.microsoft](https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/ai-102)
- Exports: CSV + “accounting package friendly” export (simple schema) per month/quarter; optional PDF summary.  
- Audit trail: immutable log of uploads, extraction runs, corrections, and exports (who/when/what changed).

## Architecture and Azure services
- Frontend: React (portal, upload, validation grid, chat UI).  
- Core API: ASP.NET Core (.NET) REST API for auth, tenants, billing, document metadata, exports.  
- Storage: Azure Blob Storage for raw files + derived artifacts (OCR text, JSON extraction results).  
- Async pipeline: Azure Service Bus queue + Azure Functions workers (or WebJobs) for “upload → extract → index → notify”, using Service Bus queue triggers for reliable background processing. [learn.microsoft](https://learn.microsoft.com/en-us/azure/azure-functions/functions-bindings-service-bus-trigger)
- AI services:  
  - Azure AI Document Intelligence for structured extraction from invoices/receipts and (later) custom models. [learn.microsoft](https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/ai-102)
  - Azure AI Search for indexing, filtering, and semantic/vector retrieval feeding RAG. [learn.microsoft](https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/ai-102)
  - Azure OpenAI for answer generation grounded on retrieved chunks from AI Search. [learn.microsoft](https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/ai-102)
- Observability: Application Insights + structured logging; per-tenant metrics (docs processed, avg latency, cost estimate).

## Data model and APIs (minimum)

Tables (Azure Database for PostgreSQL)

- Tenants
  - `TenantId` (uuid, PK): unique tenant identifier for multi-tenancy and FK relationships.
  - `Name` (varchar(200)): organization/tenant display name.
  - `Plan` (varchar(50) or enum): subscription tier (free/pro/enterprise).
  - `CreatedAt` (timestamptz): creation timestamp.
  - `DeletedAt` (timestamptz, nullable): soft-delete marker (optional).

- Users
  - `UserId` (uuid, PK): unique user id.
  - `TenantId` (uuid, FK -> Tenants.TenantId): tenant ownership; used for RLS.
  - `Email` (varchar(320)): login email, unique per tenant.
  - `Role` (varchar(20) or enum): `Owner` / `Accountant` / `Viewer` — authorization role.
  - `PasswordHash` (text, nullable) OR `EntraId` (varchar, nullable): local credential or external identity reference.
  - `DisplayName` (varchar(200), nullable): UI name.
  - `CreatedAt` (timestamptz) and `LastLoginAt` (timestamptz, nullable).

- Documents
  - `DocumentId` (uuid, PK): unique document id.
  - `TenantId` (uuid, FK): owner tenant.
  - `BlobUri` (text): canonical blob URL for original file.
  - `FileHash` (varchar(128)): content hash (e.g., SHA256) for dedupe and integrity.
  - `Type` (varchar(50) or enum): `Invoice` / `Receipt` / `PurchaseOrder` / `Other`.
  - `Status` (varchar(30) or enum): `Uploaded` / `Queued` / `Processing` / `Extracted` / `Failed`.
  - `UploadedBy` (uuid, FK -> Users.UserId, nullable) and `UploadedAt` (timestamptz).
  - `Pages` (int, nullable), `TextUri` (text, nullable) for OCR/plaintext, `SizeBytes` (bigint, nullable) — size of original file in bytes.

- Extractions
  - `ExtractionId` (uuid, PK): unique extraction run id.
  - `DocumentId` (uuid, FK -> Documents.DocumentId).
  - `ModelVersion` (varchar(100)): model id/version used for extraction.
  - `RawJsonUri` (text): blob URI to raw extraction JSON (Document Intelligence output).
  - `Confidence` (numeric(5,4) or real, nullable): overall extraction confidence (0..1).
  - `CompletedAt` (timestamptz, nullable) and `Status` (enum: `success`/`partial`/`failed`).
  - `Errors` (jsonb, nullable) and `ProcessedBy` (varchar, nullable).

- InvoiceFields
  - `DocumentId` (uuid, PK, FK -> Documents.DocumentId): one-to-one for invoice-like docs.
  - `VendorName` (text, nullable) and `VendorTaxId` (varchar(100), nullable).
  - `InvoiceNumber` (varchar(100), nullable).
  - `InvoiceDate` (date or timestamptz, nullable) and `DueDate` (date, nullable).
  - `Subtotal` / `Tax` / `Total` (numeric(18,2), nullable) and `Currency` (char(3)).
  - `PaymentStatus` (varchar(20) or enum): `unpaid` / `paid` / `partially_paid` / `overdue`.
  - `PaymentTerms` (varchar(200), nullable).
  - `RawConfidence` (jsonb, nullable): per-field confidence scores.
  - `CorrectedBy` (uuid, nullable) and `CorrectedAt` (timestamptz, nullable) for manual edits.

- LineItems
  - `LineItemId` (uuid, PK).
  - `DocumentId` (uuid, FK -> InvoiceFields.DocumentId).
  - `Description` (text), `Qty` (numeric or int), `UnitPrice` (numeric(18,4)), `Amount` (numeric(18,2)).
  - `TaxAmount` (numeric(18,2), nullable), `Sequence` (int), `Confidence` (real, nullable).

- AuditEvents
  - `EventId` (bigserial or uuid, PK): unique audit id.
  - `TenantId` (uuid, nullable) and `UserId` (uuid, nullable).
  - `DocumentId` (uuid, nullable).
  - `EventType` (varchar(100) or enum): e.g., `upload`, `extraction.started`, `extraction.completed`, `correction`, `export.generated`.
  - `EventDataJson` (jsonb): structured payload (previous values, diff, reason).
  - `CreatedAt` (timestamptz) and `Immutable` (boolean, default true) for retention.

Notes & constraints

- Use Postgres `uuid` PKs (e.g., `gen_random_uuid()`); consider `jsonb` for flexible AI outputs.
- Currency/amounts: `numeric(18,2)` for monetary values; store ISO currency in `char(3)`.
- Indexes: add indexes on `TenantId`, `DocumentId`, `UploadedAt`, and `Status` for queries.
- Partial indexes for common filters (e.g., unpaid invoices) improve performance.
- Row-level security (RLS) + application-enforced `TenantId` is recommended for multi-tenancy.
- Store raw extraction artifacts off-DB (`RawJsonUri`) to keep DB size small; keep `jsonb` extracts only when rich queries are needed.
- AuditEvents should be append-only; consider immutability and encryption-at-rest for sensitive data.

API endpoints (minimum)

- `POST /api/documents` — Upload a file; returns `DocumentId` and initial `Status`.
- `GET /api/documents?filters…` — List documents with metadata and filter options (tenant-scoped).
- `GET /api/documents/{id}` — Document details: metadata, latest `Extraction`, `InvoiceFields`, `LineItems` and correction history.
- `POST /api/documents/{id}/reprocess` — Enqueue document for re-extraction/re-indexing.
- `POST /api/chat` — Question payload (user + tenant context); returns answer, citations, and referenced documents.
- `GET /api/exports/monthly?yyyy-mm=…` — Generate/download CSV or accounting-friendly export for a tenant.


## MVP build order (2–4 weeks)
1) Upload + blob storage + document status tracking.  
2) Service Bus + Function worker pipeline (extract + persist results). [learn.microsoft](https://learn.microsoft.com/en-us/azure/azure-functions/functions-bindings-service-bus-trigger)
3) Validation UI (editable fields) + export CSV.  
4) Azure AI Search indexing + basic keyword search. [learn.microsoft](https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/ai-102)
5) RAG chat using AI Search retrieval + Azure OpenAI response with source citations. [learn.microsoft](https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/ai-102)

Stretch goals (to stand out in UAE interviews)
- Custom Document Intelligence model for “local supplier templates” + composed model routing. [learn.microsoft](https://learn.microsoft.com/en-us/credentials/certifications/resources/study-guides/ai-102)
- Role-based access + per-tenant encryption keys, private endpoints/VNet integration.  
- Multi-language: Arabic/English UI and query handling (store original + translated snippets).  
- “Anomaly & fraud hints”: duplicate invoice detection, outlier totals per vendor, suspicious bank details changes.
