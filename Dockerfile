# Caddy with the dynv6 DNS provider (ACME DNS-01 for *.dynv6.net names).
#
# Both FROM lines are pinned by tag and digest and updated together by Dependabot.
# The builder compiles the Caddy version it ships (its CADDY_VERSION), cross-compiled
# for the target platform, so no emulation is needed. The build checks that the
# binary and the runtime image are the same Caddy version.
FROM --platform=$BUILDPLATFORM caddy:2.11.9-builder@sha256:3fddbec729442a56b942d4c9eaef1df80893dbf2cf5b86701bfae6aad1408eeb AS builder

ARG TARGETOS TARGETARCH TARGETVARIANT
# caddy-dns/dynv6 has no releases, so it's pinned to a commit. Update it by hand (see README).
ARG DYNV6_MODULE=github.com/caddy-dns/dynv6@71fad600afb29911aa04cbfd99f7d5d878c3bc48

RUN GOOS="$TARGETOS" GOARCH="$TARGETARCH" GOARM="${TARGETVARIANT#v}" \
    xcaddy build --with "$DYNV6_MODULE" --output /usr/bin/caddy

FROM caddy:2.11.9@sha256:0c2243efcf437ab7f7a978f1027fcf0d4f9be8a75df27b1b3fbc5dbe0ffa8cf0

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
