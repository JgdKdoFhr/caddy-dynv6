# caddy-dynv6

[Caddy](https://caddyserver.com/) with the [dynv6 DNS provider](https://github.com/caddy-dns/dynv6), so Caddy can get certificates for names under a [dynv6.com](https://dynv6.com/) zone via the ACME DNS-01 challenge. That also works for hosts that can't be reached from the internet. It is the official `caddy` image with the binary rebuilt by `xcaddy`, for amd64, arm64 and arm/v7.

> [!NOTE]
> **This build is maintained mainly by AI.** The Dockerfile, the build pipeline and the documentation are written by an AI coding assistant (Claude, via Claude Code), and a human reviews and merges them. New Caddy versions from Dependabot are merged and released automatically once the tests pass, without a human review. Review the code before you rely on it.

## Image

`ghcr.io/jgdkdofhr/caddy-dynv6`

| Tag | Meaning |
|---|---|
| `2.11.9` | Caddy 2.11.9. Pushed once, when that Caddy version is first built here. Pin this one. |
| `2.11` | Latest build of Caddy 2.11.x |
| `latest` | Latest build from `main`, including base image refreshes within the same Caddy version |
| `sha-<commit>` | Build of that commit |

## Use

```yaml
services:
  caddy:
    image: ghcr.io/jgdkdofhr/caddy-dynv6:2.11.9
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
      - "443:443/udp"
    environment:
      - DYNV6_TOKEN=${DYNV6_TOKEN}
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile:ro
      - caddy_data:/data
      - caddy_config:/config

volumes:
  caddy_data:
  caddy_config:
```

```caddyfile
app.example.dynv6.net {
	tls {
		dns dynv6 {env.DYNV6_TOKEN}
	}
	reverse_proxy 192.168.0.10:8080
}
```

Keep the token in an environment variable or a `.env` file, not in the Caddyfile.

## How updates work

1. Dependabot checks the two `caddy` base images in the [Dockerfile](Dockerfile) every day. When Caddy publishes a new image, it opens one pull request that updates both, two days after the release.
2. The [build](.github/workflows/build.yml) compiles Caddy with the dynv6 module and checks that the binary and the runtime image are the same Caddy version, that the module is included and that a Caddyfile using it loads.
3. If the build passes, [automerge](.github/workflows/automerge.yml) merges the pull request and starts the build on `main`.
4. On `main`, the build pushes the image. If the image contains a Caddy version that has no release here yet, it also pushes the version tags and creates the release `v<version>`.

Major Caddy updates and GitHub Actions updates are left open for a manual review.

When the base image is rebuilt for the same Caddy version (for example an Alpine security fix), only `latest` and `sha-*` are updated. The version tag stays as it was released.

### dynv6 module

[caddy-dns/dynv6](https://github.com/caddy-dns/dynv6) has no releases, so the Dockerfile pins a commit in `DYNV6_MODULE`. Dependabot can't update it. To update it, put the newest commit of that repository into `DYNV6_MODULE` and open a pull request. After the merge, `latest` and `sha-*` contain the new module, and the version tags follow with the next Caddy version.

## Build locally

```bash
docker build -t caddy-dynv6 .
docker run --rm caddy-dynv6 caddy list-modules | grep dynv6
```

## License

Apache-2.0 for the files in this repository (see [LICENSE](LICENSE)), the same license as Caddy. The dynv6 module keeps the license of its authors.
