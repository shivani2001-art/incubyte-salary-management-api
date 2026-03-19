# Salary Management API

A Rails API for managing employees and computing salary deductions. Built as part of the Incubyte engineering kata.

## Tech Stack

- Ruby 3.3.10
- Rails 8.1.2 (API mode)
- SQLite3
- RSpec for testing
- JWT for authentication

## Setup

```bash
# Install dependencies
bundle install

# Create and seed the database
rails db:setup

# Run the server
rails server
```

The seed data creates a default user (`admin@example.com` / `password123`) and 8 sample employees.

## Running Tests

```bash
bundle exec rspec
```

## API Endpoints

All endpoints except login require a JWT token in the `Authorization: Bearer <token>` header.

### Authentication

**POST /auth/login**

```bash
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "admin@example.com", "password": "password123"}'
```

Returns: `{ "token": "eyJhbG..." }`

### Employees CRUD

```bash
# List all employees
curl http://localhost:3000/api/v1/employees -H "Authorization: Bearer <token>"

# Get single employee
curl http://localhost:3000/api/v1/employees/1 -H "Authorization: Bearer <token>"

# Create employee
curl -X POST http://localhost:3000/api/v1/employees \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"employee": {"full_name": "Jane Doe", "job_title": "Engineer", "country": "India", "salary": 70000}}'

# Update employee
curl -X PUT http://localhost:3000/api/v1/employees/1 \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"employee": {"salary": 80000}}'

# Delete employee
curl -X DELETE http://localhost:3000/api/v1/employees/1 -H "Authorization: Bearer <token>"
```

### Salary Calculation

Returns gross salary, deductions, and net salary based on the employee's country.

- India: 10% TDS
- United States: 12% TDS
- All others: no deductions

```bash
curl http://localhost:3000/api/v1/employees/1/salary -H "Authorization: Bearer <token>"
```

### Salary Metrics

```bash
# Get salary stats by country (min, max, avg)
curl "http://localhost:3000/api/v1/salary_metrics/by_country?country=India" \
  -H "Authorization: Bearer <token>"

# Get average salary by job title
curl "http://localhost:3000/api/v1/salary_metrics/by_job_title?job_title=Engineer" \
  -H "Authorization: Bearer <token>"
```

## TDD Approach

Built using strict red-green-refactor TDD. Each feature was developed by:

1. Writing failing specs first
2. Implementing the minimum code to make them pass
3. Refactoring where appropriate

The commit history reflects this incremental development process.

## Implementation Details

AI (Claude) was used for:
- Initial project scaffolding and gem selection
- Generating test cases and controller boilerplate
- Writing this README

All generated code was reviewed, tested, and adjusted as part of the development process.
