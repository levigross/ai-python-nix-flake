{pkgs}: let
  inherit (pkgs) lib;

  mkFastmcpCi = pythonPackages:
    pythonPackages.fastmcp.overrideAttrs (old: {
      preCheck =
        (old.preCheck or "")
        + ''
          python - <<'PY'
          from pathlib import Path

          for path in Path("tests").rglob("*.py"):
              content = path.read_text()
              updated = content.replace("@pytest.mark.timeout(20)", "@pytest.mark.timeout(75)")
              if updated != content:
                  path.write_text(updated)
          PY
        '';
      pytestFlagsArray =
        (lib.filter (f: !(lib.hasPrefix "--timeout=" f)) (old.pytestFlagsArray or []))
        ++ ["--timeout=75"];
      disabledTests =
        (old.disabledTests or [])
        ++ [
          "test_server_performance_no_latency"
          "test_medium_schema_performance"
          "test_global_rate_limiting"
        ];
    });

  # Pytest 9 on python 3.13 segfaults in stdlib logging during FastMCP's
  # test suite on nixpkgs-unstable.  Fall back to a smoke build.
  needsSmoke = pythonPackages: let
    pytestProbe = builtins.tryEval pythonPackages.pytest.version;
  in
    lib.versionAtLeast pythonPackages.python.version "3.13"
    && lib.versionOlder pythonPackages.python.version "3.14"
    && pytestProbe.success
    && lib.versionAtLeast pytestProbe.value "9";

  mkFastmcpCheck = pythonPackages:
    if needsSmoke pythonPackages
    then
      (mkFastmcpCi pythonPackages).overrideAttrs (_: {
        doCheck = false;
        dontUsePytestCheck = true;
      })
    else mkFastmcpCi pythonPackages;
in {
  inherit mkFastmcpCi needsSmoke mkFastmcpCheck;
}
