# Caddy with the dynv6 DNS provider (ACME DNS-01 for *.dynv6.net names).
#
# Both FROM lines are pinned by tag and digest and updated together by Dependabot.
# The builder compiles the Caddy version it ships (its CADDY_VERSION), cross-compiled
# for the target platform, so no emulation is needed. The build checks that the
# binary and the runtime image are the same Caddy version.
FROM --platform=$BUILDPLATFORM caddy:2.11.9-builder@sha256:f9beaa5ddbe7df6f26ebbcf9cbf44e05a1917b9bba464f0c3229038d7e2e6e13 AS builder

ARG TARGETOS TARGETARCH TARGETVARIANT
# caddy-dns/dynv6 has no releases, so it's pinned to a commit. Update it by hand (see README).
ARG DYNV6_MODULE=github.com/caddy-dns/dynv6@71fad600afb29911aa04cbfd99f7d5d878c3bc48

RUN GOOS="$TARGETOS" GOARCH="$TARGETARCH" GOARM="${TARGETVARIANT#v}" \
    xcaddy build --with "$DYNV6_MODULE" --output /usr/bin/caddy

FROM caddy:2.11.9@sha256:4851e54a46b206517c574821bb5cc67f170d2156041e9fbc4c9193b45e84a75b

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
