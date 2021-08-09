# odoh-resolver Docker

This project provides a **Dockerfile** for  [dnscrypt-proxy](https://github.com/DNSCrypt/dnscrypt-proxy) project with a configuration specific to **Oblivious DNS over HTTPS** **(ODoH)**. Everything described or configured is purely for ODoH, but you can of course also provide a custom configuration to use everything else related to _dnscrypt-proxy_.

The **dnscrypt-proxy** listens on port `53` to accept standard **Do53** requests via tcp or udp, which then get forwarded via the **odoh** protocol to the configured servers.

Below are a few examples on how to run the container.

## Examples

 Build in configuration has the following 2 servers configured.

- ODoH target `odoh.cloudflare-dns.com`
- ODoH proxy `odoh1.surfdomainen.nl`

Run the container with a build-in configuration.

    docker run -it - \
      --name odoh-resolver \
      -p 53:53/tcp \
      -p 53:53/udp \
      mschirrmeister/odoh-resolver:latest

Run the container with own custom configuration.

    docker run -it -d \
      --name odoh-resolver \
      -p 53:53/tcp \
      -p 53:53/udp \
      -v /Users/marco/MyData/git/public/odoh-resolver-docker/odoh-proxied.toml:/config/odoh-proxied.toml \
      mschirrmeister/odoh-resolver:latest -loglevel 1 -config /config/odoh-proxied.toml -pidfile /var/run/odoh-proxied.pidfile

