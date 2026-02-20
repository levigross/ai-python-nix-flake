{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  uvBuild,
  aiofile,
  anyio,
  beartype,
  cachetools,
  keyring,
  typingExtensions,
}:

buildPythonPackage rec {
  pname = "py-key-value-aio";
  version = "0.4.4";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "strawgate";
    repo = "py-key-value";
    rev = version;
    hash = "sha256-JznZW3FOKlhZD42Ng108tNB4bNiEad7QBiu8RmflTXM=";
  };

  build-system = [ uvBuild ];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "uv_build>=0.8.2,<0.9.0" "uv_build>=0.8.2,<1.0.0"

    # aiofile.TextFileWrapper in nixpkgs does not expose flush(); writes are
    # already awaited and fsync is called immediately after.
    substituteInPlace src/key_value/aio/stores/filetree/store.py \
      --replace-fail "            await f.flush()" "            pass"
  '';

  dependencies = [
    aiofile
    anyio
    beartype
    cachetools
    keyring
    typingExtensions
  ];

  doCheck = false;
  pythonImportsCheck = [ "key_value" ];

  meta = with lib; {
    description = "Async key-value store interfaces";
    homepage = "https://github.com/strawgate/py-key-value";
    license = licenses.asl20;
  };
}
