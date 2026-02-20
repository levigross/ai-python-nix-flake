# ai-python-nix-flake
[![CI 25.11](https://github.com/levigross/ai-python-nix-flake/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/levigross/ai-python-nix-flake/actions/workflows/ci.yml)
[![CI unstable](https://github.com/levigross/ai-python-nix-flake/actions/workflows/ci-unstable.yml/badge.svg?branch=main)](https://github.com/levigross/ai-python-nix-flake/actions/workflows/ci-unstable.yml)

Nix packaging for:

- `fastmcp` v3 (`fastmcp` 3.0.0)
- `claude-code-sdk` (Python SDK from `anthropics/claude-agent-sdk-python`, 0.1.39)
- `dspy` (3.1.3)

This repo is designed to be easy to consume from:

- standard flakes (overlay-based)
- `flake-parts` projects (module import)
- NixOS configurations (module import)

All core package sources are fetched from GitHub, and Python packaging is done idiomatically with `buildPythonPackage` and `pyproject` backends.

Tested against:

- `nixos-25.11` (default flake input, stable)
- `nixpkgs-unstable` (via `--override-input nixpkgs`)

## What This Flake Exposes

### Flake-parts modules

- `flakeModules.default`
- `flakeModules.ai-python`

Use these in another flake's `imports` list when you already use `flake-parts`.

### Overlays

- `overlays.default`
- `overlays.ai-python`

Use these from plain flakes to extend `python3Packages`.

### NixOS modules

- `nixosModules.default`
- `nixosModules.ai-python`

Adds an option to install a Python environment with these packages:

- `programs.ai-python.enable`
- `programs.ai-python.package`

## Package Outputs

For each supported system, these are available under `packages.<system>`:

- `python` (standard interpreter env with `fastmcp`, `claude-code-sdk`, `dspy`)
- `python-with-ai-packages` (same as `python`, explicit alias)
- `fastmcp`
- `claude-code-sdk`
- `dspy`
- `fastmcp-with-all-extras`
- `claude-code-sdk-with-all-extras`
- `dspy-with-all-extras`
- `all-with-all-extras`
- `default` (same env as `python`)

## Quick Start (This Repo)

Run a Python interpreter that already has all three core packages:

```bash
nix shell .#python
python -c "import fastmcp, claude_agent_sdk, dspy; print('ok')"
```

Use the all-extras environment:

```bash
nix shell .#all-with-all-extras
python -c "import fastmcp, claude_agent_sdk, dspy; print('extras ok')"
```

## Use From Another Flake (flake-parts)

```nix
{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    ai-nix-libs.url = "github:levigross/ai-python-nix-flake";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" ];
      imports = [ inputs.ai-nix-libs.flakeModules.default ];
    };
}
```

Then use outputs like:

- `.#packages.x86_64-linux.python`
- `.#packages.x86_64-linux.fastmcp`
- `.#packages.x86_64-linux.all-with-all-extras`

## Use From Another Flake (Overlay)

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    ai-nix-libs.url = "github:levigross/ai-python-nix-flake";
  };

  outputs = { nixpkgs, ai-nix-libs, ... }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      overlays = [ ai-nix-libs.overlays.default ];
    };
  in {
    packages.${system} = {
      python = pkgs.python3.withPackages (ps: [
        ps.fastmcp
        ps."claude-code-sdk"
        ps.dspy
      ]);
      fastmcp = pkgs.python3Packages.fastmcp;
      claude-code-sdk = pkgs.python3Packages."claude-code-sdk";
      dspy = pkgs.python3Packages.dspy;
    };
  };
}
```

## Use In NixOS

```nix
{
  inputs.ai-nix-libs.url = "github:levigross/ai-python-nix-flake";

  outputs = { self, nixpkgs, ai-nix-libs, ... }: {
    nixosConfigurations.my-host = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ai-nix-libs.nixosModules.default
        ({ pkgs, ... }: {
          programs.ai-python.enable = true;

          # Optional: override with a custom env
          # programs.ai-python.package = pkgs.python3.withPackages (ps: [
          #   ps.fastmcp
          #   ps."claude-code-sdk"
          #   ps.dspy
          # ]);
        })
      ];
    };
  };
}
```

## Extras Policy

`*-with-all-extras` outputs are intended to be practical, test-friendly environments that include optional dependency groups used in upstream extras/dev/test workflows.

Examples:

- `fastmcp-with-all-extras` includes support for `anthropic`, `azure`, `openai`, and `tasks` extras.
- `claude-code-sdk-with-all-extras` includes SDK dev/test extras.
- `dspy-with-all-extras` includes optional extras plus common test/dev extras used upstream.

## Testing

Main validation commands:

```bash
nix flake check -L
nix build .#fastmcp -L
nix build .#claude-code-sdk -L
nix build .#dspy -L
nix build -L --override-input nixpkgs github:NixOS/nixpkgs/nixpkgs-unstable .#fastmcp .#claude-code-sdk .#dspy .#python
```

### Test skip policy

We keep checks enabled (`doCheck = true`) and only skip tests when they are not hermetic in the Nix build sandbox.

For every skip/ignore, a comment is included directly above the skip declaration in the corresponding derivation.

Current examples:

- `fastmcp`
  - ignores integration/experimental test folders
  - skips tests that require live network access (GitHub schema/PyPI resolution via `uv --with`)
- `claude-code-sdk`
  - ignores integration tests requiring external CLI/auth
  - skips one known async-iterable test mismatch in packaged environment

## Supported Systems

Currently configured in this flake:

- `x86_64-linux`
- `aarch64-linux`

## Development Notes

- Python packages are defined under `pkgs/python/`.
- Overlay wiring lives in `overlays/ai-python.nix`.
- flake-parts export module lives in `modules/flake-parts/ai-python.nix`.
- NixOS module lives in `modules/nixos/ai-python.nix`.

If you bump versions, run `nix flake check -L` and package builds before pushing.

## License

Apache-2.0. See `LICENSE`.
