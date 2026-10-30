# Copyright 2026 Canonical Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Recipes follow UHPC011: Common justfile format for Charmed HPC repositories.

uv := require("uv")

export PY_COLORS := "1"
export PYTHONBREAKPOINT := "pdb.set_trace"

uv_run := "uv run --frozen --extra dev"
src := "src tests lustre-ops/src lustre-ops/tests"
filesystem_info := "lib/charms/filesystem_client/v0/filesystem_info.py"

[private]
default:
    @just help

# Prepare the local environment
setup: lock
    uv sync --extra dev

# Clean project directory
clean:
    charmcraft clean
    rm -rf *.charm cover .coverage .pytest_cache .ruff_cache

# Apply static checks
check: fmt lint typecheck

# Run specified target test suites, or all test suites if none specified
test *targets:
    #!/usr/bin/env bash
    if [ "{{targets}}" = "" ]; then
        just test-all
        exit 0
    fi

    for target in {{targets}}; do
        if just --show $target > /dev/null 2>&1; then
            echo "Running $target tests..."
            just $target
        else
            echo "$target tests not found, skipping."
            exit 1
        fi
    done

# Run all test suites
test-all: unit integration

# Run unit tests for specified artifacts (lustre-server, lustre-ops), or all artifacts if none specified
unit *args:
    #!/usr/bin/env bash
    set -euo pipefail
    declare -A suites=([lustre-server]=tests/unit [lustre-ops]=lustre-ops/tests/unit)
    targets=({{args}})
    [[ ${#targets[@]} -eq 0 ]] && targets=(lustre-server lustre-ops)
    paths=()
    for target in "${targets[@]}"; do
        [[ -n "${suites[$target]:-}" ]] || { echo "unknown artifact: $target" >&2; exit 1; }
        paths+=("${suites[$target]}")
    done
    {{uv_run}} coverage erase
    {{uv_run}} coverage run -m pytest -v --tb native -s "${paths[@]}"
    {{uv_run}} coverage report
    {{uv_run}} coverage xml -o cover/coverage.xml

# Run integration tests (requires a Juju controller and LXD). Arguments are forwarded to pytest
integration *args: build
    #!/usr/bin/env bash
    set -euo pipefail

    # Drop the optional `--` separator that `just` forwards from the CLI.
    PASSTHROUGH=()
    for arg in {{args}}; do
        [[ "$arg" == "--" ]] || PASSTHROUGH+=("$arg")
    done

    # The BDD `pack` step skips `charmcraft pack` when `LUSTRE_SERVER_CHARM_PATH`
    # is set, reusing `lustre-server.charm` produced by the `build` recipe.
    export LUSTRE_SERVER_CHARM_PATH=1

    {{uv_run}} pytest -v --exitfirst -s --tb native --log-cli-level=INFO \
        --juju-bdd-wait-timeout 1800 \
        ./tests/integration "${PASSTHROUGH[@]}"

# Build specified artifacts (lustre-server), or all artifacts if none specified
build *args:
    #!/usr/bin/env bash
    set -euo pipefail
    for artifact in {{args}}; do
        [[ "$artifact" == "lustre-server" ]] || { echo "unknown artifact: $artifact" >&2; exit 1; }
    done
    charmcraft pack
    mv lustre-server_*.charm lustre-server.charm

# Regenerate uv.lock
lock:
    uv lock



# Upgrade uv.lock with the latest dependencies
upgrade:
    uv lock --upgrade

# Apply formatting standards
fmt:
    {{uv_run}} ruff format {{src}}
    {{uv_run}} ruff check --select I --fix {{src}}

# Check against style standards
lint:
    {{uv_run}} codespell {{src}}
    {{uv_run}} ruff check {{src}}
    {{uv_run}} ruff format --check {{src}}

# Perform type checking
typecheck:
    {{uv_run}} pyright

# Update the vendored `filesystem_info` library from a local `filesystem-charms` checkout
sync-libs filesystem_charms="../filesystem-charms":
    cp "{{filesystem_charms}}/charms/filesystem-client/{{filesystem_info}}" "{{filesystem_info}}"
    @grep -E '^LIB(API|PATCH) =' "{{filesystem_info}}"

# Show available recipes
help:
    @just --list --unsorted
