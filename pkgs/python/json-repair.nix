{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
}:

buildPythonPackage rec {
  pname = "json-repair";
  version = "0.54.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "mangiucugna";
    repo = "json_repair";
    rev = "v${version}";
    hash = "sha256-OwzyDrdN6jRxA/KthmrGgtfE1ZN89XebxWgtovoK2Nk=";
  };

  build-system = [ setuptools ];

  doCheck = false;
  pythonImportsCheck = [ "json_repair" ];

  meta = with lib; {
    description = "Repair broken JSON strings";
    homepage = "https://github.com/mangiucugna/json_repair/";
    license = licenses.mit;
  };
}
