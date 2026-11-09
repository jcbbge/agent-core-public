# Standard: databases

Written for Postgres, whether self-hosted or on any managed provider. The principles hold for any
SQL database.

### 1. Reachability
- The database is never open to the internet. Clients reach it over a private network or an allowlist, with TLS required and the certificate verified (`sslmode=verify-full`).
- Clients never reach the database. Only server-side code does.
  *Measure:* a connection from an address not on the allowlist fails; a connection without TLS fails.

### 2. Roles: one per purpose, least privilege
- Never let the application connect as the owner or a superuser. Separate roles for: migrations (owns the schema), app read-write, read-only consumers (reporting, MCP, agents), and humans.
- Read-only roles are read-only *in the database*: they have only `SELECT` grants and `default_transaction_read_only = on`.
- Grant only on the schemas and tables each role needs. Revoke default privileges from `PUBLIC`.
  *Measure:* a write as a read-only role fails; the app role cannot `CREATE`, `DROP` or `ALTER`; listing each role's grants matches the written intent.

### 3. Row access
- Tenant or owner scoping is enforced in every query, by a required parameter in the data layer or by row-level security for shared tables. Prefer row-level security where several tenants share a table.
  *Measure:* querying as tenant A never returns tenant B's rows, including through joins, counts and search.

### 4. Queries
- Parameterized only. No string-built SQL from input. Dynamic identifiers (sort column, table name) come from an allowlist.
- Every role has a `statement_timeout`, and long-running jobs get their own role with its own budget. `idle_in_transaction_session_timeout` is set. Connection pools are bounded.
- Every list query has a `LIMIT`.
  *Measure:* an injection payload is stored as literal text; a deliberately slow query is cancelled at the timeout.

### 5. Credentials
- One credential per role per environment, loaded at runtime and rotatable without a code change. Development and preview environments never hold production credentials.
- A preview or branch database that holds real data is treated as production.
  *Measure:* rotating the app credential needs only a secret update and a restart.

### 6. Migrations
- Migrations run under the migration role from the deploy path, never from the app at request time. They can be rolled back or rolled forward, and are reviewed like code.
  *Measure:* the app role cannot run DDL.

### 7. Data at rest and backups
- Sensitive columns are identified. Secrets and tokens are stored as hashes or encrypted. Personal data is kept to what the purpose needs.
- Backups are automatic, encrypted and stored apart from the primary. **A restore is tested on a schedule.**
  *Measure:* a restore from the latest backup into a scratch instance succeeds and is dated within the period.

### 8. Audit
- Changes to roles, grants and schema, plus logins by humans, are logged.
  *Measure:* a grant change shows up in the log.
