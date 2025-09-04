# Local Database Project

This project contains the Data Definition Language (DDL) and other SQL scripts for a local database.

## Operating System

This project is being developed on an Ubuntu operating system.

## Project Structure

```
.
├── created_at&updated_at_in_all_tables.sql
├── database_tests.sql
├── DDL.sql
├── f_save_lease_history_data.sql
├── parking_space_type_enum.sql
├── pgTAP_documentation.md
├── populate_database.sql
├── README.md
├── tenant_type_enum.sql
├── test_queries.sql
└── trg_save_lease_data_record.sql
```

## Files

*   `DDL.sql`: This script contains the main DDL for creating the database schema, including tables, columns, and constraints.
*   `populate_database.sql`: This script populates the database with initial data.
*   `created_at&updated_at_in_all_tables.sql`: This script adds `created_at` and `updated_at` columns to all tables in the database to track record creation and updates.
*   `f_save_lease_history_data.sql`: This script contains a function to save lease history data.
*   `parking_space_type_enum.sql`: This script defines a custom enumeration type for parking space types.
*   `tenant_type_enum.sql`: This script defines a custom enumeration type for tenant types.
*   `trg_save_lease_data_record.sql`: This script contains a trigger to save a record of lease data changes.
*   `database_tests.sql`: This script contains tests for the database schema and functions using pgTAP.
*   `test_queries.sql`: This script contains various queries for testing and interacting with the database.
*   `pgTAP_documentation.md`: Documentation for the pgTAP testing framework.
*   `README.md`: This file.

## How to Use

1.  **Create the database schema:** Run the `DDL.sql` script.
2.  **Populate the database:** Run the `populate_database.sql` script.
3.  **Run tests:** Use the `pg_prove` utility to run the tests in `database_tests.sql`.
