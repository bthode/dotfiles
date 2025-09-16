{
  description = "";
  inputs = {
    nixpkgs.url = "flake:nixpkgs/nixpkgs-unstable";
    nix-darwin = {

      # TODO, which is correct??
      # nix-darwin.url = "github:nix-darwin/nix-darwin/master";
      url = "flake:nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "flake:home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
  };
  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      home-manager,
      nix-homebrew,
      homebrew-core,
      homebrew-cask,
    }:
    let
      flakeContext = {
        inherit inputs;
      };

    in
    {
      darwinConfigurations = {
        air = import ./darwinConfigurations/air.nix flakeContext;
        work = import ./darwinConfigurations/work.nix flakeContext;
      };
      darwinModules = {
        darwin = import ./darwinModules/darwin.nix flakeContext;
      };
      homeConfigurations = {
        bthode = import ./homeConfigurations/bthode.nix flakeContext;
      };
      homeModules = {
        bthode = import ./homeModules/bthode.nix flakeContext;
      };
    };
}
