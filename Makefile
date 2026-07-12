.PHONY: api test fmt compose-up compose-down

api:
	cd services/api && go run ./cmd/api

test:
	cd services/api && go test ./...

fmt:
	cd services/api && gofmt -w .

compose-up:
	docker compose up --build

compose-down:
	docker compose down

