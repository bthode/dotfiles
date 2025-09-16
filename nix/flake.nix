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

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.darwin.follows = "nix-darwin";
    };

    nix-secrets = {
      url = "git+ssh://git@github.com/bthode/nix-secrets.git";
      flake = false; # This is just a source, not a flake
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
      agenix,
      nix-secrets,
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
