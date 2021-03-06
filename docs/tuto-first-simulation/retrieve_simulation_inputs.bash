#!/usr/bin/env bash

# Download a tarball of Batsim's latest release.
curl --output /tmp/batsim-v2.0.0.tar.gz \
    https://framagit.org/batsim/batsim/-/archive/v2.0.0/batsim-v2.0.0.tar.gz

# Extract tarball to /tmp/batsim-v2.0.0.
(cd /tmp && tar -xf batsim-v2.0.0.tar.gz)
