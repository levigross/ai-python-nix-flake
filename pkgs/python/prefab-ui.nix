{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  hatchling,
  uvDynamicVersioning,
  cyclopts,
  pydantic,
  rich,
}:
buildPythonPackage rec {
  pname = "prefab-ui";
  version = "0.19.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "PrefectHQ";
    repo = "prefab";
    rev = "v${version}";
    hash = "sha256-caSsMR6Il4D1l9Y1ScdN5HZ4TPG2YyB6JzctDt+W3WE=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'dynamic = ["version"]' 'version = "${version}"'
  '';

  build-system = [
    hatchling
    uvDynamicVersioning
  ];

  dependencies = [
    cyclopts
    pydantic
    rich
  ];

  doCheck = false;
  pythonImportsCheck = ["prefab_ui"];

  meta = with lib; {
    description = "Agentic frontend framework used by FastMCP Prefab apps";
    homepage = "https://github.com/PrefectHQ/prefab";
    license = licenses.asl20;
  };
}
