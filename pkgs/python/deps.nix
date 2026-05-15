{
  python,
  pythonPrev ? python,
}: {
  authlib = python.callPackage ./authlib.nix {
    pythonMultipart = python."python-multipart";
  };

  fakeredis = python.callPackage ./fakeredis.nix {};

  "burner-redis" = python.callPackage ./burner-redis.nix {};

  "py-key-value-aio" = python.callPackage ./py-key-value-aio.nix {
    typingExtensions = python."typing-extensions";
    uvBuild = python."uv-build";
  };

  asyncer = python.callPackage ./asyncer.nix {
    pdmBackend = python."pdm-backend";
    sniffio = python.sniffio;
    typingExtensions = python."typing-extensions";
  };

  griffelib = python.callPackage ./griffelib.nix {
    pdmBackend = python."pdm-backend";
    uvDynamicVersioning = python."uv-dynamic-versioning";
  };

  "json-repair" = python.callPackage ./json-repair.nix {};

  "uncalled-for" = python.callPackage ./uncalled-for.nix {
    hatchVcs = python."hatch-vcs";
  };

  "prefab-ui" = python.callPackage ./prefab-ui.nix {
    uvDynamicVersioning = python."uv-dynamic-versioning";
  };

  "pydantic-monty" = python.callPackage ./pydantic-monty.nix {
    typingExtensions = python."typing-extensions";
  };

  pydocket = python.callPackage ./pydocket.nix {
    burnerRedis = python."burner-redis";
    hatchVcs = python."hatch-vcs";
    opentelemetryApi = python."opentelemetry-api";
    prometheusClient = python."prometheus-client";
    pyKeyValueAio = python."py-key-value-aio";
    pythonJsonLogger = python."python-json-logger";
    typingExtensions = python."typing-extensions";
    uncalledFor = python."uncalled-for";
  };
}
