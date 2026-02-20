{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.ai-python;
in {
  options.programs.ai-python = {
    enable = lib.mkEnableOption "AI Python package environment";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.python3.withPackages (ps: [
        ps.fastmcp
        ps."claude-code-sdk"
        ps.dspy
      ]);
      defaultText = lib.literalExpression ''
        pkgs.python3.withPackages (ps: [ ps.fastmcp ps."claude-code-sdk" ps.dspy ])
      '';
      description = ''
        Python environment that contains fastmcp (v3), claude-code-sdk, and dspy.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [cfg.package];
  };
}
