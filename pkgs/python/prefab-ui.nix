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
  version = "0.10.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "PrefectHQ";
    repo = "prefab";
    rev = "v${version}";
    hash = "sha256-twy8g7daMZhg9uRc9LdtDYFGCt0bK9p3pl3lgtwaG1Y=";
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
