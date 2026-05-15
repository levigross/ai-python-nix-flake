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
  version = "0.0.27";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "gepa-ai";
    repo = "gepa";
    rev = "v${version}";
    hash = "sha256-5IXXE76Nb2Lc+6wQmLIw4zmsWMhVOCvRLXLXZjMFhec=";
  };

  build-system = [
    build
    setuptools
    wheel
  ];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'version="0.0.26"' 'version="${version}"' \
      --replace-fail 'license = { text = "MIT" }' 'license = "MIT"'
  '';

  doCheck = false;
  pythonImportsCheck = ["gepa"];

  meta = with lib; {
    description = "Framework for optimizing textual system components";
    homepage = "https://github.com/gepa-ai/gepa";
    license = licenses.mit;
  };
}
