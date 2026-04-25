# ADR-006 — UI Component Library: Syncfusion Essential Studio

| Field | Detail |
|---|---|
| **Document Type** | Architecture Decision Record |
| **Version** | v0.1 |
| **Status** | Accepted |
| **Owner** | Core Platform |
| **Location** | `docs/ADR/ADR-006_UI_Component_Library.md` |
| **Date** | April 2026 |
| **Related Documents** | ADR-003_UI_Technology_Stack, docs/architecture/operations/Run_Visibility_and_Dashboard_Model.md, PRD-1200_Reporting_Minimum |

---

## Context

The platform UI requires a comprehensive set of data-entry and data-display components suitable for a complex HCM application. The component requirements include:

- High-density data grids with sorting, filtering, pagination, grouping, and export — used throughout the platform for payroll run lists, employee records, exception queues, and reports
- Date pickers and date-range selectors — critical for effective-date entry, payroll period selection, and report filtering across a heavily date-driven domain
- Form inputs, dropdowns, multi-select, and autocomplete — used throughout HR and payroll data entry workflows
- Schedulers and calendars — relevant for payroll calendar management and T&A scheduling in future modules
- Charts and dashboards — relevant for operational reporting and run visibility
- Tree and hierarchy views — relevant for org structure display

The platform is built on Blazor Server (ADR-003). A proof of concept application was built using Syncfusion Blazor components, which validated the component model and integration approach. A commercial license has been procured.

**License:** Syncfusion Essential Studio® UI Edition Binary License, Release 33.1.44 (Volume 1 2026 — March 16, 2026).

---

## Decision

**The platform UI shall use Syncfusion Essential Studio Blazor components as the primary UI component library.**

All standard data-entry and data-display requirements shall be met using Syncfusion components before any alternative or custom component is considered. Custom components shall be developed only where Syncfusion's native offering has a documented gap or known UX deficiency.

---

## Known Gap: Date-Range Filter on Grid Columns

During proof of concept development, the Syncfusion grid's native date-range filter UI was found to be confusing to users. The underlying filtering behaviour is correct — the gap is in the filter interaction design, not the filtering engine.

**Mitigation:** A custom date-range filter template shall be developed and used consistently across all grid columns that require date-range filtering. The custom template shall replace the Syncfusion default filter UI with a simple two-field From / To date input pattern that is unambiguous to the user. The Syncfusion grid's underlying filter engine shall continue to process the filter values — only the UI interaction is replaced.

**This custom filter template is a platform-wide standard.** No grid in the platform shall use the Syncfusion native date-range filter UI. All date-range filtering on grid columns shall use the custom template. This ensures a consistent, predictable user experience across all modules.

The custom date-range filter template shall be developed as a shared Blazor component in the platform UI component library and documented in the UI conventions guide.

---

## Consequences

**Positive:**
- Comprehensive, production-grade component set covering all known UI requirements
- Proven integration with Blazor Server validated through proof of concept
- Commercial license provides access to support, updates, and the full component catalogue
- Syncfusion's template customisation model supports the date-range filter mitigation cleanly without requiring workarounds to the core component
- Regular release cadence (quarterly volumes) keeps components current with .NET and Blazor evolution

**Constraints to manage:**
- The custom date-range filter template must be developed early and treated as a foundational shared component — grids should not be built with the native filter and later migrated
- License renewal must be tracked — the current license (Release 33.1.44, Volume 1 2026) covers the active development period; renewal should be planned before the next major Blazor version adoption
- Syncfusion component API changes between major releases require testing on upgrade — a component update policy should be established before production deployment

**Future consideration:**
- As future modules (advanced T&A scheduling, workforce analytics) are developed, the Syncfusion Scheduler and Chart components should be evaluated against their specific requirements before assuming they are fit for purpose without customisation

---

## Alternatives Considered

**MudBlazor**
Free, open-source Blazor component library with Material Design aesthetics. Well-maintained and widely used. Not selected — the data grid component, while adequate for moderate use cases, lacks the column-level filtering sophistication, virtual scrolling performance, and export capabilities required for payroll register and HR operational report grids at the expected data volumes.

**Radzen Blazor Components**
Free tier with commercial options. Not selected — component depth and grid capability below Syncfusion at the enterprise use case level; limited support model relative to a commercial library for a production payroll platform.

**Telerik UI for Blazor (Progress)**
Strong commercial alternative with comparable feature depth to Syncfusion. Not selected — Syncfusion proof of concept was already validated and a license procured; switching cost not justified given comparable capability.

**Custom components only**
Building all UI components from scratch. Rejected — the development cost and ongoing maintenance burden of building production-grade data grid, date picker, scheduler, and chart components from scratch is not justified when a proven commercial library exists and is licensed.
