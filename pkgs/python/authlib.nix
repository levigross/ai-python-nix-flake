{
  authlib,
  fetchFromGitHub,
  lib,
  pythonMultipart,
}:
authlib.overridePythonAttrs (old: rec {
  version = "1.6.5";

  src = fetchFromGitHub {
    owner = "lepture";
    repo = "authlib";
    rev = "v${version}";
    hash = "sha256-lz2cPqag6lZ9PXb3O/SV4buIPDDzhI71/teqWHLG+vE=";
  };

  nativeCheckInputs =
    (old.nativeCheckInputs or [])
    ++ [
      pythonMultipart
    ];
})
