{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  hatchling,
  uvDynamicVersioning,
  anyio,
  httpx,
  httpxSse,
  jsonschema,
  pydantic,
  pydanticSettings,
  pyjwt,
  pythonMultipart,
  sseStarlette,
  starlette,
  typingExtensions,
  typingInspection,
  uvicorn,
  pythonOlder,
}:

buildPythonPackage rec {
  pname = "mcp";
  version = "1.26.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "modelcontextprotocol";
    repo = "python-sdk";
    rev = "v${version}";
    hash = "sha256-TGkAyuBcIstL2BCZYBWoi7PhnhoBvap67sLWGe0QUoU=";
  };

  build-system = [
    hatchling
    uvDynamicVersioning
  ];

  dependencies = [
    anyio
    httpx
    httpxSse
    jsonschema
    pydantic
    pydanticSettings
    pyjwt
    pythonMultipart
    sseStarlette
    starlette
    typingInspection
    uvicorn
  ] ++ lib.optionals (pythonOlder "3.11") [ typingExtensions ];

  doCheck = false;
  pythonImportsCheck = [ "mcp" ];

  meta = with lib; {
    description = "Model Context Protocol SDK";
    homepage = "https://github.com/modelcontextprotocol/python-sdk";
    license = licenses.mit;
  };
}
