{ options, config, lib, pkgs, ... }:

let
  inherit (lib.attrsets) attrValues optionalAttrs;
  inherit (lib.modules) mkIf mkMerge;

  cfg = config.modules.desktop.distractions.lutris;
in {
  options.modules.desktop.distractions.lutris =
    let inherit (lib.options) mkEnableOption;
    in {
      enable = mkEnableOption "libre game-manager";
      league.enable = mkEnableOption "lutris LoL setup";
    };

  config = mkMerge [
    (mkIf cfg.enable {
      user.packages = attrValues ({
        lutris =
          pkgs.lutris.override { extraLibraries = pkgs: [ pkgs.jansson ]; };
      } // optionalAttrs (config.modules.virtualisation.wine.enable == false) {
        inherit (pkgs) winetricks;
        inherit (pkgs.wineWowPackages) fonts stagingFull;
      });
    })

    (mkIf (cfg.enable && cfg.league.enable) {
      boot.kernel.sysctl."abi.vsyscall32" = 0; # anti-cheat...
      networking.firewall.allowedTCPPorts = [ 443 ];
      environment.variables.QT_X11_NO_MITSHM = "1";

      user.packages = attrValues {
        inherit (pkgs) vulkan-tools dxvk;
        inherit (pkgs.gnome) zenity;
      };
    })
  ];
}
