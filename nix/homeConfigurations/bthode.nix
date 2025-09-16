{ inputs, ... }@flakeContext:
let
  homeModule =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      config = {
        home = {
          username = "bthode";
          homeDirectory = "/Users/bthode";
          stateVersion = "25.11";
        };
        programs = {
          zellij = {
            enable = true;
            enableFishIntegration = true;
          };
          ripgrep = {
            enable = true;
            arguments = [
              "--max-columns=150"
              "--max-columns-preview"
              "--line-number"
              "--glob=!*.min.js"
            ];
          };
        };

      };
    };
  nixosModule =
    { ... }:
    {
      home-manager.users.bthode = homeModule;
    };
in
(
  (inputs.home-manager.lib.homeManagerConfiguration {
    modules = [
      homeModule
    ];
    pkgs = inputs.nixpkgs.legacyPackages.aarch64-darwin;
  })
  {
    inherit nixosModule;
  }
)
