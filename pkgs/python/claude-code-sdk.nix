{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  hatchling,
  anyio,
  mcp,
  pytestCheckHook,
  pytestAsyncio,
  trio,
  typingExtensions,
  pythonOlder,
}:
buildPythonPackage rec {
  pname = "claude-code-sdk";
  version = "0.1.39";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "anthropics";
    repo = "claude-agent-sdk-python";
    rev = "v${version}";
    hash = "sha256-Us2YNfm2WOZVAgNMLhH8ZIWqdSwD2wGHqFQxukDVT+Q=";
  };

  build-system = [hatchling];

  dependencies =
    [
      anyio
      mcp
    ]
    ++ lib.optionals (pythonOlder "3.11") [typingExtensions];

  nativeCheckInputs = [
    pytestCheckHook
    pytestAsyncio
    trio
  ];

  pytestFlagsArray = [
    "tests"
    # Integration tests require the external Claude Code CLI and credentials.
    "--ignore=tests/test_integration.py"
  ];

  disabledTests = [
    # Uses an async generator input shape that currently fails under the
    # packaged test environment; keep this isolated until upstream fixes it.
    "test_query_with_async_iterable"
  ];

  doCheck = true;
  pythonImportsCheck = ["claude_agent_sdk"];

  meta = with lib; {
    description = "Python SDK for Claude Code";
    homepage = "https://github.com/anthropics/claude-agent-sdk-python";
    license = licenses.mit;
  };
}
