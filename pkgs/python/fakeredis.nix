{
  fakeredis,
  fetchFromGitHub,
}:
fakeredis.overridePythonAttrs (old: rec {
  version = "2.32.1";

  src = fetchFromGitHub {
    owner = "cunla";
    repo = "fakeredis-py";
    rev = "v${version}";
    hash = "sha256-66lTCnN6M818FvEkPMRacmgrmBOYCIgbgxjqkhxsir8=";
  };

  disabledTests =
    (old.disabledTests or [])
    ++ [
      # On nixos-25.11, redis/valkey score payloads are bytes (b"1") instead of
      # float (1.0) for withscore responses in this test path.
      "test_zrank_redis7_2"
      # Same bytes-vs-float score representation mismatch as above.
      "test_zrevrank_redis7_2"
    ];
})
