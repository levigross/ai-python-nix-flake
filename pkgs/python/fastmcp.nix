{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  hatchling,
  python,
  uvDynamicVersioning,
  authlib,
  anthropic,
  azureIdentity,
  googleGenai,
  cyclopts,
  dirtyEquals,
  emailValidator,
  exceptiongroup,
  fastapi,
  httpx,
  jsonref,
  jsonschemaPath,
  mcp,
  openapiPydantic,
  opentelemetryApi,
  opentelemetrySdk,
  openai,
  pydanticMonty,
  prefabUi,
  packaging,
  platformdirs,
  pydocket,
  pyKeyValueAio,
  pydantic,
  pyperclip,
  pytestCheckHook,
  pytestAsyncio,
  pytestHttpx,
  pytestTimeout,
  pytestXdist,
  pytestEnv,
  inlineSnapshot,
  psutil,
  pythonDotenv,
  uv,
  pyyaml,
  rich,
  uncalledFor,
  uvicorn,
  watchfiles,
  websockets,
}:
buildPythonPackage rec {
  pname = "fastmcp";
  version = "3.1.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "PrefectHQ";
    repo = "fastmcp";
    rev = "v${version}";
    hash = "sha256-MnU69JuMlRwiUFIOaws9N7Hw6oDnrIIwCoWuHFrvbHQ=";
  };

  build-system = [
    hatchling
    uvDynamicVersioning
  ];

  dependencies = [
    anthropic
    authlib
    azureIdentity
    cyclopts
    emailValidator
    exceptiongroup
    googleGenai
    httpx
    jsonref
    jsonschemaPath
    mcp
    openapiPydantic
    openai
    opentelemetryApi
    packaging
    platformdirs
    prefabUi
    pydanticMonty
    pydocket
    pyKeyValueAio
    pydantic
    pyperclip
    pythonDotenv
    pyyaml
    rich
    uncalledFor
    uvicorn
    watchfiles
    websockets
  ];

  nativeCheckInputs = [
    pytestCheckHook
    pytestAsyncio
    pytestHttpx
    pytestTimeout
    pytestXdist
    pytestEnv
    inlineSnapshot
    opentelemetrySdk
    dirtyEquals
    fastapi
    psutil
    uv
  ];

  preCheck = ''
            # uv-based transport tests need writable cache dirs and must avoid managed
            # Python discovery (which probes non-Nix FHS paths).
            export HOME="$TMPDIR/home"
            export XDG_CACHE_HOME="$TMPDIR/xdg-cache"
            export UV_CACHE_DIR="$TMPDIR/uv-cache"
            export UV_NO_MANAGED_PYTHON=1
            export UV_PYTHON_DOWNLOADS=never
            export UV_PYTHON="${python.interpreter}"
            mkdir -p "$HOME" "$XDG_CACHE_HOME" "$UV_CACHE_DIR"

            # mcp stdio subprocesses inherit only an allowlisted environment.
            # Add PYTHONPATH to that allowlist during tests so child Python processes
            # can import fastmcp + deps from the Nix check environment.
            mkdir -p .nix-test-hooks
            cat > .nix-test-hooks/sitecustomize.py <<'PY'
    try:
        import mcp.client.stdio as _mcp_stdio
    except Exception:
        _mcp_stdio = None

    if _mcp_stdio is not None:
        inherited = list(_mcp_stdio.DEFAULT_INHERITED_ENV_VARS)
        required = [
            "PYTHONPATH",
            "XDG_CACHE_HOME",
            "UV_CACHE_DIR",
            "UV_NO_MANAGED_PYTHON",
            "UV_PYTHON_DOWNLOADS",
            "UV_PYTHON",
        ]
        for key in required:
            if key not in inherited:
                inherited.append(key)
        _mcp_stdio.DEFAULT_INHERITED_ENV_VARS = inherited
    PY
            export PYTHONPATH="$PWD/.nix-test-hooks:$PYTHONPATH"

            # Some upstream tests pin a strict 5-second pytest-timeout marker that is
            # too aggressive for subprocess-heavy Nix builders.
            python - <<'PY'
    from pathlib import Path

    for path in Path("tests").rglob("*.py"):
        content = path.read_text()
        updated = content.replace("@pytest.mark.timeout(5)", "@pytest.mark.timeout(20)")
        if updated != content:
            path.write_text(updated)
    PY
  '';

  pytestFlagsArray = [
    "tests"
    # Upstream defaults to a strict 5s timeout; this is too tight for some
    # heavily parallelized IPC subprocess tests in constrained builders.
    "--timeout=20"
    # Requires live external services and credentials.
    "--ignore=tests/integration_tests"
    # Upstream experimental suite is intentionally unstable/non-gating.
    "--ignore=tests/experimental"
    # This in-memory transport test sets a 50ms client-wide timeout, which is
    # too tight for builder-side session initialization.
    "--deselect=tests/client/client/test_timeout.py::TestTimeout::test_timeout"
  ];

  disabledTests = [
    # Downloads GitHub's public OpenAPI schema over the network.
    # Nix checks must remain hermetic.
    "test_github_api_schema_performance"
    # In release mode, UvStdioTransport resolves fastmcp from PyPI (`uv --with`),
    # which requires external network access.
    "test_uv_transport"
    # Module variant of the same PyPI-fetching uv flow above.
    "test_uv_transport_module"
  ];

  dontUsePytestXdist = true;
  doCheck = true;
  pythonImportsCheck = ["fastmcp"];

  meta = with lib; {
    description = "Fast, Pythonic framework for MCP servers and clients";
    homepage = "https://github.com/PrefectHQ/fastmcp";
    license = licenses.asl20;
  };
}
