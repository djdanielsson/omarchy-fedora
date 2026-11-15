FROM quay.io/fedora/fedora-bootc:45

# Layer Omarchy-like Hyprland desktop onto Fedora bootc (image mode)
# UPDATE MODEL: GHCR container is source of truth.
#  - `bootc upgrade` pulls ghcr.io/<you>/omarchy-fedora:45
#  - ISO in Actions output is only the installer, built FROM that same container
# Docs: https://docs.fedoraproject.org/en-US/bootc/
# Base pattern: FROM quay.io/fedora/fedora-bootc:45 + RUN dnf install + ostree container commit
# Build locally: podman build -t localhost/omarchy-fedora:45 .
# Lint: bootc container lint

COPY build_files /ctx
COPY system_files /

RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh && \
    bootc container lint
