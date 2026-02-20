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
  xxhash,
}:
buildPythonPackage rec {
  pname = "dspy";
  version = "3.1.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "stanfordnlp";
    repo = "dspy";
    rev = version;
    hash = "sha256-Mfl5ac367QnFgSHXTItBAQ0ksHR1mEKIjyptAbt/Bvc=";
  };

  build-system = [setuptools];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'version="3.1.2"' 'version="${version}"'
  '';

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
