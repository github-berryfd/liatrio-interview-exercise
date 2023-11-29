FROM golang:latest as builder

LABEL maintainer="Daniel"

WORKDIR /opt/build-go-app

COPY go.mod go.sum ./

RUN go mod download && go mod verify

COPY . .

# Statically linked so that the libararies are included directly. (CGO_ENABLED=0)
# Alpine Linux uses musl libc instead of glibc (the GNU C Library), which is commonly used in other Linux distributions.
RUN CGO_ENABLED=0 go build -v -o /opt/release/liatrio-exercise.exe ./cmd/liatrio-service/main.go

FROM golang:alpine

WORKDIR /opt/liatrio

COPY --from=builder /opt/release/liatrio-exercise.exe /opt/liatrio/

EXPOSE 8080

CMD ["/opt/liatrio/liatrio-exercise.exe"] 