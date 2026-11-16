# Caddy with the dynv6 DNS provider (ACME DNS-01 for *.dynv6.net names).
#
# Both FROM lines are pinned by tag and digest and updated together by Dependabot.
# The builder compiles the Caddy version it ships (its CADDY_VERSION), cross-compiled
# for the target platform, so no emulation is needed. The build checks that the
# binary and the runtime image are the same Caddy version.
FROM --platform=$BUILDPLATFORM caddy:2.11.9-builder@sha256:345264d8c6b50f44f4a4d507d4e6b6bcae40eef2f210d70f76e717fd8cc31baf AS builder

ARG TARGETOS TARGETARCH TARGETVARIANT
# caddy-dns/dynv6 has no releases, so it's pinned to a commit. Update it by hand (see README).
ARG DYNV6_MODULE=github.com/caddy-dns/dynv6@71fad600afb29911aa04cbfd99f7d5d878c3bc48

RUN GOOS="$TARGETOS" GOARCH="$TARGETARCH" GOARM="${TARGETVARIANT#v}" \
    xcaddy build --with "$DYNV6_MODULE" --output /usr/bin/caddy

FROM caddy:2.11.9@sha256:4e2425f6009577e7c651010f16679c28f7d12df3e7b1914f941a7a3370746b3c

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
