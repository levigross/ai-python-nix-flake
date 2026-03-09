{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  hatchling,
  hypothesis,
  jsonpath-ng,
  lupa,
  pyprobables,
  pytest-asyncio,
  pytest-mock,
  pytestCheckHook,
  redis,
  redisTestHook,
  sortedcontainers,
  valkey,
}:
buildPythonPackage rec {
  pname = "fakeredis";
  version = "2.33.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "dsoftwareinc";
    repo = "fakeredis-py";
    tag = "v${version}";
    hash = "sha256-uvbvrziVdoa/ip8MbZG8GcpN1FoINxUV+SDVRmg78Qs=";
  };

  build-system = [hatchling];

  dependencies = [
    redis
    sortedcontainers
  ];

  optional-dependencies = {
    lua = [lupa];
    json = [jsonpath-ng];
    bf = [pyprobables];
    cf = [pyprobables];
    probabilistic = [pyprobables];
    valkey = [valkey];
  };

  nativeCheckInputs = [
    hypothesis
    pytest-asyncio
    pytest-mock
    pytestCheckHook
    redisTestHook
    valkey
  ];

  pythonImportsCheck = ["fakeredis"];

  disabledTestMarks = ["slow"];

  disabledTests = [
    # FakeValkey support is not exposed by the packaged module.
    "test_init_args"
    "test_async_init_kwargs"
    # redis/valkey sandbox does not expose evalsha in this test path.
    "test_async_lock"
    # Score payloads come back as bytes instead of floats in Nix builders.
    "test_zrank_redis7_2"
    "test_zrevrank_redis7_2"
    # These ACL/client-info paths are still flaky in packaged test environments.
    "test_acl_log_auth_exist"
    "test_acl_log_invalid_channel"
    "test_acl_log_invalid_key"
    "test_client_id"
    "test_client_info"
    "test_client_list"
  ];

  preCheck = ''
    redisTestPort=6390
  '';

  meta = with lib; {
    description = "Fake implementation of Redis API";
    homepage = "https://github.com/dsoftwareinc/fakeredis-py";
    changelog = "https://github.com/dsoftwareinc/fakeredis-py/releases/tag/${src.tag}";
    license = [licenses.bsd3];
  };
}
