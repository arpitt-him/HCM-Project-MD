# SPEC — HRIS Document Management

| Field | Detail |
|---|---|
| **Document Type** | Functional Specification |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Core Platform / HRIS |
| **Location** | `docs/SPEC/HRIS_Document_Management.md` |
| **Related Documents** | HRIS_Module_PRD §12, SPEC/HRIS_Core_Module, docs/DATA/Entity_Document.md, docs/STATE/STATE-DOC_Document.md, docs/architecture/data/Document_Data_Model.md, docs/architecture/governance/Data_Retention_and_Archival_Model.md, docs/architecture/governance/Security_and_Access_Control_Model.md |

---

## Purpose

Defines the implementation-ready specification for document management within the HRIS module — document upload, versioning, expiration tracking, compliance alerting, access control, and the Blazor component specifications for document-related UI.

Documents are governed records attached to Person or Employment. They are versioned, never deleted, and retained per regulatory requirements. The most compliance-critical documents are I-9 (employment eligibility) and W-4 (federal tax withholding), which have specific handling rules covered in detail below.

---

## 1. Module Assembly Additions

The following additions are made to the `BlazorHR.Module.Hris` assembly:

```
BlazorHR.Module.Hris/
│
├── Domain/
│   └── Documents/
│       ├── HrDocument.cs              # Domain record (named to avoid conflict with System.Document)
│       ├── DocumentType.cs            # Enum — I9, W4, OFFER_LETTER, etc.
│       └── DocumentStatus.cs         # Enum — STATE-DOC-001 through 004
│
├── Commands/
│   ├── UploadDocumentCommand.cs
│   ├── VerifyDocumentCommand.cs
│   ├── SupersedeDocumentCommand.cs
│   └── ArchiveDocumentCommand.cs
│
├── Repositories/
│   └── IDocumentRepository.cs
│
└── Services/
    ├── IDocumentService.cs
    └── IDocumentStorageService.cs     # Abstraction over file storage
```

---

## 2. Domain Commands

```csharp
// Commands/UploadDocumentCommand.cs
public sealed record UploadDocumentCommand
{
    public required Guid        PersonId          { get; init; }
    public Guid?                EmploymentId      { get; init; }  // null = person-level
    public required string      DocumentType      { get; init; }
    public required string      DocumentName      { get; init; }
    public required Stream      FileContent       { get; init; }
    public required string      FileFormat        { get; init; }  // PDF, DOCX, PNG, etc.
    public required DateOnly    EffectiveDate     { get; init; }
    public DateOnly?            ExpirationDate    { get; init; }
    public required Guid        UploadedBy        { get; init; }
}

// Commands/VerifyDocumentCommand.cs
public sealed record VerifyDocumentCommand
{
    public required Guid   DocumentId    { get; init; }
    public required Guid   VerifiedBy    { get; init; }
}

// Commands/SupersedeDocumentCommand.cs
public sealed record SupersedeDocumentCommand
{
    public required Guid        SupersededDocumentId  { get; init; }
    public required Guid        PersonId              { get; init; }
    public Guid?                EmploymentId          { get; init; }
    public required string      DocumentType          { get; init; }
    public required string      DocumentName          { get; init; }
    public required Stream      FileContent           { get; init; }
    public required string      FileFormat            { get; init; }
    public required DateOnly    EffectiveDate         { get; init; }
    public DateOnly?            ExpirationDate        { get; init; }
    public required Guid        UploadedBy            { get; init; }
}
```

---

## 3. Repository Interface

```csharp
// Repositories/IDocumentRepository.cs
public interface IDocumentRepository
{
    Task<HrDocument?>              GetByIdAsync(Guid documentId);
    Task<IEnumerable<HrDocument>>  GetByPersonIdAsync(Guid personId);
    Task<IEnumerable<HrDocument>>  GetByEmploymentIdAsync(Guid employmentId);
    Task<HrDocument?>              GetActiveByTypeAsync(Guid personId,
                                       string documentType, Guid? employmentId = null);
    Task<IEnumerable<HrDocument>>  GetExpiringWithinAsync(int days,
                                       string? documentType = null);
    Task<Guid>                     InsertAsync(HrDocument document, IUnitOfWork uow);
    Task                           UpdateStatusAsync(Guid documentId, string status,
                                       IUnitOfWork uow);
    Task                           SetSupersededByAsync(Guid documentId,
                                       Guid supersedingDocumentId, IUnitOfWork uow);
    Task                           SetVerifiedAsync(Guid documentId, Guid verifiedBy,
                                       DateTimeOffset verificationDate, IUnitOfWork uow);
}
```

---

## 4. Storage Service Interface

File content is stored outside the database. The `IDocumentStorageService` abstracts the storage mechanism — local filesystem for development, configurable blob storage for production.

```csharp
// Services/IDocumentStorageService.cs
public interface IDocumentStorageService
{
    /// <summary>
    /// Stores the file and returns a storage reference (opaque string)
    /// that can later be used to retrieve the file.
    /// </summary>
    Task<string> StoreAsync(Guid documentId, Stream content,
        string fileFormat, CancellationToken ct = default);

    /// <summary>
    /// Returns the file content for the given storage reference.
    /// </summary>
    Task<Stream> RetrieveAsync(string storageReference,
        CancellationToken ct = default);

    /// <summary>
    /// Permanently removes a file from storage.
    /// Only called when retention policy explicitly permits disposal.
    /// </summary>
    Task DeleteAsync(string storageReference,
        CancellationToken ct = default);
}
```

The storage reference is stored in the `document.storage_reference` column. The application never stores file paths or URLs directly — only the opaque reference returned by `StoreAsync`.

---

## 5. Document Service Interface

```csharp
// Services/IDocumentService.cs
public interface IDocumentService
{
    /// <summary>
    /// Uploads a new document. If an active document of the same type
    /// already exists for the same person/employment, it is automatically
    /// superseded by the new upload.
    /// </summary>
    Task<Guid> UploadDocumentAsync(UploadDocumentCommand command,
        CancellationToken ct = default);

    /// <summary>
    /// Marks a document as verified by an authorised HR administrator.
    /// Required for I-9 documents before employment activation.
    /// </summary>
    Task VerifyDocumentAsync(VerifyDocumentCommand command);

    /// <summary>
    /// Explicitly supersedes an existing document with a new upload.
    /// Used for re-verification of expiring documents.
    /// </summary>
    Task<Guid> SupersedeDocumentAsync(SupersedeDocumentCommand command,
        CancellationToken ct = default);

    /// <summary>
    /// Archives a document. Archived documents remain in the database
    /// and storage but are removed from active display.
    /// Cannot archive documents under legal hold.
    /// </summary>
    Task ArchiveDocumentAsync(Guid documentId, Guid archivedBy);

    Task<IEnumerable<HrDocument>> GetDocumentsAsync(Guid personId,
        Guid? employmentId = null);

    Task<Stream> DownloadDocumentAsync(Guid documentId, Guid requestedBy);

    Task<IEnumerable<HrDocument>> GetExpiringDocumentsAsync(int withinDays,
        string? documentType = null);
}
```

---

## 6. Upload Implementation Pattern

```csharp
public async Task<Guid> UploadDocumentAsync(UploadDocumentCommand command,
    CancellationToken ct = default)
{
    // 1. Validate command
    if (command.ExpirationDate.HasValue
     && command.ExpirationDate.Value <= command.EffectiveDate)
        throw new ValidationException(
            "Expiration date must be after effective date.");

    // 2. Store file content and get storage reference
    var documentId = Guid.NewGuid();
    var storageRef = await _storageService.StoreAsync(
        documentId, command.FileContent, command.FileFormat, ct);

    using var uow = new UnitOfWork(_connectionFactory);
    try
    {
        // 3. Supersede existing active document of same type if present
        var existing = await _documentRepository.GetActiveByTypeAsync(
            command.PersonId, command.DocumentType, command.EmploymentId);

        if (existing is not null)
        {
            await _documentRepository.UpdateStatusAsync(
                existing.DocumentId, DocumentStatus.Superseded.ToString(), uow);
            await _documentRepository.SetSupersededByAsync(
                existing.DocumentId, documentId, uow);
        }

        // 4. Create new document record
        var document = new HrDocument
        {
            DocumentId       = documentId,
            PersonId         = command.PersonId,
            EmploymentId     = command.EmploymentId,
            DocumentType     = command.DocumentType,
            DocumentName     = command.DocumentName,
            DocumentVersion  = (existing?.DocumentVersion ?? 0) + 1,
            DocumentStatus   = DocumentStatus.Active.ToString(),
            EffectiveDate    = command.EffectiveDate,
            ExpirationDate   = command.ExpirationDate,
            StorageReference = storageRef,
            FileFormat       = command.FileFormat,
            UploadDate       = DateTimeOffset.UtcNow,
            UploadedBy       = command.UploadedBy,
            CreatedBy        = command.UploadedBy,
            CreationTimestamp = DateTimeOffset.UtcNow
        };

        await _documentRepository.InsertAsync(document, uow);
        uow.Commit();

        return documentId;
    }
    catch
    {
        // Attempt to clean up orphaned file on failure
        await _storageService.DeleteAsync(storageRef, ct);
        uow.Rollback();
        throw;
    }
}
```

---

## 7. I-9 Specific Handling

The I-9 (Employment Eligibility Verification) is the most compliance-critical document in the system. It has specific rules beyond the standard document flow.

### 7.1 I-9 Requirements

- **Section 1** (employee) must be completed on or before the first day of employment
- **Section 2** (employer) must be completed within 3 business days of the start date
- **Re-verification** is required when work authorization expires or when more than 3 years have elapsed since the prior I-9 date for rehires
- A missing or expired I-9 generates `EXC-VAL-013` — this is a compliance exception that must be resolved

### 7.2 I-9 Verification Gate

An I-9 document must be verified (HR administrator completes Section 2) before the employment record can transition from PENDING to ACTIVE. The `VerifyDocumentAsync` service method records the verifying HR administrator and timestamp.

```csharp
// I-9 verification check called during employment activation
public async Task<bool> IsI9VerifiedAsync(Guid personId, Guid employmentId)
{
    var i9 = await _documentRepository.GetActiveByTypeAsync(
        personId, DocumentType.I9.ToString(), employmentId);

    return i9 is not null
        && i9.VerifiedBy.HasValue
        && i9.DocumentStatus == DocumentStatus.Active.ToString();
}
```

### 7.3 I-9 Re-Verification (Rehire)

On rehire, the system checks the most recent I-9 on file:
- If the prior I-9 is less than 3 years old and work authorization is still valid → no re-verification required; existing I-9 remains active
- If the prior I-9 is more than 3 years old → `EXC-ONB-003` raised; new I-9 required as blocking onboarding task
- If work authorization has expired → re-verification required regardless of age

---

## 8. W-4 Specific Handling

The W-4 (Federal Tax Withholding) governs federal income tax withholding. It is required before the first payroll run.

- A new W-4 is required for every hire and rehire
- The W-4 is consumed by the Payroll module to determine withholding elections
- The platform stores the W-4 document but does not parse its content — withholding elections are entered separately as tax election records
- W-4 does not expire but may be superseded when the employee submits a new election
- A missing W-4 at payroll processing time generates `EXC-TAX-002`

---

## 9. Expiration Tracking and Compliance Alerts

Documents with `expiration_date` populated are monitored by a scheduled background job (`DOCUMENT_EXPIRATION_CHECK` job type) that runs daily.

Alert thresholds per document type:

| Document Type | Alert at | Severity |
|---|---|---|
| I9 | 90, 60, 30 days before expiration | Warning → Hold at 30 days |
| LICENSE | 60, 30 days before expiration | Warning |
| CERTIFICATION | 60, 30 days before expiration | Warning |
| POA | 30 days before expiration | Warning |

**On expiration:** Document status transitions to `EXPIRED` (STATE-DOC-003). The document remains accessible for historical and compliance purposes. An exception is raised in the operator work queue.

**Background job pattern:**

```csharp
// Registered as IHostedService in Program.cs
public class DocumentExpirationCheckJob : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken ct)
    {
        while (!ct.IsCancellationRequested)
        {
            var operativeDate = DateOnly.FromDateTime(
                _temporalContext.GetOperativeDate());

            // Check for documents expiring within alert thresholds
            var expiring90 = await _documentService
                .GetExpiringDocumentsAsync(withinDays: 90);

            foreach (var doc in expiring90)
                await _workQueueService.EnsureExpirationAlertAsync(doc, operativeDate);

            // Transition overdue documents to EXPIRED
            var expired = await _documentRepository
                .GetExpiredAsOfAsync(operativeDate);

            foreach (var doc in expired)
                await _documentService.ExpireDocumentAsync(doc.DocumentId);

            // Run once per day — wait until next governed operative midnight
            await Task.Delay(TimeSpan.FromHours(24), ct);
        }
    }
}
```

---

## 10. Access Control

Document access is strictly role-scoped. The storage reference must never be returned to a caller who has not been authorised to access the document.

| Role | Read Metadata | Download Content | Upload | Verify | Archive |
|---|---|---|---|---|---|
| `Employee` | Own documents only | Own documents only | Own documents (ESS) | No | No |
| `Manager` | Direct reports | No | No | No | No |
| `HrisAdmin` | All in scope | All in scope | Yes | Yes | Yes |
| `HrDocumentReviewer` | All in scope | All in scope | No | Yes | No |
| `Auditor` | All in scope | All in scope | No | No | No |

**Download audit logging:** Every document download is logged with actor identity, timestamp, document ID, and IP address. This is a hard requirement — no download may occur without an audit record.

---

## 11. Blazor Component Specifications

### 11.1 Document List (Employee Detail — Documents Tab)

Syncfusion Grid showing all documents for the employee.

**Columns:**

| Column | Source | Notes |
|---|---|---|
| Type | `document_type` display name | |
| Name | `document_name` | |
| Version | `document_version` | |
| Status | `document_status` | Colour-coded badge |
| Effective Date | `effective_date` | |
| Expiration Date | `expiration_date` | Red if expired; amber if within 30 days |
| Uploaded By | User display name | |
| Upload Date | `upload_date` | |
| Actions | — | Download; Upload New Version |

**Filters:** Document Type, Status. Custom date-range filter on Expiration Date (platform standard per ADR-006).

**Role gating:** Download button only visible to roles with download permission. Upload New Version only visible to `HrisAdmin`.

---

### 11.2 Upload Document Panel

Syncfusion Dialog or Sidebar. Opened from the `+ Add Document` or `Upload New Version` buttons.

**Form fields:**

| Field | Input | Notes |
|---|---|---|
| Document Type | Dropdown | Required; drives expiration required flag |
| Document Name | Text | Required |
| Effective Date | SfDatePicker | Required |
| Expiration Date | SfDatePicker | Required if document type requires expiration |
| File | SfUploader | PDF, DOCX, PNG, JPG accepted; max 10MB |

**On upload:** Calls `UploadDocumentAsync`. If a document of the same type already exists, the UI warns: "This will supersede the existing [Document Type] dated [date]. Proceed?" Confirmation required before submission.

**File size and format validation** occurs client-side before the request is submitted.

---

### 11.3 Document Expiration Report (`/hris/documents/expiring`)

Pre-built report from PRD-1200 HR-RPT-008 — Document Expiration Report.

Syncfusion Grid showing all documents expiring within a configurable window (default 90 days).

**Columns:** Employee Name, Employment ID, Document Type, Expiration Date, Days Until Expiration, Status.

**Filters:** Expiration window (days), Document Type, Employment Status (Active only by default).

**Export:** CSV export available. Role: `HrisAdmin`, `HrDocumentReviewer`, `Auditor`.

---

## 12. Document Retention Rules

Per `Data_Retention_and_Archival_Model` and regulatory requirements:

| Document Type | Minimum Retention | Notes |
|---|---|---|
| I-9 | 3 years from hire date OR 1 year after termination, whichever is later | USCIS requirement |
| W-4 | 4 years | IRS requirement |
| Employment Agreement | 7 years after termination | |
| Offer Letter | 7 years after termination | |
| Disciplinary | 7 years after termination | |
| License / Certification | 7 years after expiration | |
| Other | 7 years after employment end | Default |

Documents within their retention window may not be physically deleted. The `ArchiveDocumentAsync` method transitions status only — it does not remove the file from storage.

---

## 13. DBML Addition Required

The `document` table in `hcm_hris.dbml` needs one column added to support the document expiration check job:

```
// Add to document table in hcm_hris.dbml
legal_hold_flag    boolean    [not null, default: false, note: "True if document is under legal hold; prevents archival and disposal"]
```

Regenerate DDL after updating DBML.

---

## 14. Test Cases

| ID | Description | Expected Result |
|---|---|---|
| TC-DOC-001 | Upload a new I-9 document | Document created in ACTIVE state; storage reference populated; version = 1 |
| TC-DOC-002 | Upload a second I-9 for same person/employment | Prior I-9 transitions to SUPERSEDED; new I-9 created as ACTIVE with version = 2 |
| TC-DOC-003 | Upload document with expiration date before effective date | ValidationException thrown; no document created; file not stored |
| TC-DOC-004 | Upload fails mid-transaction | Storage file cleaned up; no database record created |
| TC-DOC-005 | Verify I-9 document | `verified_by` and `verification_date` populated; document remains ACTIVE |
| TC-DOC-006 | `IsI9VerifiedAsync` returns true for verified I-9 | Returns true |
| TC-DOC-007 | `IsI9VerifiedAsync` returns false for unverified I-9 | Returns false; employment activation blocked |
| TC-DOC-008 | `IsI9VerifiedAsync` returns false when no I-9 on file | Returns false |
| TC-DOC-009 | Document expiration check job runs with document expiring in 25 days | Hold raised in work queue; document status not yet changed |
| TC-DOC-010 | Document expiration check job runs with document past expiration date | Document status transitions to EXPIRED; exception raised in work queue |
| TC-DOC-011 | Expiration check job respects Temporal Override | With override active, expiration evaluated relative to override date not system clock |
| TC-DOC-012 | Employee downloads own document | Download permitted; audit record created with actor identity and timestamp |
| TC-DOC-013 | Manager attempts to download direct report document | Download denied (Manager role has no download permission); audit record created |
| TC-DOC-014 | HrisAdmin downloads any document in scope | Download permitted; audit record created |
| TC-DOC-015 | Archive document within retention window | Status transitions to ARCHIVED; file remains in storage |
| TC-DOC-016 | Archive document with legal_hold_flag = true | `DomainException` thrown; document not archived |
| TC-DOC-017 | Document list grid shows expiration date in red for expired document | Expiration date cell renders with danger colour |
| TC-DOC-018 | Document list grid shows expiration date in amber within 30 days | Expiration date cell renders with warning colour |
| TC-DOC-019 | Upload panel warns before superseding existing document | Confirmation dialog shown with existing document details |
| TC-DOC-020 | Document Expiration Report filtered to 90 days shows correct documents | Grid shows only documents with expiration_date within 90 days of governed operative date |
