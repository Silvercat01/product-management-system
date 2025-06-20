# product-management-system
A simplified ERP system built with Oracle SQL &amp; PL/SQL. Manages products, warehouses, orders, and customers.

**Note:** All table names, column names, comments, and code logic use **Hungarian** naming conventions

## Project structure

mini_erp/
│
├── create_tables.sql
├── insert_data.sql
├── plsql_procedures.sql
├── plsql_functions.sql
├── test_calls.sql
└── er_diagram.png

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
