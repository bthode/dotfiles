{ inputs, ... }@flakeContext:
let
  darwinModule =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [
        inputs.home-manager.darwinModules.home-manager
        flakeContext.inputs.self.darwinModules.darwin
        flakeContext.inputs.self.homeModules.bthode
      ];
      config = {
        homeModules.bthode.username = "bthode";
        darwinModules.darwin.primaryUser = "bthode";
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.bthode = {
          home.homeDirectory = lib.mkForce "/Users/bthode";
          home.username = "bthode";
          home.stateVersion = "25.11";
          programs.zellij = {
            enable = false;
            enableFishIntegration = false;
          };
        };
        documentation = {
          enable = false;
        };

        system = {
          stateVersion = 6;
          activationScripts.extraActivation.text = ''
            /opt/homebrew/bin/displayplacer "id:37D8832A-2D66-02CA-B9F7-8F30A301B230 res:1710x1112 hz:60 color_depth:8 enabled:true scaling:on origin:(0,0) degree:0"
          '';
        };
      };
    };
in
inputs.nix-darwin.lib.darwinSystem {
  modules = [
    darwinModule
  ];
  system = "aarch64-darwin";
}
