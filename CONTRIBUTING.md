# Contributing to `lustre-server-operator`

Do you want to contribute to the `lustre-server-operator` repository? You've come to the right place then!
__Here is how you can get involved.__

Before you start working on your contribution, please familiarize yourself with the [Charmed
HPC project's contributing guide]. After you've gone through the main contributing guide,
you can use this guide for specific information on contributing to the `lustre-server-operator` repository.

Have any questions? Feel free to ask them in the [Ubuntu High-Performance Computing Matrix chat]
or in the [High-Performance Computing category on the Ubuntu Discourse].

[Charmed HPC project's contributing guide]: https://github.com/canonical/hpc-team/blob/main/CONTRIBUTING.md
[Ubuntu High-Performance Computing Matrix chat]: https://matrix.to/#/#hpc:ubuntu.com
[High-Performance Computing category on the Ubuntu Discourse]: https://discourse.ubuntu.com/c/project/hpc/151

## Hacking on `lustre-server-operator`

This repository uses [just](https://github.com/casey/just) and [uv](https://github.com/astral-sh/uv) for development
which provide some useful commands that will help you while hacking on `lustre-server-operator`:

```shell
# Prepare the local development environment
just setup

# Upgrade uv.lock with the latest dependencies
just upgrade
```

Run `just help` to view the full list of available recipes.

### Repository layout

- `src/`, `tests/`, `terraform/`: the `lustre-server` charm.
- `lustre-ops/`: a Python package of shared Lustre operations. It is installed into the charm as
  a path dependency, and is also consumed by the `filesystem-client` charm in
  [canonical/filesystem-charms] as a uv git dependency pinned to a tag of this repository.
- `lib/charms/filesystem_client/v0/filesystem_info.py`: a **vendored** copy of the
  `filesystem_info` charm library.

### Changing `lustre-ops`

`filesystem-client` pins `lustre-ops` to a tag of this repository, so changes here do not reach it
until the pin is bumped. After your change merges:

1. Tag the release (e.g. `lustre-ops-vX.Y.Z`).
2. In [canonical/filesystem-charms], update the `lustre-ops` `tag` in the root `pyproject.toml`
   and run `just lock`.

Avoid breaking changes to the public API of `lustre-ops`. If one is unavoidable, coordinate it with
a matching change to `filesystem-client`.

### Updating the vendored `filesystem_info` library

The source of truth for `filesystem_info` is `filesystem-client` in [canonical/filesystem-charms].
__Do not edit the vendored copy in this repository.__ Make the change in `filesystem-charms`
first, then sync it here:

```shell
just sync-libs ../filesystem-charms
```

[canonical/filesystem-charms]: https://github.com/canonical/filesystem-charms

### Before opening a pull request on the `lustre-server-operator` repository

Ensure that your changes pass all the existing tests, and that you have added tests
for any new features you're introducing in this changeset.

Your proposed changes will not be reviewed until your changes pass all the
required tests. You can run the required tests locally using `just`:

```shell
# Apply static checks (formatting, linting, and type checking)
just check

# Run unit tests for the charm and `lustre-ops`
just test unit

# Run unit tests for a single artifact (`lustre-server` or `lustre-ops`)
just unit lustre-ops

# Run integration tests (requires a Juju controller and LXD)
just test integration

# Run all test suites
just test
```

## License information

By contributing to `lustre-server-operator`, you agree to license your contribution under
the Apache License 2.0 license.

### Adding a new file to `lustre-server-operator`

If you add a new source code file to the repository, add the following license header
as a comment to the top of the file with the copyright owner set to the organization
you are contributing on behalf of and the current year set as the copyright year.

```text
Copyright [yyyy] [name of copyright owner]

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

### Updating an existing file in `lustre-server-operator`

If you are making changes to an existing file, and the copyright year is not the current year,
update the year range to include the current year. For example, if a file's copyright year is:

```text
Copyright 2023 Canonical Ltd.
```

and you make changes to that file in 2025, update the copyright year in the file to:

```text
Copyright 2023-2025 Canonical Ltd.
```
