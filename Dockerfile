FROM golang:1.16 as builder

ENV APP_USER app
ENV APP_HOME /app
RUN groupadd $APP_USER && useradd -m -g $APP_USER -l $APP_USER
RUN mkdir -p $APP_HOME/build && chown -R $APP_USER:$APP_USER $APP_HOME
WORKDIR $APP_HOME/build
USER $APP_USER

# build master branch
# RUN git clone https://github.com/DNSCrypt/dnscrypt-proxy.git .

# build stable release
# RUN git clone https://github.com/DNSCrypt/dnscrypt-proxy.git .
# RUN git checkout tags/2.0.45 -b 2.0.45
# or
# RUN git clone --depth 1 -b 2.0.45 https://github.com/DNSCrypt/dnscrypt-proxy.git .
# or
# RUN git clone https://github.com/DNSCrypt/dnscrypt-proxy.git --branch 2.0.46-beta3 .

# build specific commit
RUN git clone https://github.com/DNSCrypt/dnscrypt-proxy.git . \
    && git checkout 0ca90dd8cc41d1a77c48c28827a42b541e147beb && git reset --hard

WORKDIR $APP_HOME/build/dnscrypt-proxy

# Enable and adjust git commit, when you build specific commit above
RUN sed -i -E 's/[0-9]{1}.[0-9]{1}.[0-9]{2}-[a-z]{4}[0-9]{1}/&-git-0ca90dd/' main.go

ENV CGO_ENABLED=0
ENV GOOS=linux
ENV GOARCH=amd64
RUN go clean \
    && go build -mod vendor -ldflags="-s -w" \
    && cp -p dnscrypt-proxy $APP_HOME/

WORKDIR $APP_HOME

RUN rm -rf build

FROM alpine

ENV APP_HOME /app
WORKDIR $APP_HOME

ENV LOCAL_PORT 53

COPY --chown=0:0 --from=builder $APP_HOME/dnscrypt-proxy $APP_HOME

ADD dnscrypt-proxy.toml /config/dnscrypt-proxy.toml

EXPOSE $LOCAL_PORT/tcp $LOCAL_PORT/udp

ENTRYPOINT ["./dnscrypt-proxy"]

CMD ["-config", "/config/dnscrypt-proxy.toml"]
