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
  version = "0.0.11";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "pydantic";
    repo = "monty";
    rev = "v${version}";
    hash = "sha256-PRP8XcgeNVnc+2dWHxpizjvAtSjfqtkEXckXjPCRoJI=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit src;
    hash = "sha256-L18Prmtv+jKs8jG1HNSMp4hDwpDgLc1x9CV39WYFUK8=";
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
