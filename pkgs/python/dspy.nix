{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  anyio,
  asyncer,
  cachetools,
  cloudpickle,
  diskcache,
  gepa,
  jsonRepair,
  litellm,
  numpy,
  openai,
  optuna,
  orjson,
  pydantic,
  pytestCheckHook,
  pytestAsyncio,
  pytestMock,
  regex,
  requests,
  tenacity,
  tqdm,
  typeguard,
  xxhash,
}:
buildPythonPackage rec {
  pname = "dspy";
  version = "3.2.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "stanfordnlp";
    repo = "dspy";
    rev = version;
    hash = "sha256-xquV+FyDfejm1SCWYfuiezIkyutmm/1zOvd5X+oElrM=";
  };

  build-system = [setuptools];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'version="3.2.0"' 'version="${version}"'
  '';

  # Upstream pins cloudpickle>=3.1.2 and typeguard==4.4.3; nixpkgs ships
  # 3.1.1 and 4.4.4 respectively. Both diffs are patch-level and API-compatible.
  pythonRelaxDeps = [
    "cloudpickle"
    "typeguard"
  ];

  dependencies = [
    anyio
    asyncer
    cachetools
    cloudpickle
    diskcache
    gepa
    jsonRepair
    litellm
    numpy
    openai
    optuna
    orjson
    pydantic
    regex
    requests
    tenacity
    tqdm
    typeguard
    xxhash
  ];

  nativeCheckInputs = [
    pytestCheckHook
    pytestAsyncio
    pytestMock
  ];

  pytestFlagsArray = ["tests/primitives"];

  doCheck = true;
  pythonImportsCheck = ["dspy"];

  meta = with lib; {
    description = "Programming framework for language models";
    homepage = "https://github.com/stanfordnlp/dspy";
    license = licenses.mit;
  };
}
