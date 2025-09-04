# Introduction to pgTAP for Database Testing

This guide provides an introduction to `pgTAP`, a powerful testing framework for PostgreSQL. It will help you understand how to write and run tests to ensure your database schema and functions work as expected.

## What is pgTAP?

`pgTAP` is a suite of database functions that make it easy to write unit tests for your PostgreSQL database. It follows the principles of the Test Anything Protocol (TAP), which is a simple and flexible protocol for reporting test results. With `pgTAP`, you can test everything from schema structure to business logic within your database.

## Key Concepts

- **Test Plan:** At the beginning of your test script, you declare a "plan," which is the number of tests you expect to run. This helps ensure that your tests run completely.
- **Test Functions:** `pgTAP` provides a rich set of functions to make assertions about your database. For example, `has_table()` checks if a table exists, `col_type_is()` verifies a column's data type, and `results_eq()` compares the output of a query to expected results.
- **Test Execution:** `pgTAP` tests are typically run from the command line using the `pg_prove` utility, which comes with `pgTAP`. `pg_prove` executes your SQL test files and provides a summary of the results.

## How to Write a Test File

A `pgTAP` test file is a standard SQL file that contains a series of `SELECT` statements that call `pgTAP` functions. Here is a basic structure:

```sql
-- Start the test session
BEGIN;

-- Tell pgTAP how many tests you plan to run
SELECT plan(3); -- We plan to run 3 tests

-- Test 1: Check if the 'owner' table exists
SELECT has_table('owner');

-- Test 2: Check if the 'full_name' column exists in the 'owner' table
SELECT has_column('owner', 'full_name');

-- Test 3: Check the data type of the 'full_name' column
SELECT col_type_is('owner', 'full_name', 'character varying');

-- Finish the test session and roll back any changes
SELECT * FROM finish();
ROLLBACK;
```

### Common pgTAP Functions

- `plan(number)`: Declares the number of tests you will run.
- `has_table(table_name)`: Checks if a table exists.
- `has_column(table_name, column_name)`: Checks if a column exists in a table.
- `col_type_is(table_name, column_name, type_name)`: Checks the data type of a column.
- `has_pk(table_name)`: Checks if a table has a primary key.
- `has_fk(table_name)`: Checks if a table has a foreign key.
- `results_eq(query, expected_results_query)`: Checks if a query produces the expected results.
- `is(value, expected_value, description)`: A general-purpose function to check if a value is equal to an expected value.

## How to Run Tests

To run `pgTAP` tests, you typically use the `pg_prove` command-line utility. Here's how you would run a test file named `my_tests.sql` against your database:

```bash
pg_prove -d your_database_name -U your_username -f my_tests.sql
```

- `-d`: The name of your database..
- `-U`: The username to connect with.
- `-f`: The test file to run.

`pg_prove` will execute the SQL file and show you the results in the console, indicating which tests passed and which failed.

## Getting Started

To use `pgTAP`, you need to install it on your system and then install the `pgTAP` extension in your database. The installation process varies depending on your operating system. You can find detailed instructions on the official [pgTAP website](https://pgtap.org/).

Once installed, you can add the extension to your database by running:

```sql
CREATE EXTENSION pgtap;
```

This documentation should give you a good starting point. Now, I will create a set of tests for your project using these principles.

## Example Tests for This Project

Here are some example tests that you could write for this project in `database_tests.sql`. These tests are based on the file names and common database structures.

```sql
-- Start the test session
BEGIN;

-- Plan the number of tests
SELECT plan(8);

-- Check for custom types
SELECT has_type('tenant_type');
SELECT has_type('parking_space_type');

-- Check for tables (assuming table names from file names)
SELECT has_table('lease');
SELECT has_table('tenant');
SELECT has_table('parking_space');

-- Check for columns in the 'lease' table
SELECT has_column('lease', 'created_at');
SELECT has_column('lease', 'updated_at');

-- Check the trigger function
SELECT has_function('save_lease_data_record');


-- Finish the test session
SELECT * FROM finish();
ROLLBACK;
```