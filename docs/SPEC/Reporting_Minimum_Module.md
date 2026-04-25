# SPEC — Reporting Minimum Module

| Field | Detail |
|---|---|
| **Document Type** | Functional Specification |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Core Platform |
| **Location** | `docs/SPEC/Reporting_Minimum_Module.md` |
| **Related Documents** | PRD-1200_Reporting_Minimum, ADR-006_UI_Component_Library, ADR-007_Module_Composition_DI_Lifetime, ADR-005_Background_Job_Execution, SPEC/Payroll_Core_Module, SPEC/HRIS_Core_Module, docs/architecture/operations/Operational_Reporting_and_Analytics_Model.md |

---

## Purpose

Defines the implementation-ready specification for the Reporting (minimum) module — the platform's pre-built operational reports for payroll and HR administration.

This module provides 16 pre-built reports — 8 payroll operational and 8 HR operational — accessible via on-screen view and three export formats: CSV, XLSX (Excel), and PDF. Role-scoped access enforcement applies to all reports and all export channels.

The Reporting module is read-only. It consumes data from Payroll and HRIS but never writes to either.

**Export libraries:**

| Format | Library | License | Notes |
|---|---|---|---|
| CSV | None | N/A | Streamed directly — no dependency |
| XLSX | ClosedXML | MIT | Pure .NET; proper workbook formatting |
| PDF | QuestPDF | Community (free < $1M revenue) | Fluent C# API; professional document output |

---

## 1. Module Assembly Structure

```
BlazorHR.Module.Reporting/
│
├── ReportingModule.cs
│
├── Domain/
│   ├── ReportDefinition.cs
│   ├── ReportData.cs
│   ├── ReportColumn.cs
│   └── ReportResult.cs
│
├── Reports/
│   ├── Payroll/
│   │   ├── PAY_RPT_001_PayrollRegister.cs
│   │   ├── PAY_RPT_002_GrossToNetSummary.cs
│   │   ├── PAY_RPT_003_EmployerCost.cs
│   │   ├── PAY_RPT_004_PayrollException.cs
│   │   ├── PAY_RPT_005_YtdAccumulatorBalance.cs
│   │   ├── PAY_RPT_006_PayrollVariance.cs
│   │   ├── PAY_RPT_007_PaymentDisbursement.cs
│   │   └── PAY_RPT_008_TaxLiabilitySummary.cs
│   └── HR/
│       ├── HR_RPT_001_ActiveHeadcount.cs
│       ├── HR_RPT_002_NewHireTermination.cs
│       ├── HR_RPT_003_Turnover.cs
│       ├── HR_RPT_004_LeaveUtilisation.cs
│       ├── HR_RPT_005_OpenPosition.cs
│       ├── HR_RPT_006_CompensationSummary.cs
│       ├── HR_RPT_007_OnboardingStatus.cs
│       └── HR_RPT_008_DocumentExpiration.cs
│
├── Export/
│   ├── CsvExporter.cs
│   ├── XlsxExporter.cs              # ClosedXML
│   └── PdfExporter.cs               # QuestPDF
│
├── Services/
│   ├── IReportService.cs
│   ├── IReportExportService.cs
│   └── IScheduledReportService.cs
│
└── Queries/
    ├── PayrollReportQueries.cs
    └── HrReportQueries.cs
```

---

## 2. ReportingModule Registration

```csharp
[Export(typeof(IPlatformModule))]
public sealed class ReportingModule : IPlatformModule
{
    public void Register(ContainerBuilder builder)
    {
        builder.RegisterType<ReportService>()
               .As<IReportService>()
               .InstancePerLifetimeScope();

        builder.RegisterType<ReportExportService>()
               .As<IReportExportService>()
               .InstancePerLifetimeScope();

        builder.RegisterType<ScheduledReportService>()
               .As<IScheduledReportService>()
               .SingleInstance();

        builder.RegisterType<CsvExporter>().AsSelf()
               .InstancePerLifetimeScope();
        builder.RegisterType<XlsxExporter>().AsSelf()
               .InstancePerLifetimeScope();
        builder.RegisterType<PdfExporter>().AsSelf()
               .InstancePerLifetimeScope();
    }

    public IEnumerable<MenuContribution> GetMenuContributions() =>
    [
        new MenuContribution
        {
            Label        = "Reports",
            Icon         = "reports-icon",
            SortOrder    = 40,
            AccentColor  = "var(--color-accent-sand)",
            BadgeLabel   = "RPT",
            RequiredRole = "ReportViewer"
        },
        new MenuContribution
        {
            Label        = "Payroll Reports",
            Href         = "/reports/payroll",
            Icon         = "icon-payroll-report",
            SortOrder    = 1,
            ParentLabel  = "Reports",
            RequiredRole = "PayrollOperator"
        },
        new MenuContribution
        {
            Label        = "HR Reports",
            Href         = "/reports/hr",
            Icon         = "icon-hr-report",
            SortOrder    = 2,
            ParentLabel  = "Reports",
            RequiredRole = "HrisViewer"
        },
        new MenuContribution
        {
            Label        = "Scheduled Reports",
            Href         = "/reports/scheduled",
            Icon         = "icon-schedule",
            SortOrder    = 3,
            ParentLabel  = "Reports",
            RequiredRole = "ReportAdmin"
        }
    ];
}
```

---

## 3. Report Parameters Model

All 16 reports share a common parameter model. Each report uses only the parameters relevant to it.

```csharp
public sealed record ReportParameters
{
    // Scope
    public Guid?     RunId              { get; init; }   // Payroll reports
    public Guid?     PayrollContextId   { get; init; }
    public Guid?     LegalEntityId      { get; init; }
    public Guid?     DepartmentId       { get; init; }
    public Guid?     LocationId         { get; init; }

    // Date
    public DateOnly? AsOfDate           { get; init; }   // Point-in-time reports
    public DateOnly? PeriodStart        { get; init; }   // Range reports
    public DateOnly? PeriodEnd          { get; init; }

    // Report-specific
    public string?   JurisdictionLevel  { get; init; }   // PAY-RPT-008
    public decimal?  VarianceThreshold  { get; init; }   // PAY-RPT-006
    public int?      ExpirationDays     { get; init; }   // HR-RPT-008
    public string?   EmploymentType     { get; init; }   // HR-RPT-001
    public string?   EventType          { get; init; }   // HR-RPT-002

    // Pagination — on-screen view only; exports always fetch all rows
    public int       Page               { get; init; } = 1;
    public int       PageSize           { get; init; } = 100;
}
```

---

## 4. Service Interfaces

```csharp
// Services/IReportService.cs
public interface IReportService
{
    /// <summary>
    /// Runs a report for on-screen display.
    /// Returns data inline for result sets under the async threshold.
    /// Returns Job_ID for larger result sets.
    /// </summary>
    Task<ReportResult> RunReportAsync(string reportId,
        ReportParameters parameters, Guid requestedBy,
        CancellationToken ct = default);

    Task<IEnumerable<ReportDefinition>> GetAvailableReportsAsync(
        ClaimsPrincipal user);
}

// Services/IReportExportService.cs
public interface IReportExportService
{
    /// <summary>
    /// Streams all rows as plain CSV. No library dependency.
    /// Always fetches all rows regardless of async threshold.
    /// </summary>
    Task<Stream> ExportCsvAsync(string reportId,
        ReportParameters parameters, Guid requestedBy,
        CancellationToken ct = default);

    /// <summary>
    /// Generates a formatted Excel workbook using ClosedXML.
    /// Includes column headers, number formatting, column width
    /// auto-sizing, freeze panes on row 3, and a title block.
    /// Always fetches all rows regardless of async threshold.
    /// </summary>
    Task<Stream> ExportXlsxAsync(string reportId,
        ReportParameters parameters, Guid requestedBy,
        CancellationToken ct = default);

    /// <summary>
    /// Generates a formatted PDF document using QuestPDF.
    /// Landscape orientation for wide reports. Includes report
    /// title, parameter summary, generated timestamp, and
    /// page numbers. Always fetches all rows.
    /// </summary>
    Task<Stream> ExportPdfAsync(string reportId,
        ReportParameters parameters, Guid requestedBy,
        CancellationToken ct = default);
}
```

---

## 5. Report Execution Pattern

All 16 reports follow the same execution pattern:

```csharp
public async Task<ReportResult> RunReportAsync(string reportId,
    ReportParameters parameters, Guid requestedBy,
    CancellationToken ct = default)
{
    // 1. Authorisation — does this user have access to this report?
    if (!_accessControl.CanAccessReport(reportId, requestedBy))
        throw new AuthorizationException(
            $"User does not have access to report {reportId}.");

    // 2. Scope enforcement — constrain parameters to user's authorised scope
    var scopedParams = _scopeEnforcer.Enforce(parameters, requestedBy);

    // 3. Resolve operative date — Temporal Override aware
    var asOf = scopedParams.AsOfDate
        ?? DateOnly.FromDateTime(_temporalContext.GetOperativeDate());

    // 4. Execute query
    var data = await _queryExecutor.ExecuteAsync(
        reportId, scopedParams, asOf, ct);

    // 5. Audit log
    await _auditLogger.LogReportAccessAsync(
        reportId, requestedBy, scopedParams, data.RowCount);

    // 6. Async threshold — submit as background job for large result sets
    if (data.RowCount > _config.AsyncThreshold)
    {
        var jobId = await _jobService.SubmitReportJobAsync(
            reportId, scopedParams, requestedBy);
        return ReportResult.Async(jobId);
    }

    return ReportResult.Inline(data);
}
```

**Async threshold:** Configurable per deployment; default 10,000 rows. Built-in reports for a 250-employee client will rarely approach this. The threshold is a safety valve for future growth.

---

## 6. Export Implementation Patterns

### 6.1 CSV Exporter — No Library

```csharp
public sealed class CsvExporter
{
    public async Task<Stream> ExportAsync(ReportData data,
        CancellationToken ct = default)
    {
        var stream = new MemoryStream();
        await using var writer = new StreamWriter(stream, leaveOpen: true);

        // Header row
        await writer.WriteLineAsync(string.Join(",",
            data.Columns.Select(c => Quote(c.Header))));

        // Data rows
        foreach (var row in data.Rows)
        {
            ct.ThrowIfCancellationRequested();
            await writer.WriteLineAsync(string.Join(",",
                data.Columns.Select(c =>
                    Quote(row[c.Field]?.ToString() ?? string.Empty))));
        }

        await writer.FlushAsync();
        stream.Position = 0;
        return stream;
    }

    private static string Quote(string v) =>
        v.Contains(',') || v.Contains('"') || v.Contains('\n')
            ? $"\"{v.Replace("\"", "\"\"")}\"" : v;
}
```

### 6.2 XLSX Exporter — ClosedXML

```csharp
public sealed class XlsxExporter
{
    public Stream Export(ReportData data, ReportDefinition definition,
        ReportParameters parameters)
    {
        using var workbook  = new XLWorkbook();
        var worksheet = workbook.Worksheets.Add(definition.ShortName);

        // Title block — rows 1-2
        var titleCell = worksheet.Cell(1, 1);
        titleCell.Value = definition.Title;
        titleCell.Style.Font.Bold      = true;
        titleCell.Style.Font.FontSize  = 13;
        worksheet.Range(1, 1, 1, data.Columns.Count).Merge();

        var paramCell = worksheet.Cell(2, 1);
        paramCell.Value = BuildParamSummary(parameters);
        paramCell.Style.Font.Italic    = true;
        paramCell.Style.Font.FontSize  = 9;
        worksheet.Range(2, 1, 2, data.Columns.Count).Merge();

        // Column headers — row 3
        for (int c = 0; c < data.Columns.Count; c++)
        {
            var cell = worksheet.Cell(3, c + 1);
            cell.Value = data.Columns[c].Header;
            cell.Style.Font.Bold       = true;
            cell.Style.Fill.BackgroundColor =
                XLColor.FromHtml("#E8EDF2");
            cell.Style.Border.BottomBorder =
                XLBorderStyleValues.Medium;
        }

        // Freeze top 3 rows
        worksheet.SheetView.FreezeRows(3);

        // Data rows — starting row 4
        for (int r = 0; r < data.Rows.Count; r++)
        {
            for (int c = 0; c < data.Columns.Count; c++)
            {
                var col   = data.Columns[c];
                var cell  = worksheet.Cell(r + 4, c + 1);
                var value = data.Rows[r][col.Field];

                cell.Value = value switch
                {
                    decimal d => XLCellValue.FromObject(d),
                    DateOnly dt => XLCellValue.FromObject(dt.ToDateTime(TimeOnly.MinValue)),
                    _ => XLCellValue.FromObject(value?.ToString() ?? string.Empty)
                };

                // Number formatting for currency columns
                if (col.Format == "currency")
                    cell.Style.NumberFormat.Format = "#,##0.00";

                // Date formatting
                if (col.Format == "date")
                    cell.Style.NumberFormat.Format = "yyyy-mm-dd";

                // Alternate row shading
                if (r % 2 == 1)
                    cell.Style.Fill.BackgroundColor =
                        XLColor.FromHtml("#F7F9FC");
            }
        }

        // Auto-size columns
        worksheet.Columns().AdjustToContents(minWidth: 8, maxWidth: 40);

        // Totals row for numeric columns where applicable
        if (definition.ShowTotals)
            AddTotalsRow(worksheet, data);

        var stream = new MemoryStream();
        workbook.SaveAs(stream);
        stream.Position = 0;
        return stream;
    }

    private static string BuildParamSummary(ReportParameters p)
    {
        var parts = new List<string>();
        if (p.AsOfDate.HasValue)
            parts.Add($"As of: {p.AsOfDate:yyyy-MM-dd}");
        if (p.PeriodStart.HasValue && p.PeriodEnd.HasValue)
            parts.Add($"Period: {p.PeriodStart:yyyy-MM-dd} – {p.PeriodEnd:yyyy-MM-dd}");
        return parts.Count > 0
            ? string.Join("   |   ", parts)
            : $"Generated: {DateTime.UtcNow:yyyy-MM-dd HH:mm} UTC";
    }
}
```

### 6.3 PDF Exporter — QuestPDF

```csharp
public sealed class PdfExporter
{
    public Stream Export(ReportData data, ReportDefinition definition,
        ReportParameters parameters)
    {
        var stream = new MemoryStream();

        Document.Create(container =>
        {
            container.Page(page =>
            {
                // Landscape for wide reports
                page.Size(definition.IsWideReport
                    ? PageSizes.A4.Landscape()
                    : PageSizes.A4);

                page.Margin(30);
                page.DefaultTextStyle(x => x.FontSize(8));

                page.Header().Column(col =>
                {
                    col.Item().Text(definition.Title)
                       .Bold().FontSize(14);
                    col.Item().Text(BuildParamSummary(parameters))
                       .Italic().FontSize(8).FontColor(Colors.Grey.Darken2);
                    col.Item().Height(4);
                    col.Item().LineHorizontal(0.5f);
                });

                page.Content().Table(table =>
                {
                    // Column definitions
                    table.ColumnsDefinition(cols =>
                    {
                        foreach (var col in data.Columns)
                            cols.RelativeColumn();
                    });

                    // Header row
                    foreach (var col in data.Columns)
                    {
                        table.Header().Cell().Background("#E8EDF2")
                             .Padding(4).Text(col.Header).Bold();
                    }

                    // Data rows
                    bool alternate = false;
                    foreach (var row in data.Rows)
                    {
                        var bg = alternate ? "#F7F9FC" : Colors.White;
                        foreach (var col in data.Columns)
                        {
                            var value = row[col.Field]?.ToString() ?? string.Empty;
                            var isNumeric = col.Format is "currency" or "number";

                            table.Cell().Background(bg).Padding(3)
                                 .Text(FormatValue(value, col.Format))
                                 .FontSize(7.5f)
                                 .AlignRight(isNumeric);
                        }
                        alternate = !alternate;
                    }
                });

                page.Footer().Row(row =>
                {
                    row.RelativeItem()
                       .Text($"Generated: {DateTime.UtcNow:yyyy-MM-dd HH:mm} UTC")
                       .FontSize(7).FontColor(Colors.Grey.Medium);
                    row.RelativeItem().AlignRight()
                       .Text(txt =>
                       {
                           txt.Span("Page ").FontSize(7);
                           txt.CurrentPageNumber().FontSize(7);
                           txt.Span(" of ").FontSize(7);
                           txt.TotalPages().FontSize(7);
                       });
                });
            });
        }).GeneratePdf(stream);

        stream.Position = 0;
        return stream;
    }

    private static string FormatValue(string value, string? format) =>
        format == "currency" && decimal.TryParse(value, out var d)
            ? d.ToString("N2") : value;
}
```

---

## 7. Report Queries

Each report class implements a single `ExecuteAsync` method backed by a Dapper query. All queries are effective-dated and scope-enforced. Two representative examples:

### PAY-RPT-001 — Payroll Register

```csharp
public async Task<ReportData> ExecuteAsync(ReportParameters p,
    DateOnly asOf, CancellationToken ct)
{
    const string sql = """
        SELECT
            p.legal_last_name  || ', ' || p.legal_first_name AS employee_name,
            e.employee_number,
            ou.org_unit_name                                  AS department,
            epr.pay_period_start_date,
            epr.pay_period_end_date,
            epr.gross_pay_amount,
            epr.total_deductions_amount,
            epr.total_employee_tax_amount,
            epr.total_employer_contribution_amount,
            epr.net_pay_amount,
            epr.result_status
        FROM employee_payroll_result epr
        JOIN employment e ON e.employment_id = epr.employment_id
        JOIN person p     ON p.person_id = e.person_id
        JOIN assignment a ON a.employment_id = e.employment_id
                         AND a.assignment_type = 'PRIMARY'
                         AND a.assignment_start_date <= @AsOf
                         AND (a.assignment_end_date IS NULL
                              OR a.assignment_end_date >= @AsOf)
        JOIN org_unit ou  ON ou.org_unit_id = a.department_id
        WHERE epr.payroll_run_id = @RunId
          AND (@LegalEntityId IS NULL OR e.legal_entity_id = @LegalEntityId)
          AND (@DepartmentId  IS NULL OR a.department_id   = @DepartmentId)
        ORDER BY p.legal_last_name, p.legal_first_name
        """;

    using var conn = _connectionFactory.CreateConnection();
    var rows = await conn.QueryAsync<dynamic>(sql,
        new { p.RunId, p.LegalEntityId, p.DepartmentId, AsOf = asOf });

    return ReportData.From(rows, PayrollRegisterColumns());
}
```

### HR-RPT-001 — Active Headcount Report

```csharp
public async Task<ReportData> ExecuteAsync(ReportParameters p,
    DateOnly asOf, CancellationToken ct)
{
    const string sql = """
        SELECT
            ou.org_unit_name                                              AS department,
            COUNT(*)                                                      AS headcount,
            COUNT(*) FILTER (WHERE e.full_or_part_time_status = 'FULL_TIME')
                                                                          AS full_time,
            COUNT(*) FILTER (WHERE e.full_or_part_time_status = 'PART_TIME')
                                                                          AS part_time,
            COUNT(*) FILTER (WHERE e.flsa_status = 'EXEMPT')             AS exempt,
            COUNT(*) FILTER (WHERE e.flsa_status = 'NON_EXEMPT')         AS non_exempt
        FROM employment e
        JOIN assignment a ON a.employment_id = e.employment_id
                         AND a.assignment_type = 'PRIMARY'
                         AND a.assignment_start_date <= @AsOf
                         AND (a.assignment_end_date IS NULL
                              OR a.assignment_end_date >= @AsOf)
        JOIN org_unit ou  ON ou.org_unit_id = a.department_id
        WHERE e.employment_status = 'ACTIVE'
          AND e.employment_start_date <= @AsOf
          AND (e.employment_end_date IS NULL
               OR e.employment_end_date >= @AsOf)
          AND (@LegalEntityId  IS NULL OR e.legal_entity_id = @LegalEntityId)
          AND (@DepartmentId   IS NULL OR a.department_id   = @DepartmentId)
          AND (@EmploymentType IS NULL OR e.employment_type = @EmploymentType)
        GROUP BY ou.org_unit_id, ou.org_unit_name
        ORDER BY ou.org_unit_name
        """;

    using var conn = _connectionFactory.CreateConnection();
    var rows = await conn.QueryAsync<dynamic>(sql,
        new { AsOf = asOf, p.LegalEntityId, p.DepartmentId, p.EmploymentType });

    return ReportData.From(rows, HeadcountColumns());
}
```

---

## 8. Async Threshold

Reports exceeding the row threshold are submitted as `REPORT_GENERATION` async jobs per the `Async_Job_Execution_Model`. The UI receives a `Job_ID` and subscribes to progress via SignalR — same pattern as payroll runs.

```csharp
// Default — configurable per deployment
private const int AsyncThreshold = 10_000;
```

Built-in reports for a 250-employee client will rarely approach this limit. The threshold is a safety valve for larger PEO deployments.

Exports (CSV, XLSX, PDF) always fetch all rows regardless of threshold — they are submitted as async jobs unconditionally for large result sets to avoid HTTP timeout on export generation.

---

## 9. Scheduled Report Delivery

```csharp
public sealed record ScheduledReportConfig
{
    public required string          ReportId         { get; init; }
    public required string          TriggerType      { get; init; }
    // AFTER_PAYROLL_RUN, DAILY, WEEKLY, MONTHLY
    public Guid?                    PayrollContextId { get; init; }
    public string?                  CronExpression   { get; init; }
    public required Guid            RecipientUserId  { get; init; }
    public ReportParameters         DefaultParams    { get; init; } = new();
    public required string          ExportFormat     { get; init; }
    // CSV, XLSX, PDF
}
```

Scheduled reports execute as `REPORT_GENERATION` background jobs. Recipients receive an in-platform notification with a download link. The generated file is retained for a configurable period (default 7 days) before automatic removal.

---

## 10. Report Catalogue Summary

### Payroll Operational Reports

| ID | Report | Key Filters | Key Outputs | Roles |
|---|---|---|---|---|
| PAY-RPT-001 | Payroll Register | Run_ID, Legal Entity, Department | Employee, Gross, Deductions, Taxes, Net Pay | PayrollOperator, Finance |
| PAY-RPT-002 | Gross-to-Net Summary | Run_ID, Legal Entity | Population totals by earnings/deduction category | PayrollAdmin, Finance |
| PAY-RPT-003 | Employer Cost Report | Run_ID, Legal Entity | Employee cost + employer taxes + contributions per employee | Finance, PayrollAdmin |
| PAY-RPT-004 | Payroll Exception Report | Run_ID, Severity | Exception code, description, employee, status | PayrollOperator, PayrollAdmin |
| PAY-RPT-005 | YTD Accumulator Balance | Employment_ID or Run_ID | PTD / QTD / YTD balances by accumulator family | PayrollOperator, Finance |
| PAY-RPT-006 | Payroll Variance Report | Run_ID, Variance threshold % | Period-over-period gross pay delta; flagged employees | PayrollAdmin |
| PAY-RPT-007 | Payment Disbursement | Run_ID, Payment Method | Employee, method, masked account, net pay, disbursement status | PayrollAdmin, Finance |
| PAY-RPT-008 | Tax Liability Summary | Run_ID, Jurisdiction Level | Employee / employer tax by jurisdiction; YTD | Finance, Tax |

### HR Operational Reports

| ID | Report | Key Filters | Key Outputs | Roles |
|---|---|---|---|---|
| HR-RPT-001 | Active Headcount | As-of Date, Department, Legal Entity | Headcount, FT/PT split, Exempt/Non-Exempt | HrisAdmin, Manager, Finance |
| HR-RPT-002 | New Hire & Termination | Period, Event Type, Department | Employee, event type, effective date, reason | HrisAdmin, Finance |
| HR-RPT-003 | Turnover Report | Period, Department | Turnover rate by department; voluntary vs involuntary | HrisAdmin, Finance |
| HR-RPT-004 | Leave Utilisation | Period, Department | Leave by type; used vs entitlement; balance | HrisAdmin, Manager |
| HR-RPT-005 | Open Position Vacancy | As-of Date, Department | Open positions; days vacant; budget headcount | HrisAdmin |
| HR-RPT-006 | Compensation Summary | As-of Date, Department | Employee, rate type, base rate, annual equivalent | HrisAdmin, Finance |
| HR-RPT-007 | Onboarding Status | Period, Department | New hire, plan status, blocking tasks outstanding | HrisAdmin, Manager |
| HR-RPT-008 | Document Expiration | Expiration window (days) | Employee, document type, expiration date, days remaining | HrisAdmin |

---

## 11. Blazor Component Specifications

### 11.1 Report Hub Pages

Two pages — `/reports/payroll` and `/reports/hr`. Card layout — one card per report, role-filtered.

Each card: report name, brief description, primary users badge, "Run Report" button. Cards for reports the current user cannot access are not rendered.

---

### 11.2 ReportRunner Component

Shared component used by all 16 reports:

```razor
@* ReportRunner.razor *@

<div class="report-runner">

    <div class="report-params-panel">
        <ReportParameterPanel ReportId="@ReportId"
                              @bind-Parameters="_parameters" />
        <button class="btn-primary" @onclick="RunReport"
                disabled="@_isRunning">
            @(_isRunning ? "Running..." : "Run Report")
        </button>
    </div>

    @if (_jobId.HasValue)
    {
        <JobProgressPanel JobId="@_jobId.Value"
                          OnComplete="OnReportComplete" />
    }
    else if (_reportData is not null)
    {
        <div class="report-export-toolbar">
            <button @onclick="() => ExportAsync("csv")">
                Export CSV
            </button>
            <button @onclick="() => ExportAsync("xlsx")">
                Export Excel
            </button>
            <button @onclick="() => ExportAsync("pdf")">
                Export PDF
            </button>
        </div>

        <SfGrid DataSource="@_reportData.Rows"
                AllowPaging="true" AllowSorting="true"
                AllowResizing="true">
            <GridPageSettings PageSize="100" />
            <GridColumns>
                @foreach (var col in _reportData.Columns)
                {
                    <GridColumn Field="@col.Field"
                                HeaderText="@col.Header"
                                Format="@col.SyncfusionFormat"
                                TextAlign="@col.Alignment" />
                }
            </GridColumns>
        </SfGrid>

        <div class="report-footer">
            @_reportData.RowCount rows
            — generated @_generatedAt.ToString("yyyy-MM-dd HH:mm") UTC
        </div>
    }
</div>

@code {
    [Parameter] public required string ReportId { get; set; }

    private ReportParameters _parameters      = new();
    private ReportData?      _reportData;
    private Guid?            _jobId;
    private bool             _isRunning;
    private DateTime         _generatedAt;

    private async Task RunReport()
    {
        _isRunning  = true;
        _reportData = null;
        _jobId      = null;

        var result = await _reportService.RunReportAsync(
            ReportId, _parameters, CurrentUser.Id);

        if (result.IsAsync)
            _jobId = result.JobId;
        else
        {
            _reportData  = result.Data;
            _generatedAt = DateTime.UtcNow;
        }

        _isRunning = false;
    }

    private async Task ExportAsync(string format)
    {
        var stream = format switch
        {
            "csv"  => await _exportService.ExportCsvAsync(
                          ReportId, _parameters, CurrentUser.Id),
            "xlsx" => await _exportService.ExportXlsxAsync(
                          ReportId, _parameters, CurrentUser.Id),
            "pdf"  => await _exportService.ExportPdfAsync(
                          ReportId, _parameters, CurrentUser.Id),
            _      => throw new ArgumentException(nameof(format))
        };

        var mimeType = format switch
        {
            "csv"  => "text/csv",
            "xlsx" => "application/vnd.openxmlformats-officedocument"
                    + ".spreadsheetml.sheet",
            "pdf"  => "application/pdf",
            _      => "application/octet-stream"
        };

        var fileName = $"{ReportId}_{DateTime.UtcNow:yyyyMMdd}.{format}";
        await _jsRuntime.InvokeVoidAsync(
            "blazorDownload", fileName, mimeType,
            Convert.ToBase64String(((MemoryStream)stream).ToArray()));
    }
}
```

**Date-range filter** on date columns uses the platform-standard `DateRangeFilter` component per ADR-006.

---

### 11.3 Individual Report Pages

Each of the 16 reports has a dedicated Blazor page that renders the `ReportRunner` component with the correct `ReportId` and configures the parameter panel for that report's specific filters. All 16 pages are thin wrappers — the business logic is entirely in `ReportRunner` and the query classes.

---

## 12. Access Control

Default role-to-report access per REQ-RPT-062. The `CanAccessReport` method in the access control layer enforces this. Role-to-report mappings are configurable without a code change per REQ-RPT-063.

| Role | Payroll Reports | HR Reports |
|---|---|---|
| PayrollOperator | PAY-RPT-001, 004 | None |
| PayrollAdmin | All payroll | None |
| HrisAdmin | None | All HR |
| Finance | PAY-RPT-002, 003, 007, 008 | HR-RPT-001, 003, 006 |
| Manager | None | HR-RPT-001, 004, 007 (scoped to direct reports) |
| Auditor | All (read-only) | All (read-only) |

---

## 13. Role Definitions

| Role | Description |
|---|---|
| `ReportViewer` | Base role — can see the Reports menu; access to specific reports governed by more specific roles above |
| `ReportAdmin` | Can configure scheduled report delivery |

---

## 14. Test Cases

| ID | Description | Expected Result |
|---|---|---|
| TC-RPT-001 | Run PAY-RPT-001 for a completed payroll run | Payroll register returns all employee results for the run; gross/net totals correct |
| TC-RPT-002 | Run HR-RPT-001 with as-of date in the past | Headcount reflects employment state on that historical date; Temporal Override honoured |
| TC-RPT-003 | User without PayrollOperator role attempts PAY-RPT-001 | AuthorizationException thrown; no data returned |
| TC-RPT-004 | Finance user runs PAY-RPT-003 | Employer Cost report returns; scoped to Finance user's authorised legal entity |
| TC-RPT-005 | Manager runs HR-RPT-004 | Leave utilisation scoped to direct reports only; no other employees visible |
| TC-RPT-006 | Report result set exceeds async threshold | Job_ID returned immediately; progress updates via SignalR; data available on completion |
| TC-RPT-007 | Export PAY-RPT-001 as XLSX | Workbook downloaded; row 3 headers frozen; currency columns formatted; auto-sized columns |
| TC-RPT-008 | Export PAY-RPT-001 as PDF | PDF downloaded; landscape orientation; title and parameter summary in header; page numbers in footer |
| TC-RPT-009 | Export HR-RPT-001 as CSV | CSV downloaded; correct column headers; all data rows present |
| TC-RPT-010 | All three exports log to audit trail | Audit records created with user identity, timestamp, report ID, and scope parameters |
| TC-RPT-011 | PAY-RPT-006 with 5% variance threshold | Employees with period-over-period gross pay change > 5% flagged; employees below threshold excluded |
| TC-RPT-012 | HR-RPT-008 with 90-day window | Documents expiring within 90 days shown; documents outside window excluded |
| TC-RPT-013 | Schedule PAY-RPT-001 after payroll run | After run completes, report job triggered automatically; recipient notified with download link |
| TC-RPT-014 | Scheduled report retains file for 7 days | Download link valid for 7 days; after 7 days file removed |
| TC-RPT-015 | Report scope filter cannot be bypassed | Applying DepartmentId filter for a department outside user's scope returns empty result; no data leaked |
| TC-RPT-016 | Regenerate historical PAY-RPT-001 | Same results as original generation; corrections reflected if applicable |
| TC-RPT-017 | XLSX export includes totals row for numeric columns | Totals row present at bottom of workbook for sum-eligible columns |
| TC-RPT-018 | PDF export switches to landscape for wide reports | PAY-RPT-001 renders in landscape; narrower HR reports may use portrait |
