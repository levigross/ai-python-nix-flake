{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  hatchling,
  pdmBackend,
  uvDynamicVersioning,
}:
buildPythonPackage rec {
  pname = "griffelib";
  version = "2.0.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "mkdocstrings";
    repo = "griffe";
    rev = version;
    hash = "sha256-Fxa9lrBVQ/enVLiU7hUc0d5x9ItI19EGnbxa7MX6Plc=";
  };

  sourceRoot = "${src.name}/packages/griffelib";

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'dynamic = ["version"]' 'version = "${version}"'
  '';

  build-system = [
    hatchling
    pdmBackend
    uvDynamicVersioning
  ];

  doCheck = false;
  pythonImportsCheck = ["griffe"];

  meta = with lib; {
    description = "Extract the structure of Python projects for API documentation and breaking change detection";
    homepage = "https://github.com/mkdocstrings/griffe";
    license = licenses.isc;
  };
}
