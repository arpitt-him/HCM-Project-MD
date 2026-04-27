# ADR-004 — Data Access Strategy: Dapper with Manual SQL

| Field | Detail |
|---|---|
| **Document Type** | Architecture Decision Record |
| **Version** | v0.2 |
| **Status** | Accepted |
| **Owner** | Core Platform |
| **Location** | `docs/ADR/ADR-004_Data_Access_Strategy.md` |
| **Date** | April 2026 |
| **Related Documents** | PRD-0100_Architecture_Principles, ADR-001_Event_Driven_Architecture, ADR-002_Deterministic_Replayability, ADR-003_UI_Technology_Stack, docs/architecture/processing/Async_Job_Execution_Model.md, docs/architecture/governance/Correction_and_Immutability_Model.md, schemas/dbml/, schemas/ddl/ |

---

## Context

The platform requires a data access strategy that supports a complex payroll domain with the following characteristics:

- Multi-step transactional writes with precisely defined atomicity boundaries — payroll run state transitions, accumulator mutation sequences, and correction lineage writes must succeed or fail as governed units
- High-volume insert paths — a payroll run for a large population generates hundreds of thousands of accumulator impact, contribution, and result line records; insert performance matters
- Complex query shapes — lineage chain traversal, period-over-period variance, accumulator balance reconstruction, and cross-table reporting joins require SQL that is difficult to express cleanly through an ORM abstraction
- Deterministic replayability (ADR-002) — the exact SQL executing against historical data must be knowable and auditable; ORM-generated SQL can vary between versions and is harder to reason about in a compliance context
- DBMS portability — the platform must support on-premises deployments against the client's DBMS of choice; the data access layer must not be tightly coupled to any single database vendor
- Schema ownership — DDL is managed manually from DBML source files; the data access layer does not own or manage schema migrations

Entity Framework Core was evaluated as the primary ORM alternative. Stored procedures, raw ADO.NET, and Dapper were also considered.

---

## Decision

**The platform data access layer shall use Dapper as a micro-ORM over ADO.NET, with all SQL written manually.**

Dapper provides lightweight mapping between SQL query results and C# objects without generating SQL or managing schema. All SQL statements are written explicitly by the development team. Transactions use raw ADO.NET `IDbTransaction` scoped through a unit of work pattern.

### Key Rationale

**Full SQL control.** Every query and write operation is an explicit, readable SQL statement. There is no ORM-generated SQL that can change behaviour between framework versions or produce unexpected query shapes. This is directly aligned with ADR-002 — the SQL executing against historical data is deterministic and auditable.

**Precise transaction control.** The accumulator mutation chain, payroll run state transitions, and correction lineage writes require atomic multi-statement transactions with explicit ordering. Raw ADO.NET transactions give the application full control over commit and rollback boundaries without ORM interference. Dapper participates cleanly in ADO.NET transactions.

**Performance on high-volume paths.** Dapper's overhead over raw ADO.NET is minimal — it adds only the object mapping step. For high-volume insert paths (accumulator impacts, result lines, contributions) this matters. EF Core's change tracking and identity map add overhead that is unnecessary for append-only write patterns.

**DBMS portability.** Dapper works through any ADO.NET-compatible provider. Switching between PostgreSQL (Npgsql), SQL Server (Microsoft.Data.SqlClient), and MySQL (MySql.Data or Pomelo) requires only a connection string and provider package change. The SQL itself uses standard ANSI syntax where possible, with dialect differences managed through a thin provider abstraction. Parameter syntax (`@paramname`) is consistent across PostgreSQL, SQL Server, and MySQL — minimising dialect-specific handling.

**Schema independence.** Dapper has no knowledge of schema structure and does not manage migrations. The DBML-sourced DDL files in `schemas/ddl/*` remain the sole source of truth for schema definition. This separation is intentional — schema evolution is a deployment concern, not an application concern.

**No stored procedures.** Business logic resides entirely in the application layer. Stored procedures fragment domain logic across application and database, complicate version control, and create a maintenance surface that grows with platform complexity. They are not used.

---

## Transaction and Unit of Work Pattern

Multi-step write operations shall use the following pattern:

```csharp
// Unit of work scopes a transaction across multiple Dapper operations
using var connection = _connectionFactory.Create();
connection.Open();
using var transaction = connection.BeginTransaction();

try
{
    // Multiple Dapper writes participate in the same transaction
    await connection.ExecuteAsync(sql1, params1, transaction);
    await connection.ExecuteAsync(sql2, params2, transaction);
    await connection.ExecuteAsync(sql3, params3, transaction);
    
    transaction.Commit();
}
catch
{
    transaction.Rollback();
    throw;
}
```

This pattern is mandatory for:
- Payroll run state transitions
- Accumulator mutation sequences (Impact → Contribution → Balance update)
- Correction lineage writes
- Any operation that must succeed or fail as a governed unit per the Correction_and_Immutability_Model

---

## DBMS Portability Implementation

The connection factory shall return an `IDbConnection` based on a deployment configuration setting. Application code interacts with `IDbConnection` — it has no knowledge of the specific provider:

```csharp
public interface IConnectionFactory
{
    IDbConnection Create();
}

// Registered at startup based on configuration
// PostgreSQL: new NpgsqlConnection(connectionString)
// SQL Server: new SqlConnection(connectionString)
// MySQL:      new MySqlConnection(connectionString)
```

SQL dialect differences shall be managed through named query providers where necessary — for example, date arithmetic and string functions that differ between providers. These are isolated to a thin abstraction layer rather than scattered through domain code.

---

## Consequences

**Positive:**
- Complete visibility into every SQL statement executing against the database
- Precise transaction control aligned with domain atomicity requirements
- Minimal performance overhead on high-volume write paths
- DBMS portability through provider abstraction
- No ORM migration system competing with manually managed DDL
- Domain logic remains entirely in the application layer

**Constraints to manage:**
- All SQL must be written and maintained manually — boilerplate CRUD operations require explicit implementation rather than generation
- Query result mapping for complex joins requires attention — Dapper's multi-mapping must be used correctly for nested object graphs
- SQL dialect differences between providers must be managed explicitly for any non-standard SQL constructs
- There is no ORM-level caching or identity map — applications that need result caching must implement it explicitly

**Future consideration:**
- As the query library grows, a query object pattern (encapsulating SQL strings and parameter construction in dedicated query classes) is recommended to prevent SQL strings from scattering across the codebase
- A lightweight integration test suite against each supported DBMS provider should be established early to catch dialect regressions

---

## Alternatives Considered

**Entity Framework Core**
Full ORM with LINQ query generation, change tracking, migration management, and identity map. Rejected because: generated SQL is not fully controllable and can vary between EF Core versions; change tracking adds overhead inappropriate for append-only high-volume write paths; the migration system conflicts with the decision to manage DDL from DBML source; ORM abstractions obscure the precise execution semantics required by ADR-002. EF Core's strengths (rapid CRUD scaffolding, LINQ query composition) do not align with this platform's primary data access challenges.

**Raw ADO.NET only**
Maximum control, no dependencies beyond the provider. Rejected because: Dapper's object mapping eliminates significant boilerplate without sacrificing control; the productivity cost of raw DataReader mapping for every query is not justified when Dapper provides the same SQL control with clean result materialisation.

**Stored Procedures**
Business logic encapsulated in the database. Rejected because: fragments domain logic across application and database layers; complicates version control and deployment; creates a maintenance surface that conflicts with the modular architecture; makes the codebase harder to reason about, test, and port across DBMS providers.

**Marten (PostgreSQL document/event store)**
PostgreSQL-specific document and event store with .NET integration. Rejected because: creates a hard dependency on PostgreSQL, directly conflicting with the DBMS portability requirement.
