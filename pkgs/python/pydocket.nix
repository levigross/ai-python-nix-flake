{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  hatchling,
  hatchVcs,
  burnerRedis,
  cloudpickle,
  cronsim,
  exceptiongroup,
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
  version = "0.20.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "chrisguidry";
    repo = "docket";
    rev = version;
    hash = "sha256-KEKk9/tewl46GkZ7DV6MixAzz9ZKMIqjwzj5kZ38AFk=";
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
      burnerRedis
      cloudpickle
      cronsim
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
