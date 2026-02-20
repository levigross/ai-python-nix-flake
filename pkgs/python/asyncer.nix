{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  pdmBackend,
  anyio,
  typingExtensions,
}:
buildPythonPackage rec {
  pname = "asyncer";
  version = "0.0.8";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "fastapi";
    repo = "asyncer";
    rev = version;
    hash = "sha256-SbByOiTYzp+G+SvsDqXOQBAG6nigtBXiQmfGgfKRqvM=";
  };

  build-system = [pdmBackend];

  dependencies = [
    anyio
    typingExtensions
  ];

  doCheck = false;
  pythonImportsCheck = ["asyncer"];

  meta = with lib; {
    description = "Async and await focused on developer ergonomics";
    homepage = "https://github.com/fastapi/asyncer";
    license = licenses.mit;
  };
}
