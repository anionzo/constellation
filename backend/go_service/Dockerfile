# Stage 1: Build binary using official Go Alpine image
FROM golang:1.22-alpine AS builder

WORKDIR /app

# Download dependencies
COPY go.mod go.sum* ./
RUN go mod download || true

# Copy source code and compile statically linked binary
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o /bin/bff ./cmd/server

# Stage 2: Minimal runtime image (< 20MB)
FROM alpine:3.19

RUN apk --no-cache add ca-certificates tzdata

COPY --from=builder /bin/bff /bin/bff

EXPOSE 8000

USER nobody:nobody

ENTRYPOINT ["/bin/bff"]
