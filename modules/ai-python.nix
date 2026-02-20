{...}: let
  aiPythonOverlay = import ../overlays/ai-python.nix;
  aiPythonFlakeModule = import ./flake-parts/ai-python.nix;

  aiPythonNixosModule = {...}: {
    imports = [./nixos/ai-python.nix];
    nixpkgs.overlays = [aiPythonOverlay];
  };
in {
  imports = [aiPythonFlakeModule];

  flake = {
    flakeModules.default = aiPythonFlakeModule;
    flakeModules.ai-python = aiPythonFlakeModule;
    nixosModules.default = aiPythonNixosModule;
    nixosModules.ai-python = aiPythonNixosModule;
  };
}
