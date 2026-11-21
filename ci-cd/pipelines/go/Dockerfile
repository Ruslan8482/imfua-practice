FROM golang:1.22-alpine AS build

WORKDIR /src
COPY go.mod ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -trimpath -o /out/app .

FROM alpine:3.20

COPY --from=build /out/app /usr/local/bin/app
ENTRYPOINT ["app"]
