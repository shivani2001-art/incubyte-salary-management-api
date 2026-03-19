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

Currently **49 specs**, all passing — covering models, services, and request specs for every endpoint.

## API Endpoints

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| POST | `/auth/signup` | Register a new user | No |
| POST | `/auth/login` | Login, get JWT token | No |
| GET | `/api/v1/employees` | List all employees | Yes |
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

## Deployment (Render)

Vercel doesn't support Ruby/Rails. [Render](https://render.com) is the easiest free option.

### Steps

1. Push your code to GitHub
2. Go to [render.com](https://render.com) and sign up / log in
3. Click **New > Web Service**
4. Connect your GitHub repo
5. Configure the service:

| Setting | Value |
|---------|-------|
| **Runtime** | Ruby |
| **Build Command** | `bundle install && bin/rails db:migrate && bin/rails db:seed` |
| **Start Command** | `bin/rails server -b 0.0.0.0 -p $PORT` |
| **Environment** | Set `RAILS_ENV=production`, `RAILS_MASTER_KEY=<your key>`, `SECRET_KEY_BASE=<generate one>` |

6. Click **Deploy**

### Generate a secret key

```bash
bin/rails secret
```

Copy the output and set it as `SECRET_KEY_BASE` in Render's environment variables.

### Notes

- Render's free tier uses ephemeral storage — SQLite data resets on each deploy. For persistence, switch to PostgreSQL (Render offers a free managed Postgres instance).
- Your `config/credentials.yml.enc` requires `RAILS_MASTER_KEY` to decrypt in production. Find it in `config/master.key` locally.

## Implementation Details

AI (Claude Code) was used as a development aid for:
- Project scaffolding and initial gem selection
- Generating test cases from requirements
- Writing controller and service boilerplate
- Generating Swagger/OpenAPI documentation
- Writing this README

All generated code was reviewed, tested, and iterated on throughout the development process. The TDD workflow ensured correctness at every step — specs were verified to fail before implementation and pass after.
