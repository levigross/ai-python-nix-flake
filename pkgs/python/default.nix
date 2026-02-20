{
  python,
  pythonPrev ? python,
}: {
  authlib = python.callPackage ./authlib.nix {
    authlib = pythonPrev.authlib;
    pythonMultipart = python."python-multipart";
  };

  fakeredis = python.callPackage ./fakeredis.nix {
    fakeredis = pythonPrev.fakeredis;
  };

  mcp = python.callPackage ./mcp.nix {
    httpxSse = python."httpx-sse";
    pydanticSettings = python."pydantic-settings";
    pythonMultipart = python."python-multipart";
    sseStarlette = python."sse-starlette";
    typingExtensions = python."typing-extensions";
    typingInspection = python."typing-inspection";
    uvDynamicVersioning = python."uv-dynamic-versioning";
  };

  "py-key-value-aio" = python.callPackage ./py-key-value-aio.nix {
    typingExtensions = python."typing-extensions";
    uvBuild = python."uv-build";
  };

  asyncer = python.callPackage ./asyncer.nix {
    pdmBackend = python."pdm-backend";
    typingExtensions = python."typing-extensions";
  };

  "json-repair" = python.callPackage ./json-repair.nix {};

  pydocket = python.callPackage ./pydocket.nix {
    fakeredis = python.fakeredis;
    hatchVcs = python."hatch-vcs";
    opentelemetryApi = python."opentelemetry-api";
    prometheusClient = python."prometheus-client";
    pyKeyValueAio = python."py-key-value-aio";
    pythonJsonLogger = python."python-json-logger";
    typingExtensions = python."typing-extensions";
  };

  fastmcp = python.callPackage ./fastmcp.nix {
    authlib = python.authlib;
    anthropic = python.anthropic;
    azureIdentity = python."azure-identity";
    dirtyEquals = python."dirty-equals";
    emailValidator = python."email-validator";
    fastapi = python.fastapi;
    inlineSnapshot = python."inline-snapshot";
    jsonschemaPath = python."jsonschema-path";
    mcp = python.mcp;
    openapiPydantic = python."openapi-pydantic";
    opentelemetryApi = python."opentelemetry-api";
    opentelemetrySdk = python."opentelemetry-sdk";
    openai = python.openai;
    pydocket = python.pydocket;
    psutil = python.psutil;
    pytestAsyncio = python."pytest-asyncio";
    pytestEnv = python."pytest-env";
    pytestHttpx = python."pytest-httpx";
    pytestTimeout = python."pytest-timeout";
    pytestXdist = python."pytest-xdist";
    pyKeyValueAio = python."py-key-value-aio";
    pythonDotenv = python."python-dotenv";
    uv = python.uv;
    uvDynamicVersioning = python."uv-dynamic-versioning";
  };

  "claude-code-sdk" = python.callPackage ./claude-code-sdk.nix {
    mcp = python.mcp;
    pytestAsyncio = python."pytest-asyncio";
    typingExtensions = python."typing-extensions";
  };

  gepa = python.callPackage ./gepa.nix {};

  dspy = python.callPackage ./dspy.nix {
    asyncer = python.asyncer;
    gepa = python.gepa;
    jsonRepair = python."json-repair";
    pytestAsyncio = python."pytest-asyncio";
    pytestMock = python."pytest-mock";
  };
}
