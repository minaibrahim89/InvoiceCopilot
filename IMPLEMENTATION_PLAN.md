# UAE SME Invoice Copilot - Implementation Plan

## Overview
Build a multi-tenant web app that lets UAE SMEs upload invoices, extract key data, search documents, and ask questions about them using AI.

**Target Timeline:** 2-4 weeks for MVP  
**Tech Stack:** React (frontend) + ASP.NET Core (backend) + Azure Services

---

## Phase 0: Foundation & Setup (Week 1 - Start Here!)

### A. Infrastructure & Azure Services Setup
- [ ] Create Azure resource group for the project
- [ ] Set up Azure Database for PostgreSQL for tenant/user/document data
- [ ] Create Azure Blob Storage account for document files
- [ ] Set up Azure Service Bus (queue for async processing)
- [ ] Create Azure Functions project or WebJobs for workers
- [ ] Create Application Insights for monitoring/logging
- [ ] Set up Azure Document Intelligence resource
- [ ] Set up Azure AI Search resource
- [ ] Set up Azure OpenAI resource

### B. Project Scaffolding
- [ ] Create ASP.NET Core Web API project
- [ ] Create Angular project structure
- [ ] Set up code repository (Git)
- [ ] Configure environment/config files for dev/staging/prod
- [ ] Set up authentication (Azure Entra ID or OAuth)

### C. Database Design
- [ ] Create SQL scripts for tables:
  - `Tenants` (TenantId, Name, Plan, CreatedAt)
  - `Users` (UserId, TenantId, Email, Role, PasswordHash, CreatedAt)
  - `Documents` (DocumentId, TenantId, BlobUri, FileHash, Type, Status, UploadedBy, UploadedAt)
  - `Extractions` (ExtractionId, DocumentId, ModelVersion, RawJsonUri, Confidence, CompletedAt)
  - `InvoiceFields` (DocumentId, VendorName, InvoiceNumber, InvoiceDate, Subtotal, Tax, Total, Currency, PaymentStatus, etc.)
  - `LineItems` (LineItemId, DocumentId, Description, Qty, UnitPrice, Amount)
  - `AuditEvents` (EventId, TenantId, UserId, DocumentId, EventType, EventDataJson, CreatedAt)
- [ ] Create indexes for performance (TenantId, DocumentId, Status)
- [ ] Apply migrations to Azure Database for PostgreSQL

---

## Phase 1: Document Upload & Storage (Week 1-2)

### A. Backend API - Upload Endpoint
- [ ] Create `POST /api/documents` endpoint
- [ ] Implement file validation (PDF, JPG, PNG only)
- [ ] Add tenant/user authentication check
- [ ] Upload file to Azure Blob Storage
- [ ] Calculate file hash (for deduplication)
- [ ] Create Document record in DB with Status = "Uploaded"
- [ ] Return DocumentId to frontend

### B. Document Tracking
- [ ] Create `GET /api/documents` endpoint with filters (tenant, date, status)
- [ ] Create `GET /api/documents/{id}` endpoint
- [ ] Add sorting/pagination support

### C. Frontend - Upload UI
- [ ] Create file upload component (drag-and-drop)
- [ ] Show upload progress
- [ ] Display list of uploaded documents with status
- [ ] Add error handling/messages

---

## Phase 2: Async Extraction Pipeline (Week 2)

### A. Service Bus Queue Setup
- [ ] Create Service Bus queue for document processing
- [ ] Configure connection strings in backend

### B. Backend - Queue Producer
- [ ] Modify upload endpoint to enqueue document for processing
- [ ] Update Document Status to "Queued"

### C. Azure Function Worker
- [ ] Create Azure Function triggered by Service Bus queue
- [ ] Implement Document Intelligence API call:
  - Call prebuilt Invoice model (if invoice)
  - Call prebuilt Receipt model (if receipt)
  - Get structured JSON response (vendor, invoice #, date, line items, total, tax, etc.)
- [ ] Store raw extraction JSON to Blob Storage
- [ ] Create Extractions DB record
- [ ] Create/update InvoiceFields DB record with extracted values
- [ ] Update Document Status to "Extracted"
- [ ] Handle errors gracefully (logs, retry logic)
- [ ] Send completion event/notification to frontend

### D. Supporting Infrastructure
- [ ] Add Application Insights logging throughout pipeline
- [ ] Create retry policy for Function (e.g., 3 retries with exponential backoff)

---

## Phase 3: Validation & Correction UI (Week 2-3)

### A. Backend - Correction Endpoint
- [ ] Create `POST /api/documents/{id}/corrections` endpoint
- [ ] Accept manual field corrections from user
- [ ] Update InvoiceFields table with corrected values
- [ ] Create AuditEvent record (who changed what, when)
- [ ] Track confidence scores vs. actual

### B. Backend - Re-processing
- [ ] Create `POST /api/documents/{id}/reprocess` endpoint
- [ ] Re-enqueue document to process with latest model

### C. Frontend - Validation Grid
- [ ] Create editable form/grid to show extracted fields:
  - Vendor Name
  - Invoice Number
  - Invoice Date
  - Line Items (Description, Qty, Unit Price, Amount)
  - Subtotal, Tax, Total
  - Currency
  - Payment Status
- [ ] Show confidence scores (color-coded: high/medium/low)
- [ ] Allow inline editing of fields
- [ ] Add "Save" button to submit corrections
- [ ] Show audit trail of who made changes

---

## Phase 4: Knowledge Mining & Search (Week 3)

### A. Azure AI Search Setup
- [ ] Create Azure AI Search index with fields:
  - documentId (filterable)
  - tenantId (filterable)
  - content (full text, searchable)
  - vendorName (filterable)
  - invoiceNumber (filterable)
  - invoiceDate (filterable)
  - amount (filterable, sortable)
  - uploadDate (filterable)
  - source (for citations)
- [ ] Configure semantic search
- [ ] Configure vector embeddings (optional, for better similarity)

### B. Backend - Indexing Pipeline
- [ ] Create Function to push extracted data + OCR text to AI Search
- [ ] Index Document and LineItem data
- [ ] Update Document Status to "Indexed"

### C. Frontend - Search UI
- [ ] Create search bar component
- [ ] Show filters (vendor, date range, amount range)
- [ ] Display search results with highlights
- [ ] Link results to document detail page

### D. Backend - Search API
- [ ] Create `GET /api/search?query=...&filters...` endpoint
- [ ] Support keyword search via AI Search
- [ ] Support filter combinations
- [ ] Return paginated results with document metadata

---

## Phase 5: RAG Chat Interface (Week 3-4)

### A. Backend - Chat Endpoint  
- [ ] Create `POST /api/chat` endpoint
- [ ] Accept user question + tenantId
- [ ] Query Azure AI Search with user question (retrieval)
- [ ] Get top-K relevant chunks/documents (e.g., top 5)
- [ ] Call Azure OpenAI with question + retrieved context in prompt
- [ ] Parse response and extract citations
- [ ] Return answer + document references + source links

### B. Chat Logic
- [ ] Implement prompt engineering:
  - System message: "You are a helpful assistant for invoice questions. Answer based only on the provided documents."
  - User question + retrieved context
- [ ] Track citations back to source documents
- [ ] Handle edge cases (no results, ambiguous questions)
- [ ] Add streaming response (optional enhancement)

### C. Frontend - Chat UI
- [ ] Create chat interface (message history)
- [ ] Input field for questions
- [ ] Display AI responses with source citations
- [ ] Show linked documents/chunks below each answer
- [ ] Add loading/error states

---

## Phase 6: Exports & Reports (Week 4)

### A. Backend - Export Endpoints
- [ ] Create `GET /api/exports/monthly?yyyy-mm=...` endpoint
- [ ] Build CSV export:
  - Headers: InvoiceNumber, VendorName, InvoiceDate, Amount, Tax, Total, Currency, PaymentStatus
  - Rows: one per document in the month
- [ ] Create "accounting package friendly" export (possibly JSON or same CSV format)
- [ ] Support optional PDF summary (stretch goal)

### B. Backend - Audit Trail  
- [ ] Ensure all AuditEvents are created for:
  - Upload
  - Extraction run
  - Field correction
  - Export
  - Re-processing
- [ ] Create `GET /api/audits?tenantId=...&filters...` endpoint
- [ ] Show immutable log in frontend (optional)

### C. Frontend - Export UI
- [ ] Add export button on dashboard
- [ ] Allow user to select month/quarter
- [ ] Trigger download of CSV

---

## Phase 7: Multi-Tenancy & RBAC (Throughout, Emphasize Now)

### A. Authentication & Authorization
- [ ] Ensure all endpoints validate TenantId from JWT token
- [ ] Implement tenant isolation (users only see their tenant's data)
- [ ] Create role checks:
  - Owner: full access
  - Accountant: upload, view, correct, export
  - Viewer: view only

### B. Signup Flow (Basic)
- [ ] Create `POST /api/auth/signup` endpoint
- [ ] Create first user + Tenant record
- [ ] Set user role to "Owner"

### C. User Management
- [ ] Create `POST /api/users` endpoint (Owner only)
- [ ] Allow inviting Accountant/Viewer users
- [ ] Implement role assignment

---

## Phase 8: Monitoring & Observability

### A. Logging
- [ ] Add structured logging to Backend API (Serilog to Application Insights)
- [ ] Add logging to Azure Functions
- [ ] Include: timestamp, userId, tenantId, operation, status, duration

### B. Metrics & Alerts
- [ ] Track documents processed per tenant
- [ ] Track average extraction latency
- [ ] Track chat query response time
- [ ] Set alerts for errors/failures in pipeline

### C. Cost Estimation
- [ ] Add cost calculation per tenant (Document Intelligence calls, indexing, OpenAI tokens)
- [ ] Display estimated costs in dashboard (stretch goal)

---

## Stretch Goals (If Time Permits)

- [ ] Custom Document Intelligence model for local supplier templates
- [ ] Role-based access with per-tenant encryption keys
- [ ] VNet integration / private endpoints
- [ ] Multi-language support (Arabic/English)
- [ ] Anomaly detection (duplicate invoices, outlier totals, suspicious changes)
- [ ] PDF export summaries
- [ ] Advanced filters (e.g., "show me all unpaid invoices from vendor X in Q4")
- [ ] Invoice reconciliation workflow

---

## Testing Strategy

### Backend
- [ ] Unit tests for API endpoints (happy path + error cases)
- [ ] Integration tests for database operations
- [ ] Integration tests for Azure Function pipeline
- [ ] End-to-end tests for upload → extract → search flow

### Frontend
- [ ] Component tests (upload, search, chat)
- [ ] E2E tests for critical workflows

### Validation
- [ ] Manual testing of extraction accuracy on sample invoices
- [ ] Performance testing (concurrent uploads, large documents)
- [ ] Multi-tenancy isolation verification

---

## Key Checkpoints

| Milestone | End of Week | Status |
|-----------|---------|--------|
| Infrastructure + DB setup | Week 1 | |
| Upload + Storage working | Week 1-2 | |
| Extraction pipeline + validation UI | Week 2-3 | |
| Search + Chat functional | Week 3-4 | |
| Exports + Audit Trail | Week 4 | |
| Multi-tenancy + RBAC + Monitoring | Throughout | |
| MVP Launch | Week 4 | |

---

## Quick Reference: API Endpoints to Build

| Method | Endpoint | Purpose |
|--------|----------|---------|
| POST | `/api/documents` | Upload document |
| GET | `/api/documents` | List documents |
| GET | `/api/documents/{id}` | Get document details + extraction |
| POST | `/api/documents/{id}/reprocess` | Re-run extraction |
| POST | `/api/documents/{id}/corrections` | Save field corrections |
| POST | `/api/chat` | Ask question about documents |
| GET | `/api/search` | Search documents |
| GET | `/api/exports/monthly` | Export monthly data |
| POST | `/api/auth/signup` | Create tenant + first user |
| POST | `/api/users` | Invite new user |

---

## Tips to Avoid Feeling Overwhelmed

1. **Start with Phase 0** – Get all the Azure resources set up first. It takes time but is foundational.
2. **Build in order** – Don't jump to chat before extraction works. Each phase enables the next.
3. **Use test data** – Create sample invoices early to test end-to-end quickly.
4. **Focus on MVP first** – Ignore stretch goals until all core features work.
5. **Test incrementally** – After each phase, verify it works before moving on.
6. **Communicate progress** – Update this plan as you complete phases.

---

**Good luck! Break it into small chunks, and you'll ship an impressive project. 🚀**
