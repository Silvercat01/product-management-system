# product-management-system
A simplified ERP (Enterprise Resource Planning) system built with Oracle SQL &amp; PL/SQL. Manages products, warehouses, orders, and customers.

**Note:** All table names, column names, comments, and code logic use **Hungarian** naming conventions

## Project structure

```
mini_erp/
├── schema/
│   ├── tables/
│   │   ├── create_tables.sql
│   │   ├── sequences.sql
│   │   └── teardown.sql
│   └── initial_data/
│	    └── insert_data.sql
├── business_logic/
│   ├── inventory/
│   │   ├── inventory_procedures.sql - 
│   │   └── inventory_functions.sql
│   ├── orders/
│   │   └── order_procedures.sql
│   └── customers/
│       ├── customer_procedures.sql
│       └── customer_functions.sql
├── reports/
│   ├── inventory_reports.sql
│   ├── order_reports.sql
│   └── customer_reports.sql
└── tests/
    └── test_calls.sql
README.md - documentation
```

## Features

- Customer and product management
- Warehouse stock tracking
- Order processing and payment records
- PL/SQL procedures (e.g. create order, transfer stock)
- PL/SQL functions (e.g. calculate warehouse usage)

## Requirements

- Oracle SQL (tested with Oracle SQL Developer)
- No external dependencies

## Usage
1. Download or clone the repository
2. Run schema/tables/`teardown.sql` as a script - it makes sure to erase all previously created tables and sequences (it's not necessary if you set up the database for the first time)
3. Run schema/tables/`create_tables.sql` as a script - creates the basic structure of the tables, primary key and foreign key constraints
4. Run schema/tables/`create_sequences.sql` as a script - creates the sequence used for automatically incrementing order IDs
5. Run schema/initial_data/`insert_data.sql` as a script - inserts example data into each table, necessary for example queries, testing procedures and functions
7. Run the files that contain procedures and functions found in the business logic folder - compiles the procedures and functions
8. Finally, run the SQL queries found in the reports folder and run tests/`test_calls.sql` to test the PL/SQL procedures and functions as well
