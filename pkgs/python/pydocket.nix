{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  hatchling,
  hatchVcs,
  cloudpickle,
  cronsim,
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
  uncalledFor,
  pythonOlder,
}:
buildPythonPackage rec {
  pname = "pydocket";
  version = "0.19.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "chrisguidry";
    repo = "docket";
    rev = version;
    hash = "sha256-215VlCGwQx7vf5nFdu38PP21X911bo0i9rt7LMolPaw=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'dynamic = ["version"]' 'version = "${version}"'
  '';

  build-system = [
    hatchling
    hatchVcs
  ];

  dependencies =
    [
      cloudpickle
      cronsim
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
      uncalledFor
    ]
    ++ lib.optionals (pythonOlder "3.11") [exceptiongroup]
    ++ lib.optionals (pythonOlder "3.11" && taskgroup != null) [taskgroup];

  doCheck = false;
  pythonImportsCheck = ["docket"];

  meta = with lib; {
    description = "Distributed background task system for Python functions";
    homepage = "https://github.com/chrisguidry/docket";
    license = licenses.mit;
  };
}
