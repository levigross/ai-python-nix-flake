{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  jsonschema,
  pytestCheckHook,
  setuptools,
}:
buildPythonPackage rec {
  pname = "json-repair";
  version = "0.59.4";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "mangiucugna";
    repo = "json_repair";
    tag = "v${version}";
    hash = "sha256-tmiQ4ZHXd1FMVfZlJwdGqx5yxlxsImI7mnjICe3+maI=";
  };

  build-system = [setuptools];

  nativeCheckInputs = [
    jsonschema
    pytestCheckHook
  ];

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
