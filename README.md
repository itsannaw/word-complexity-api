# Word Complexity Score API

Asynchronous API that calculates word complexity: `score = (synonyms + antonyms) / definitions`

## Quick Start

```bash
bundle install
rails db:create db:migrate

# Terminal 1
rails server

# Terminal 2
bin/jobs
```

## API Endpoints

### POST /complexity-score
```bash
curl -X POST http://localhost:3000/complexity-score \
  -H "Content-Type: application/json" \
  -d '["happy", "sad", "angry"]'

# Response: { "job_id": "abc123" }
```

### GET /complexity-score/:job_id
```bash
curl http://localhost:3000/complexity-score/abc123

# Pending:   { "status": "pending" }
# Completed: { "status": "completed", "result": { "happy": 3.5, ... } }
```

## Testing

```bash
bundle exec rspec     # 95 examples, 0 failures
bundle exec rubocop   # Code style check
```

## API Documentation

Interactive Swagger UI available at:
```
http://localhost:3000/api-docs
```

Generate Swagger docs from tests:
```bash
bundle exec rake rswag:specs:swaggerize
```

## Tech Stack

**Backend:** Rails 8, SQLite, Solid Queue  
**External API:** Dictionary API (api.dictionaryapi.dev)  
**Testing:** RSpec, FactoryBot, WebMock

---

✅ All requirements implemented
