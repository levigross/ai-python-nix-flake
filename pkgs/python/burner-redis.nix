{
  lib,
  buildPythonPackage,
  fetchPypi,
  rustPlatform,
  cargo,
  rustc,
  maturin,
}:
buildPythonPackage rec {
  pname = "burner-redis";
  version = "0.1.7";
  pyproject = true;

  src = fetchPypi {
    pname = "burner_redis";
    inherit version;
    hash = "sha256-dHT/CSZp/RHvdlQRVyza/MPYm4BUrvTKBhe+bWvkxoA=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit src;
    hash = "sha256-laD/FhYxXCOZOvs0e7ad80vUgX4eoHpLQu6dx/glkEM=";
  };

  build-system = [maturin];

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
    cargo
    rustc
  ];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'dynamic = ["version"]' 'version = "${version}"'
  '';

  doCheck = false;
  pythonImportsCheck = ["burner_redis"];

  meta = with lib; {
    description = "Embedded, in-process Redis-compatible database with Python bindings";
    homepage = "https://github.com/PrefectHQ/burner-redis";
    license = licenses.mit;
  };
}
