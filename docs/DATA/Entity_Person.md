# Entity — Person

| Field | Detail |
|---|---|
| **Document Type** | Data Entity Specification |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Core Platform / HRIS |
| **Location** | `docs/DATA/Entity_Person.md` |
| **Related Documents** | DATA/Entity_Employee.md, PRD-0200_Core_Entity_Model.md, docs/architecture/core/Employment_and_Person_Identity_Model.md |

## Purpose

Defines the canonical Person entity — the enduring record of a human being within the HCM platform. The Person record persists across all employment episodes, including terminations and rehires.

---

## 1. Design Principles

- Person_ID is the enduring human identity key. It never changes for a given individual.
- Person records are not payroll records. Payroll anchors to Employment_ID, not Person_ID.
- A Person record is created at the time of first hire and is never deleted, even after termination.
- Sensitive fields (National Identifier / SSN) must be stored encrypted and access-controlled.
- All changes to Person records are effective-dated and historically preserved. No silent overwrites.

---

## 2. Core Attributes

| Attribute | Type | Required | Notes |
|---|---|---|---|
| Person_ID | UUID | Yes | System-generated. Immutable. |
| Legal_First_Name | String | Yes | |
| Legal_Last_Name | String | Yes | |
| Legal_Middle_Name | String | No | |
| Preferred_Name | String | No | Display name if different from legal name |
| Date_of_Birth | Date | Yes | |
| National_Identifier | String (encrypted) | Yes | SSN for US; governed by security policy |
| Gender | String | No | Self-identified; controlled vocabulary |
| Pronouns | String | No | Self-identified; free text or controlled vocabulary |
| Person_Status | Enum | Yes | See status values below |
| Creation_Timestamp | Datetime | Yes | System-generated |
| Last_Update_Timestamp | Datetime | Yes | System-generated |
| Last_Updated_By | String | Yes | Actor reference |

---

## 3. Contact Attributes

Contact information is stored as a sub-record to support multiple addresses over time.

| Attribute | Type | Required | Notes |
|---|---|---|---|
| Address_Line_1 | String | Yes | |
| Address_Line_2 | String | No | |
| City | String | Yes | |
| State_Code | String | Yes | ISO 3166-2 |
| Postal_Code | String | Yes | |
| Country_Code | String | Yes | ISO 3166-1 |
| Phone_Primary | String | No | |
| Phone_Secondary | String | No | |
| Email_Personal | String | No | |
| Effective_Start_Date | Date | Yes | |
| Effective_End_Date | Date | No | |

---

## 4. Emergency Contact Attributes

| Attribute | Type | Required | Notes |
|---|---|---|---|
| Emergency_Contact_Name | String | No | |
| Emergency_Contact_Relationship | String | No | |
| Emergency_Contact_Phone | String | No | |
| Emergency_Contact_Email | String | No | |

---

## 5. Person_Status Values

| Value | Description |
|---|---|
| Active | Has at least one active Employment record |
| Inactive | No active Employment; record retained |
| Deceased | Deceased; record preserved for legal purposes |
| Restricted | Access-restricted; reason managed by HR |

Person_Status is informational. Payroll eligibility is governed by Employment_Status on the Employment record, not by Person_Status.

---

## 6. Community Profile (person_social_profile)

An optional satellite record keyed on `Person_ID`. Stores a voluntary community-facing profile that will be visible to colleagues once the Employee Self-Service (ESS) module is live.

### 6.1 Purpose

Enables employees to share a personal photo and a short bio (hobbies, interests, life outside work) to foster community within the organisation. The profile is per-person, not per-employment — it persists across transfers and rehires.

### 6.2 Attributes

| Attribute | DB Column | Type | Required | Notes |
|---|---|---|---|---|
| Person_ID | `person_id` | UUID | Yes (PK + FK) | FK → `person.person_id` |
| Photo_Data | `photo_data` | bytea | No | Raw image bytes; max 2 MB enforced at upload |
| Photo_MIME_Type | `photo_mime_type` | varchar(50) | No | `image/jpeg`, `image/png`, `image/webp` |
| Bio_Text | `bio_text` | varchar(1000) | No | Free-text; max 1,000 characters |
| Updated_At | `updated_at` | timestamptz | Yes | Set by server on each save |

### 6.3 Storage & Serving

- Photo bytes are stored directly in `person_social_profile.photo_data` (lightweight blob). No external object store for Phase 1.
- Photo served via minimal API endpoint `GET /api/profile-photo/{personId}` with `Cache-Control: private, max-age=3600`.
- Upload uses the existing `window.allworkFiles.readBase64` JS FileReader interop (avoids `IBrowserFile.OpenReadStream()` Blazor timeout issue).
- Client-side size check (`allworkFiles.getFileSize`) + server-side byte check after base64 decode; rejected if > 2,097,152 bytes.

### 6.4 Governance

- Self-service only — employees supply their own photo and bio. HR administrators may clear the profile via the Employee Detail → Community tab.
- No access control on photo endpoint beyond authentication (any authenticated user may view any colleague's photo once ESS is live).
- Photo and bio are not subject to the same change-authorisation rules as core Person data (legal name, SSN, etc.).
- DDL migration: `schemas/ddl/postgres/migrations/008_person_social_profile.sql`

---

## 7. Relationships

| Relationship | Cardinality | Notes |
|---|---|---|
| Person → Employment | One-to-many | A person may have multiple employment episodes |
| Person → Document | One-to-many | Person-level documents (e.g., ID verification) |
| Person → Community Profile | One-to-one (optional) | Voluntary; row absent until first save |

---

## 8. Governance

- Changes to legal name, national identifier, or date of birth require HR administrator authorization and may require supporting documentation.
- National Identifier is encrypted at rest and access-controlled per the `Security_and_Access_Control_Model`.
- All Person record changes are audit-logged with timestamp and actor.
- Person records are subject to retention policy per the `Data_Retention_and_Archival_Model`.

---

## 9. Related Architecture Models

| Model | Relevance |
|---|---|
| Employment_and_Person_Identity_Model | Defines the Person/Employment separation and identity anchoring rules |
| Security_and_Access_Control_Model | Governs access to sensitive Person fields |
| Data_Retention_and_Archival_Model | Governs retention of Person records |
| Correction_and_Immutability_Model | Governs how Person record changes are applied |
