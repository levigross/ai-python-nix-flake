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
  uvicorn,
  watchfiles,
  websockets,
}:
buildPythonPackage rec {
  pname = "fastmcp";
  version = "3.0.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "PrefectHQ";
    repo = "fastmcp";
    rev = "v${version}";
    hash = "sha256-/wTLeya7Xo+mee2fAqqcAS9V1qheIv4V2QNdwZKYi1A=";
  };

  build-system = [
    hatchling
    uvDynamicVersioning
  ];

  dependencies = [
    authlib
    cyclopts
    exceptiongroup
    httpx
    jsonref
    jsonschemaPath
    mcp
    openapiPydantic
    opentelemetryApi
    packaging
    platformdirs
    pyKeyValueAio
    pydantic
    pyperclip
    pythonDotenv
    pyyaml
    rich
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
    anthropic
    azureIdentity
    dirtyEquals
    emailValidator
    fastapi
    openai
    pydocket
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

  doCheck = true;
  pythonImportsCheck = ["fastmcp"];

  meta = with lib; {
    description = "Fast, Pythonic framework for MCP servers and clients";
    homepage = "https://github.com/PrefectHQ/fastmcp";
    license = licenses.asl20;
  };
}
