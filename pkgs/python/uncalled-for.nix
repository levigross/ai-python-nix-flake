{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  hatchling,
  hatchVcs,
}:
buildPythonPackage rec {
  pname = "uncalled-for";
  version = "0.2.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "chrisguidry";
    repo = "uncalled-for";
    rev = version;
    hash = "sha256-+oc4ZQWp3Szkts/T0+iHrSXrq5NoIdbs15FRBGeYleQ=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'dynamic = ["version"]' 'version = "${version}"'
  '';

  build-system = [
    hatchling
    hatchVcs
  ];

  doCheck = false;
  pythonImportsCheck = ["uncalled_for"];

  meta = with lib; {
    description = "Async dependency injection for Python functions";
    homepage = "https://github.com/chrisguidry/uncalled-for";
    license = licenses.mit;
  };
}
