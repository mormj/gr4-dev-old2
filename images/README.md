# Images

`images/` owns the Docker build inputs for gr4-dev:

- builder matrix images for distro/toolchain prerequisites
- product image builds for GNU Radio 4, gr4-control-plane, and gr4-studio

The runtime interface is the repo-root `compose.yml`. After images exist,
running the stack should be:

```bash
docker compose up
```

## Layout

```text
images/
  Dockerfile
  build-images.sh
  Makefile
  nginx/
    gr4-studio.conf
  <distro>/
    base/
      Dockerfile
    profiles/
      <profile>/
        Dockerfile
```

## Responsibilities

`Makefile` builds and pushes builder images only.

`build-images.sh` builds and pushes product images only. It assumes the selected
builder image already exists locally or in the registry.

`../compose.yml` runs the production two-container instance:

- `gr4-control-plane`
- `gr4-studio`

Compose waits for the control-plane `/healthz` endpoint before starting Studio.

## Image Names

Builder images:

```text
gr4-dev/<distro>-base:latest
gr4-dev/<distro>-<profile>:latest
```

Hosted builder images:

```text
ghcr.io/$USER/gr4-dev/<distro>-base:latest
ghcr.io/$USER/gr4-dev/<distro>-<profile>:latest
```

Local product images:

```text
gr4-dev/gnuradio4-sdk:latest
gr4-dev/gr4-control-plane-sdk:latest
gr4-dev/gr4-control-plane-runtime:latest
gr4-dev/gr4-studio:latest
```

Hosted product images:

```text
ghcr.io/$USER/gr4-dev/gnuradio4-sdk:latest
ghcr.io/$USER/gr4-dev/gr4-control-plane-sdk:latest
ghcr.io/$USER/gr4-dev/gr4-control-plane-runtime:latest
ghcr.io/$USER/gr4-dev/gr4-studio:latest
```

`gr4-studio` is a production nginx image. It serves the built Studio frontend
and proxies `/api/*` to the `gr4-control-plane` service on port `8080`.
The runtime image includes `curl` so Compose can health-check the control plane.

## 1. Build Builder Images

List available builder targets:

```bash
cd images
make list
```

Build a local single-arch builder:

```bash
cd images
make build-ubuntu-26.04-gcc
```

That creates:

```text
gr4-dev/ubuntu-26.04-base:latest
gr4-dev/ubuntu-26.04-gcc:latest
```

Push a multi-arch builder:

```bash
cd images
make push-ubuntu-26.04-gcc \
  BUILDER_NAMESPACE=ghcr.io/$USER/gr4-dev \
  PLATFORMS=linux/amd64,linux/arm64
```

That publishes:

```text
ghcr.io/$USER/gr4-dev/ubuntu-26.04-base:latest
ghcr.io/$USER/gr4-dev/ubuntu-26.04-gcc:latest
```

## 2. Build Product Images

Local product build with Ubuntu 26.04 GCC:

```bash
cd images
./build-images.sh --profile ubuntu-26.04-gcc
```

Local mode is the default. It derives:

```text
BUILDER_IMAGE=gr4-dev/ubuntu-26.04-gcc:latest
IMAGE_NAMESPACE=gr4-dev
RUNTIME_BASE_IMAGE=ubuntu:26.04
SOURCE_MODE=local
```

Local source comes from the workspace under `../src/`:

```text
../src/gnuradio4
../src/gr4-incubator
../src/gr4-control-plane
../src/gr4-studio
```

Push product images after pushing the matching builder image:

```bash
cd images
GHCR_TOKEN=... \
./build-images.sh --push --profile ubuntu-26.04-gcc
```

In push mode, `build-images.sh` derives:

```text
BUILDER_IMAGE=ghcr.io/$USER/gr4-dev/ubuntu-26.04-gcc:latest
IMAGE_NAMESPACE=ghcr.io/$USER/gr4-dev
RUNTIME_BASE_IMAGE=ubuntu:26.04
SOURCE_MODE=git
```

Push builds use the `url` and `ref` entries from `../repos.yaml` for:

```text
gnuradio4
gr4-incubator
gr4-control-plane
gr4-studio
```

For reproducible hosted images, prefer commit SHA refs in `repos.yaml` instead
of `main`.

You can override individual refs from the command line when needed:

```bash
cd images
GHCR_TOKEN=... \
./build-images.sh \
  --push \
  --profile ubuntu-26.04-gcc \
  --gnuradio4-ref <commit-sha>
```

Push multi-arch product images:

```bash
cd images
GHCR_TOKEN=... \
./build-images.sh \
  --push \
  --profile ubuntu-26.04-gcc \
  --platforms linux/amd64,linux/arm64
```

Multi-arch product pushes require a registry-backed multi-arch builder image.
Build it first with the matching `make push-...` target.

Print the derived image names and build settings without building:

```bash
cd images
./build-images.sh --dry-run --profile ubuntu-26.04-gcc
```

Build only selected product images:

```bash
cd images
./build-images.sh --profile ubuntu-26.04-gcc --images control-plane,studio
```

## 3. Run The Production Instance

From the repo root:

```bash
docker compose up
```

Studio is exposed on:

```text
http://127.0.0.1:8088
```

The control plane is also exposed directly on:

```text
http://127.0.0.1:8080
```

`compose.yml` defaults to:

```text
gr4-dev/gr4-control-plane-runtime:latest
gr4-dev/gr4-studio:latest
```

The control-plane service also sets the in-container plugin search path to:

```text
/usr/local/lib/gnuradio-4/plugins:/usr/local/lib:/opt/gr4-control-plane/lib
```

Override it with `GR4_DOCKER_PLUGIN_DIRECTORIES` if a custom runtime image uses
different plugin install locations.

For local graph runs, Compose bind-mounts the repo-local, gitignored `data/`
directory inside the control-plane container:

```text
./data:/opt/gr4-control-plane/data:rw
```

Since the control plane runs from `/opt/gr4-control-plane`, graphs can use
relative paths like `data/input.sigmf-meta`. Override the mount with
`GR4_DOCKER_HOST_DATA_DIR` and `GR4_DOCKER_CONTAINER_DATA_DIR` when needed.

Override image names or ports when needed:

```bash
GR4_CONTROL_PLANE_IMAGE=ghcr.io/$USER/gr4-dev/gr4-control-plane-runtime:latest \
GR4_STUDIO_IMAGE=ghcr.io/$USER/gr4-dev/gr4-studio:latest \
GR4_DOCKER_STUDIO_PORT=8090 \
docker compose up
```

To run hosted images without specifying both image names:

```bash
IMAGE_NAMESPACE=ghcr.io/$USER/gr4-dev docker compose up
```

The repo-root `.env.example` lists the Compose variables intended for regular
use. Copy values from it into a local `.env` when you want persistent Compose
defaults.

## Runtime Base Selection

`RUNTIME_BASE_IMAGE` is inferred from `PROFILE`:

```text
ubuntu-26.04-gcc       -> ubuntu:26.04
ubuntu-24.04-gcc-14    -> ubuntu:24.04
debian-sid-gcc         -> debian:sid
debian-bookworm-gcc    -> debian:bookworm
fedora-44-clang        -> fedora:44
```

Override it directly when needed:

```bash
RUNTIME_BASE_IMAGE=debian:sid ./build-images.sh
```

## Useful Overrides

```text
OWNER                  GHCR owner used for default product image names
IMAGE_NAMESPACE        full product image namespace
PROFILE                selected builder profile, default ubuntu-24.04-clang-20
BUILDER_NAMESPACE      builder image namespace/prefix
BUILDER_IMAGE          explicit builder image
PUSH_IMAGES            push product images when 1, local build when 0
IMAGES                 product image selection: gnuradio4-sdk,control-plane,studio
IMAGE_TAG              product image tag, default latest
NO_CACHE               run product docker builds with --no-cache when set to 1
PLATFORMS              product platform list, default linux/amd64
RUNTIME_BASE_IMAGE     explicit runtime base image
SOURCE_MODE            local or git, defaults to local for local builds and git for push builds
REPOS_FILE             manifest used for default git source URLs and refs
GNURADIO4_REPO         GNU Radio 4 git repo used when SOURCE_MODE=git
GNURADIO4_REF          GNU Radio 4 git ref used when SOURCE_MODE=git
GR4_INCUBATOR_REPO     gr4-incubator git repo used when SOURCE_MODE=git
GR4_INCUBATOR_REF      gr4-incubator git ref used when SOURCE_MODE=git
CONTROL_PLANE_REPO     gr4-control-plane git repo used when SOURCE_MODE=git
CONTROL_PLANE_REF      gr4-control-plane git ref used when SOURCE_MODE=git
STUDIO_REPO            gr4-studio git repo used when SOURCE_MODE=git
STUDIO_REF             gr4-studio git ref used when SOURCE_MODE=git
REBUILD_STUDIO_BLOCKS  rebuild only the Studio block build stage when set to 1
STUDIO_BLOCKS_CACHE_BUST explicit cache key for the Studio block build stage
```

In local mode, `IMAGE_NAMESPACE` and `BUILDER_NAMESPACE` default to `gr4-dev`.

In push mode, `IMAGE_NAMESPACE` defaults to `ghcr.io/$USER/gr4-dev`, and
`BUILDER_NAMESPACE` defaults to `IMAGE_NAMESPACE`.

Compatibility aliases still work:

```text
BUILDER_DISTRO + BUILDER_PROFILE  older way to select PROFILE
BUILDER_TAG_PREFIX                older name for BUILDER_NAMESPACE
BASE_TAG_PREFIX                   older Makefile name for BUILDER_NAMESPACE
BUILD_BASE_IMAGE                  older name for BUILD_GR4_SDK_IMAGE
PLATFORM                          older single-platform variable
PUBLISH_MULTIARCH + PUBLISH_PLATFORMS older multi-arch push variables
```
