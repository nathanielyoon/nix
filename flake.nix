{
  description = "New flake!";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    auto-cpufreq = {
      url = "github:AdnanHodzic/auto-cpufreq";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri = {
      url = "github:sodiboo/niri-flake";
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
        inputs.auto-cpufreq.nixosModules.default
        inputs.disko.nixosModules.default
        inputs.impermanence.nixosModules.default
        ./boot.nix
        ./configuration.nix
        inputs.home-manager.nixosModules.default
        {
          nixpkgs.overlays = [ inputs.zig.overlays.default ];
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.nathaniel = import ./home.nix;
            extraSpecialArgs = {
              inherit (inputs) niri;
              pkgs = import inputs.nixpkgs {
                system = "x86_64-linux";
                overlays = [ inputs.niri.overlays.niri ];
              };
            };
          };
        }
      ];
    };
  };
}
