FROM golang:1.20.4-alpine

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY cmd/ops-test-app ./cmd/ops-test-app
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build ./cmd/ops-test-app

EXPOSE 8080

CMD [ "./ops-test-app" ]
