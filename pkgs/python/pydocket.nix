{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  hatchling,
  hatchVcs,
  cloudpickle,
  croniter,
  exceptiongroup,
  fakeredis,
  lupa,
  opentelemetryApi,
  prometheusClient,
  pyKeyValueAio,
  pythonJsonLogger,
  redis,
  rich,
  taskgroup ? null,
  typer,
  typingExtensions,
  pythonOlder,
}:

buildPythonPackage rec {
  pname = "pydocket";
  version = "0.17.8";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "chrisguidry";
    repo = "docket";
    rev = version;
    hash = "sha256-rQMCNqmaE2vRt0Yx9z7O7pHsyBez0WfMfvgzyyTb8sY=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'dynamic = ["version"]' 'version = "${version}"'
  '';

  build-system = [
    hatchling
    hatchVcs
  ];

  dependencies = [
    cloudpickle
    croniter
    fakeredis
    lupa
    opentelemetryApi
    prometheusClient
    pyKeyValueAio
    pythonJsonLogger
    redis
    rich
    typer
    typingExtensions
  ]
  ++ lib.optionals (pythonOlder "3.11") [ exceptiongroup ]
  ++ lib.optionals (pythonOlder "3.11" && taskgroup != null) [ taskgroup ];

  doCheck = false;
  pythonImportsCheck = [ "docket" ];

  meta = with lib; {
    description = "Distributed background task system for Python functions";
    homepage = "https://github.com/chrisguidry/docket";
    license = licenses.mit;
  };
}
