{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  hatchling,
  hatchVcs,
}:
buildPythonPackage rec {
  pname = "uncalled-for";
  version = "0.3.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "chrisguidry";
    repo = "uncalled-for";
    rev = version;
    hash = "sha256-5jFMlynYaxd83SQiZ1uPs1whWFgKP4y6s473TplH4iI=";
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
