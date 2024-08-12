self:
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.wl-screenrec-daemon;
in
{
  options.services.wl-screenrec-daemon = {
    enable = lib.mkEnableOption "wl-screenrec-daemon";
    package = lib.mkOption {
      type = lib.types.package;
      default = self.packages.${pkgs.system}.wl-screenrec-daemon;
    };
    args = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
    wl-screenrec-args = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
    systemd.user.services.wl-screenrec-daemon = {
      Unit = {
        Description = "wl-screenrec-daemon";
        PartOf = [ "graphical-session.target" ];
        Requires = [ "graphical-session.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart = "${lib.getExe cfg.package} --daemon ${lib.concatStringsSep " " cfg.args} -- ${lib.concatStringsSep " " cfg.wl-screenrec-args}";
        Restart = "on-failure";
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
