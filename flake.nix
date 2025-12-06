{
  description = "New flake!";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zig.url = "github:mitchellh/zig-overlay";
  };
  outputs = inputs: {
    nixosConfigurations.fw = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = inputs;
      modules = [
        inputs.nixos-hardware.nixosModules.framework-amd-ai-300-series
        inputs.disko.nixosModules.default
        inputs.impermanence.nixosModules.default
        ./boot.nix
        ./configuration.nix
        inputs.home-manager.nixosModules.default
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.nathaniel = import ./home.nix;
          };
        }
      ];
    };
  };
}
