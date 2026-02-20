{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  build,
  setuptools,
  wheel,
}:
buildPythonPackage rec {
  pname = "gepa";
  version = "0.0.26";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "gepa-ai";
    repo = "gepa";
    rev = "v${version}";
    hash = "sha256-zkGD9QlBV9UckmJrLeMtU68jdh3YS5d+rwTUUMpvUUc=";
  };

  build-system = [
    build
    setuptools
    wheel
  ];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'version="0.0.25"' 'version="${version}"'
  '';

  doCheck = false;
  pythonImportsCheck = ["gepa"];

  meta = with lib; {
    description = "Framework for optimizing textual system components";
    homepage = "https://github.com/gepa-ai/gepa";
    license = licenses.mit;
  };
}
