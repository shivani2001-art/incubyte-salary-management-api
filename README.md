# Salary Management API

A production-ready Rails API for managing employees, calculating salary deductions, and providing salary analytics. Built as part of the Incubyte engineering hiring kata.

## Tech Stack

| Component       | Choice           |
|-----------------|------------------|
| Language        | Ruby 3.3.10      |
| Framework       | Rails 8.1.2 (API mode) |
| Database        | SQLite3          |  
| Authentication  | JWT (stateless)  |
| Testing         | RSpec, FactoryBot, Shoulda Matchers |
| API Docs        | Swagger UI (rswag) |
| Serialization   | Blueprinter        |
| Pagination      | Pagy               |
| Rate Limiting   | Rack::Attack       |

## Prerequisites

- Ruby 3.3.10 (managed via rbenv)
- Bundler
- SQLite3

## Getting Started

```bash
# Clone the repo
git clone <repo-url>
cd Incubyte

# Set ruby version
rbenv install 3.3.10
rbenv local 3.3.10

# Install dependencies
bundle install

# Setup database (create, migrate, seed)
bin/rails db:setup

# Start the server
bin/rails server
```

Open [http://localhost:3000](http://localhost:3000) — it redirects to Swagger UI where you can explore and test all endpoints interactively.

### Seed Data

The seed creates:
- **User**: `admin@example.com` / `password123`
- **8 employees** across India, United States, and Germany with various job titles

## Running Tests

```bash
bundle exec rspec
```

Currently **58 specs**, all passing — covering models, services, serializers, pagination, rate limiting, and request specs for every endpoint.

## API Endpoints

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| POST | `/auth/signup` | Register a new user | No |
| POST | `/auth/login` | Login, get JWT token | No |
| GET | `/api/v1/employees` | List all employees (paginated) | Yes |
| GET | `/api/v1/employees/:id` | Get single employee | Yes |
| POST | `/api/v1/employees` | Create employee | Yes |
| PUT | `/api/v1/employees/:id` | Update employee | Yes |
| DELETE | `/api/v1/employees/:id` | Delete employee | Yes |
| GET | `/api/v1/employees/:id/salary` | Calculate net salary | Yes |
| GET | `/api/v1/salary_metrics/by_country?country=` | Min/max/avg salary by country | Yes |
| GET | `/api/v1/salary_metrics/by_job_title?job_title=` | Avg salary by job title | Yes |

### Quick Start with curl

```bash
# 1. Sign up or login to get a token
TOKEN=$(curl -s -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "admin@example.com", "password": "password123"}' | ruby -rjson -e 'puts JSON.parse(STDIN.read)["token"]')

# 2. List employees
curl http://localhost:3000/api/v1/employees \
  -H "Authorization: Bearer $TOKEN"

# 3. Create an employee
curl -X POST http://localhost:3000/api/v1/employees \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"employee": {"full_name": "Jane Doe", "job_title": "Engineer", "country": "India", "salary": 70000}}'

# 4. Calculate salary with deductions
curl http://localhost:3000/api/v1/employees/1/salary \
  -H "Authorization: Bearer $TOKEN"

# 5. Get salary metrics by country
curl "http://localhost:3000/api/v1/salary_metrics/by_country?country=India" \
  -H "Authorization: Bearer $TOKEN"

# 6. Get average salary by job title
curl "http://localhost:3000/api/v1/salary_metrics/by_job_title?job_title=Engineer" \
  -H "Authorization: Bearer $TOKEN"
```

### Employee Fields

| Field      | Type    | Required | Notes |
|------------|---------|----------|-------|
| full_name  | string  | Yes      |       |
| job_title  | string  | Yes      |       |
| country    | string  | Yes      |       |
| salary     | decimal | Yes      | Must be > 0 |

### Pagination

The `GET /api/v1/employees` endpoint is paginated (20 per page by default).

```bash
# Page 2, 10 per page
curl "http://localhost:3000/api/v1/employees?page=2&per_page=10" \
  -H "Authorization: Bearer $TOKEN"
```

Response headers include:
| Header | Description |
|--------|-------------|
| `Current-Page` | Current page number |
| `Total-Pages` | Total number of pages |
| `Total-Count` | Total number of records |

### Rate Limiting

Auth and API endpoints are protected by rate limiting (Rack::Attack) to prevent brute-force attacks.

| Endpoint | Limit | Window |
|----------|-------|--------|
| `POST /auth/login` | 5 requests | per 60 seconds |
| `POST /auth/signup` | 5 requests | per 60 seconds |
| `/api/*` | 100 requests | per 60 seconds |

Exceeding the limit returns a `429 Too Many Requests` response:

```bash
# Demonstrate rate limiting - send 6 rapid login attempts
for i in $(seq 1 6); do
  echo "Request $i: $(curl -s -o /dev/null -w '%{http_code}' -X POST http://localhost:3000/auth/login \
    -H 'Content-Type: application/json' \
    -d '{"email": "test@test.com", "password": "wrong"}')"
done

# Output:
# Request 1: 401
# Request 2: 401
# Request 3: 401
# Request 4: 401
# Request 5: 401
# Request 6: 429  <-- rate limited
```

### JSON Serialization

API responses use Blueprinter serializers to control which fields are exposed. Employee responses return only `id`, `full_name`, `job_title`, `country`, and `salary` — no internal fields like `created_at` or `updated_at`.

### Salary Deduction Rules

| Country       | Deduction | Rate |
|---------------|-----------|------|
| India         | TDS       | 10%  |
| United States | TDS       | 12%  |
| All others    | None      | 0%   |

## Project Structure

```
app/
├── controllers/
│   ├── application_controller.rb        # Base controller with auth + error handling
│   ├── authentication_controller.rb     # Signup & login
│   ├── concerns/
│   │   ├── authenticatable.rb           # JWT auth before_action
│   │   └── error_handling.rb            # Global rescue_from handlers
│   └── api/v1/
│       ├── employees_controller.rb      # CRUD
│       ├── salary_calculations_controller.rb
│       └── salary_metrics_controller.rb
├── blueprints/
│   └── employee_blueprint.rb            # JSON serializer (controls exposed fields)
├── models/
│   ├── user.rb                          # has_secure_password, email validation
│   └── employee.rb                      # Presence + numericality validations
└── services/
    ├── jwt_service.rb                   # Token encode/decode
    └── salary_calculator.rb             # Country-based TDS deduction logic
```

## TDD Approach

This project was built using strict **red-green-refactor** TDD. The commit history reflects this:

1. **Red** — Write failing specs first (`test: ...specs (red)`)
2. **Green** — Write minimum code to make them pass (`feat: ...implementation (green)`)
3. **Refactor** — Clean up and extract shared concerns (`refactor: ...`)

Each feature (auth, CRUD, salary calculation, metrics) follows this cycle. Run `git log --oneline` to see the full progression.

## Live Demo

Deployed on [Render](https://render.com):

> **[https://incubyte-salary-management-api.onrender.com](https://incubyte-salary-management-api.onrender.com)**

Swagger UI is available at the root URL. Free tier may take ~30s to wake up on first request.

## Implementation Details

AI (Claude Code) was used as a development aid for:
- Project scaffolding and initial gem selection
- Generating test cases from requirements
- Writing controller and service boilerplate
- Generating Swagger/OpenAPI documentation
- Writing this README

All generated code was reviewed, tested, and iterated on throughout the development process. The TDD workflow ensured correctness at every step — specs were verified to fail before implementation and pass after.
