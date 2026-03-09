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
    inherit (pkgs) lib;

    ci = import ./lib/ci.nix {inherit pkgs;};

    supportedPythons = lib.genAttrs ["312" "313"] (v: pkgs."python${v}Packages");

    extraNames = [
      "anthropic"
      "build"
      "datamodel-code-generator"
      "datasets"
      "langchain-core"
      "litellm"
      "mcp"
      "mypy"
      "optuna"
      "pandas"
      "pillow"
      "pytest"
      "pytest-asyncio"
      "pytest-cov"
      "pytest-mock"
      "ruff"
      "trio"
      "weaviate-client"
    ];

    optionalPkg = ps: name:
      lib.optional (builtins.tryEval ps.${name}.drvPath).success ps.${name};

    extras = ps: let
      preCommit = ps.toPythonModule pkgs.pre-commit;
    in
      lib.concatMap (optionalPkg ps) extraNames
      ++ lib.optional (builtins.tryEval preCommit.drvPath).success preCommit;

    mkAiEnv = pp:
      pp.python.withPackages (ps:
        [ps.fastmcp ps."claude-code-sdk" ps.dspy] ++ extras ps);

    fastmcpCi = ci.mkFastmcpCheck pkgs.python3Packages;
    aiPythonBase = mkAiEnv pkgs.python3Packages;
    aiPythonCi = pkgs.python3.withPackages (ps:
      [fastmcpCi pkgs.python3Packages."claude-code-sdk" pkgs.python3Packages.dspy]
      ++ extras ps);
  in {
    formatter = pkgs.alejandra;

    packages =
      {
        python = aiPythonBase;
        "python-ci" = aiPythonCi;
        fastmcp = pkgs.python3Packages.fastmcp;
        "fastmcp-ci" = fastmcpCi;
        "claude-code-sdk" = pkgs.python3Packages."claude-code-sdk";
        dspy = pkgs.python3Packages.dspy;
        default = aiPythonBase;
      }
      // lib.mapAttrs' (v: pp: {
        name = "fastmcp-py${v}";
        value = pp.fastmcp;
      })
      supportedPythons
      // lib.mapAttrs' (v: _: {
        name = "python-py${v}";
        value = mkAiEnv supportedPythons.${v};
      })
      supportedPythons;

    checks =
      {
        "fastmcp-ci" = fastmcpCi;
        "python-ci" = aiPythonCi;
      }
      // lib.mapAttrs' (v: pp: {
        name = "fastmcp-py${v}" + lib.optionalString (ci.needsSmoke pp) "-smoke";
        value = ci.mkFastmcpCheck pp;
      })
      supportedPythons;
  };
}
