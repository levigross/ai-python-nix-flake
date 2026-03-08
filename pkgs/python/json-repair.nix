{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  pytestCheckHook,
  setuptools,
}:
buildPythonPackage rec {
  pname = "json-repair";
  version = "0.55.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "mangiucugna";
    repo = "json_repair";
    tag = "v${version}";
    hash = "sha256-CzoGu6JNOaqdLZK4DyDUv+TMIA+k9AlZZy1fKnpMbkE=";
  };

  build-system = [setuptools];

  nativeCheckInputs = [pytestCheckHook];

  disabledTestPaths = [
    # Benchmark tests are non-deterministic and not needed for package validity.
    "tests/test_performance.py"
  ];

  pythonImportsCheck = ["json_repair"];

  meta = with lib; {
    description = "Repair broken JSON strings";
    homepage = "https://github.com/mangiucugna/json_repair/";
    changelog = "https://github.com/mangiucugna/json_repair/releases/tag/${src.tag}";
    license = licenses.mit;
    mainProgram = "json_repair";
  };
}
