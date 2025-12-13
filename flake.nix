{
  description = "New flake!";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    auto-cpufreq = {
      url = "github:AdnanHodzic/auto-cpufreq";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zig.url = "github:mitchellh/zig-overlay";
    helix = {
      url = "github:helix-editor/helix/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wezterm = {
      url = "github:wezterm/wezterm?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs: {
    nixosConfigurations.fw = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = inputs;
      modules = [
        inputs.nixos-hardware.nixosModules.framework-amd-ai-300-series
        inputs.disko.nixosModules.default
        inputs.auto-cpufreq.nixosModules.default
        inputs.impermanence.nixosModules.default
        ./disk.nix
        ./configuration.nix
        inputs.home-manager.nixosModules.default
        {
          nixpkgs.overlays = [
            (final: prev: {
              zigpkgs = inputs.zig.packages.${prev.stdenv.hostPlatform.system}.master;
              wezterm = inputs.wezterm.packages.${prev.stdenv.hostPlatform.system}.default;
            })
            inputs.helix.overlays.default
          ];
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
