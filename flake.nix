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
    helix = {
      url = "github:helix-editor/helix/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zig.url = "github:mitchellh/zig-overlay";
    wezterm = {
      url = "github:wezterm/wezterm?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      nixpkgs,
      nixos-hardware,
      disko,
      auto-cpufreq,
      impermanence,
      home-manager,
      zig,
      wezterm,
      helix,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
    in
    {
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-rfc-style;
      nixosConfigurations.fw = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = inputs;
        modules = [
          nixos-hardware.nixosModules.framework-amd-ai-300-series
          disko.nixosModules.default
          auto-cpufreq.nixosModules.default
          impermanence.nixosModules.default
          ./disk.nix
          ./configuration.nix
          home-manager.nixosModules.default
          {
            nixpkgs.overlays = [
              helix.overlays.default
              (final: prev: {
                zigpkgs = zig.packages.${prev.stdenv.hostPlatform.system}.master;
                wezterm = wezterm.packages.${prev.stdenv.hostPlatform.system}.default;
              })
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
