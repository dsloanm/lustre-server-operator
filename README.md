# Lustre server operator

[![CI](https://github.com/canonical/lustre-server-operator/actions/workflows/ci.yaml/badge.svg)](https://github.com/canonical/lustre-server-operator/actions/workflows/ci.yaml)
[![Publish](https://github.com/canonical/lustre-server-operator/actions/workflows/publish.yaml/badge.svg)](https://github.com/canonical/lustre-server-operator/actions/workflows/publish.yaml)
[![Matrix](https://img.shields.io/matrix/ubuntu-hpc%3Amatrix.org?logo=matrix&label=ubuntu-hpc)](https://matrix.to/#/#ubuntu-hpc:matrix.org)

A [Juju](https://juju.is) charm for deploying and managing the [Lustre](https://www.lustre.org)
parallel file system.

A single `lustre-server` charm provides all Lustre server components: MGS (Management Server),
MDS (Metadata Server), and OSS (Object Storage Server). Storage targets are set up as ZFS-backed
pools and datasets, and LNet is initialized to provide the network layer.

This repository also contains [`lustre-ops`](./lustre-ops), a Python package of shared Lustre
operations (LNet configuration, package repository setup) used by this charm and by
[`filesystem-client`](https://github.com/canonical/filesystem-charms/tree/main/charms/filesystem-client).

The charm is a core component of [Charmed HPC](https://ubuntu.com/hpc/docs/latest).

## ✨ Getting started

Deploy a minimal Lustre cluster with one MGS+MDS unit and one OSS unit:

```shell
juju deploy lustre-server --channel latest/edge --base ubuntu@26.04 -n 2 \
    --constraints "virt-type=virtual-machine cores=4 mem=4G"
juju add-storage lustre-server/0 mgt-mdt=loop,2,1G
juju add-storage lustre-server/1 ost=loop,3,1G
```

The `mgt-mdt` storage count must be even (mirror vdevs), and the `ost` storage count must be at
least 3 (RAIDZ2 vdev).

Mount the filesystem on a client machine with [`filesystem-client`](https://charmhub.io/filesystem-client):

```shell
juju deploy ubuntu --base ubuntu@26.04 --constraints virt-type=virtual-machine
juju deploy filesystem-client --channel latest/edge \
    --config mountpoint=/lustre --config enable-lustre=true
juju integrate filesystem-client:juju-info ubuntu:juju-info
juju integrate filesystem-client:filesystem lustre-server:filesystem
```

A Terraform module for deploying the charm is available in [`terraform/`](./terraform).

## 🤔 What's next?

* [Charmed HPC documentation](https://ubuntu.com/hpc/docs/latest)
* [Open an issue](https://github.com/canonical/lustre-server-operator/issues/new?title=ISSUE+TITLE&body=*Please+describe+your+issue*)
* [Ask a question](https://discourse.ubuntu.com/c/project/hpc/151)

## 🛠️ Development

The project uses [just](https://github.com/casey/just) and [uv](https://github.com/astral-sh/uv) for
development:

```shell
just setup             # Prepare the local development environment
just check             # Apply static checks (fmt, lint, typecheck)
just test unit         # Run unit tests (charm and lustre-ops)
just test integration  # Run integration tests (requires Juju and LXD)
just test              # Run all test suites
just build             # Pack the charm
just clean             # Clean project directory
```

If you're interested in contributing, take a look at our [contributing guidelines](./CONTRIBUTING.md).

## 🤝 Project and community

The Lustre server operator is a project of the [Ubuntu High-Performance Computing community](https://ubuntu.com/community/governance/teams/hpc).
Interested in contributing bug fixes, patches, documentation, or feedback? Want to join the
Ubuntu HPC community? You've come to the right place 🤩

Here's some links to help you get started with joining the community:

* [Ubuntu Code of Conduct](https://ubuntu.com/community/ethos/code-of-conduct)
* [Contributing guidelines](./CONTRIBUTING.md)
* [Join the conversation on Matrix](https://matrix.to/#/#hpc:ubuntu.com)
* [Get the latest news or ask and answer questions on the Ubuntu Discourse](https://discourse.ubuntu.com/c/project/hpc/151)

## 📋 License

The Lustre server operator is free software, distributed under the
Apache Software License, version 2.0. See the [LICENSE](./LICENSE) file for more information.
