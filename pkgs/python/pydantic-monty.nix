{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  rustPlatform,
  cargo,
  rustc,
  maturin,
}:
buildPythonPackage rec {
  pname = "pydantic-monty";
  version = "0.0.7";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "pydantic";
    repo = "monty";
    rev = "v${version}";
    hash = "sha256-6iYQ5OyjJhArZ3rxM6z0l/qgxTY3ja+rMODA6/EN6kw=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit src;
    hash = "sha256-NVBWA9oURCMF767af3rWZU0XfWZKBIuglG6OOLekKtI=";
  };

  buildAndTestSubdir = "crates/monty-python";

  build-system = [maturin];

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
    cargo
    rustc
  ];

  pythonImportsCheck = ["pydantic_monty"];

  meta = with lib; {
    description = "Python bindings for the Monty type checker";
    homepage = "https://github.com/pydantic/monty";
    license = licenses.mit;
  };
}
