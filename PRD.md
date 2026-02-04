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
Tables (Azure Database for PostgreSQL):
- Tenants(TenantId, Name, Plan, CreatedAt)  
- Users(UserId, TenantId, Email, Role, PasswordHash/EntraId)  
- Documents(DocumentId, TenantId, BlobUri, FileHash, Type, Status, UploadedBy, UploadedAt)  
- Extractions(ExtractionId, DocumentId, ModelVersion, RawJsonUri, Confidence, CompletedAt)  
- InvoiceFields(DocumentId, VendorName, InvoiceNumber, InvoiceDate, Subtotal, Tax, Total, Currency, PaymentStatus, …)  
- LineItems(LineItemId, DocumentId, Description, Qty, UnitPrice, Amount)  
- AuditEvents(EventId, TenantId, UserId, DocumentId, EventType, EventDataJson, CreatedAt)

API endpoints:
- POST /api/documents (upload, returns DocumentId)  
- GET /api/documents?filters… (list/search metadata)  
- GET /api/documents/{id} (details + extraction + corrections)  
- POST /api/documents/{id}/reprocess (enqueue pipeline)  
- POST /api/chat (question, returns answer + citations + document references)  
- GET /api/exports/monthly?yyyy-mm=… (download CSV)

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
