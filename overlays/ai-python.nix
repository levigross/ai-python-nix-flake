final: prev: {
  pythonPackagesExtensions =
    (prev.pythonPackagesExtensions or [])
    ++ [
      (pyFinal: pyPrev:
        {
          # nixpkgs aiomisc is missing the conditional typing-extensions dep
          # (Requires-Dist: typing_extensions ; python_version < "3.12")
          aiomisc = pyPrev.aiomisc.overridePythonAttrs (old: {
            dependencies =
              (old.dependencies or [])
              ++ prev.lib.optionals
              (prev.lib.versionOlder pyFinal.python.version "3.12")
              [pyFinal.typing-extensions];
          });

          # nixpkgs-unstable is missing test deps for datamodel-code-generator
          "datamodel-code-generator" = pyPrev."datamodel-code-generator".overridePythonAttrs (old: {
            nativeCheckInputs =
              (old.nativeCheckInputs or [])
              ++ [pyFinal.time-machine pyFinal.inline-snapshot];
          });
        }
        // import ../pkgs/python {
          python = pyFinal;
          pythonPrev = pyPrev;
        })
    ];
}
