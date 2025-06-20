# product-management-system
A simplified ERP system built with Oracle SQL &amp; PL/SQL. Manages products, warehouses, orders, and customers.

**Note:** All table names, column names, comments, and code logic use **Hungarian** naming conventions

## Project structure

```
mini_erp/
├── create_tables.sql - all `CREATE TABLE` and sequence definitions
├── insert_data.sql - initial data inserts
├── plsql_procedures.sql - stored procedures (e.g., new order, stock transfer)
├── plsql_functions.sql - stored functions (e.g., warehouse usage)
├── test_calls.sql - test examples to call procedures/functions
└── er_diagram.png - entity-relationship model
README.md - documentation
```

## Features

- Customer and product management
- Warehouse stock tracking
- Order processing and payment records
- PL/SQL procedures (e.g. create order, transfer stock)
- PL/SQL functions (e.g. calculate warehouse usage)
- Entity-relationship visualization using [dbdiagram.io](https://dbdiagram.io)

## Requirements

- Oracle SQL (tested with Oracle SQL Developer)
- No external dependencies

## Usage
1. Download or clone the repository
2. Run `create_tables.sql` as a script
3. Run `insert_data.sql` as a script
4. Run `plsql_functions.sql` and `plsql_procedures.sql`
5. Finally, run `test_calls.sql` to test the procedures/functions
