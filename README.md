# Football Analytics (Beginner → Intermediate)

A compact football database focused on players, clubs, matches, events, and transfers.
Use it to practice joins, CTEs, window functions, constraints, and indexing.

## Learning Objectives
- Model sports entities & M:N relationships.
- Write analytics queries (top scorers, form table, disciplinary charts).
- Use window functions (ROW_NUMBER, SUM OVER, moving totals).
- Create views and helpful indexes.

## Files
- `schema.sql` — Tables, constraints, and indexes.
- `seed.sql` — Sample data for 3 clubs and a few matches.
- `queries.sql` — Analytics queries (window functions, CTEs, views).

## Load & Run
```bash
psql -h localhost -p 5432 -U postgres -d playground -f projects/football_analytics/schema.sql
psql -h localhost -p 5432 -U postgres -d playground -f projects/football_analytics/seed.sql
psql -h localhost -p 5432 -U postgres -d playground -f projects/football_analytics/queries.sql
```