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
