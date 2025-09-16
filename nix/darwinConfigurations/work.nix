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
          primaryUser = "bryan.thode";
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
