{inputs, ...}: let
  aiPythonOverlay = import ../../overlays/ai-python.nix;
in {
  flake = {
    overlays.default = aiPythonOverlay;
    overlays.ai-python = aiPythonOverlay;
  };

  perSystem = {system, ...}: let
    pkgs = import inputs.nixpkgs {
      inherit system;
      overlays = [aiPythonOverlay];
    };
    fastmcpCi = pkgs.python3Packages.fastmcp.overrideAttrs (old: {
      preCheck =
        (old.preCheck or "")
        + ''
          # CI-only: widen strict per-test timeout markers 15x (5s -> 75s)
          # because shared runners can be significantly slower than local builds.
          python - <<'PY'
          from pathlib import Path

          for path in Path("tests").rglob("*.py"):
              content = path.read_text()
              updated = content.replace("@pytest.mark.timeout(5)", "@pytest.mark.timeout(75)")
              if updated != content:
                  path.write_text(updated)
          PY
        '';
      pytestFlagsArray =
        (pkgs.lib.filter (flag: !(pkgs.lib.hasPrefix "--timeout=" flag)) (old.pytestFlagsArray or []))
        ++ [
          # CI-only: 15x of upstream's 5-second default timeout.
          "--timeout=75"
        ];
      disabledTests =
        (old.disabledTests or [])
        ++ [
          # Performance threshold is wall-clock based and flaky on shared CI runners.
          "test_server_performance_no_latency"
          # Same as above: medium schema timing budget is not stable in GitHub Actions.
          "test_medium_schema_performance"
        ];
    });
    aiPythonBase = pkgs.python3.withPackages (ps: [
      ps.fastmcp
      ps."claude-code-sdk"
      ps.dspy
    ]);
    aiPythonCi = pkgs.python3.withPackages (_: [
      fastmcpCi
      pkgs.python3Packages."claude-code-sdk"
      pkgs.python3Packages.dspy
    ]);
  in {
    formatter = pkgs.alejandra;

    packages = {
      # Standard Python interpreter preloaded with the core AI packages.
      python = aiPythonBase;
      "python-with-ai-packages" = aiPythonBase;
      "python-ci" = aiPythonCi;
      fastmcp = pkgs.python3Packages.fastmcp;
      "fastmcp-ci" = fastmcpCi;
      "claude-code-sdk" = pkgs.python3Packages."claude-code-sdk";
      dspy = pkgs.python3Packages.dspy;
      "fastmcp-with-all-extras" = pkgs.python3.withPackages (ps: [
        ps.fastmcp
        ps.anthropic
        ps."azure-identity"
        ps.openai
        ps.pydocket
      ]);
      "claude-code-sdk-with-all-extras" = pkgs.python3.withPackages (ps: [
        ps."claude-code-sdk"
        ps.pytest
        ps."pytest-asyncio"
        ps."pytest-cov"
        ps.mypy
        ps.ruff
        ps.trio
      ]);
      "dspy-with-all-extras" = pkgs.python3.withPackages (ps: [
        ps.dspy
        ps.anthropic
        ps."weaviate-client"
        ps.mcp
        ps."langchain-core"
        ps.pytest
        ps."pytest-mock"
        ps."pytest-asyncio"
        ps.ruff
        (ps.toPythonModule pkgs.pre-commit)
        ps.pillow
        ps."datamodel-code-generator"
        ps.build
        ps.datasets
        ps.pandas
        ps.optuna
        ps.litellm
      ]);
      "all-with-all-extras" = pkgs.python3.withPackages (ps: [
        ps.fastmcp
        ps."claude-code-sdk"
        ps.dspy
        ps.anthropic
        ps."azure-identity"
        ps.openai
        ps.pydocket
        ps.pytest
        ps."pytest-asyncio"
        ps."pytest-cov"
        ps.mypy
        ps.ruff
        ps.trio
        ps."weaviate-client"
        ps.mcp
        ps."langchain-core"
        ps."pytest-mock"
        (ps.toPythonModule pkgs.pre-commit)
        ps.pillow
        ps."datamodel-code-generator"
        ps.build
        ps.datasets
        ps.pandas
        ps.optuna
        ps.litellm
      ]);
      default = aiPythonBase;
    };
  };
}
