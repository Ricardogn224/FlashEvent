FROM golang:latest

WORKDIR /app
COPY ./backend .

RUN go mod tidy
RUN go mod download

RUN cd cmd && go build -o main .

EXPOSE 8080

CMD ["./cmd/main"]


