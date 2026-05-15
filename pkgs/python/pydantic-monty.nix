{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  rustPlatform,
  cargo,
  rustc,
  maturin,
  typingExtensions,
}:
buildPythonPackage rec {
  pname = "pydantic-monty";
  version = "0.0.16";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "pydantic";
    repo = "monty";
    rev = "v${version}";
    hash = "sha256-UpHGCuoId8zNju3sQeSnt8J6Jh24na2u9/zDWrZKQWs=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit src;
    hash = "sha256-d8m5CJxkN4j/YEoXWrUMbsEjAXc/lNyTZ1Zq4RMosmw=";
  };

  buildAndTestSubdir = "crates/monty-python";

  build-system = [maturin];

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
    cargo
    rustc
  ];

  dependencies = [
    typingExtensions
  ];

  pythonImportsCheck = ["pydantic_monty"];

  meta = with lib; {
    description = "Python bindings for the Monty type checker";
    homepage = "https://github.com/pydantic/monty";
    license = licenses.mit;
  };
}
