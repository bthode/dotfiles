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
        homeModules.bthode.username = "bryan.thode";
        darwinModules.darwin.primaryUser = "bryan.thode";
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users."bryan.thode" = {
          home.homeDirectory = lib.mkForce "/Users/bryan.thode";
          home.username = "bryan.thode";
          home.stateVersion = "25.11";
        };
        programs = {
          _1password = {
            enable = true;
          };
          _1password-gui = {
            enable = true;
          };
        };
        system = {
          stateVersion = 6;
          activationScripts.extraActivation.text = ''
            /opt/homebrew/bin/displayplacer "id:37D8832A-2D66-02CA-B9F7-8F30A301B230 degree:90"
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
