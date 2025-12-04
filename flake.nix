{
  description = "New flake!";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    impermanence.url = "github:nix-community/impermanence";
    auto-cpufreq = {
      url = "github:AdnanHodzic/auto-cpufreq";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    helix = {
      url = "github:helix-editor/helix/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ghostty = {
      url = "github:ghostty-org/ghostty";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zig.url = "github:mitchellh/zig-overlay";
  };
  outputs = inputs: {
    nixosConfigurations.fw = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        inputs.nixos-hardware.nixosModules.framework-amd-ai-300-series
        inputs.auto-cpufreq.nixosModules.default
        inputs.impermanence.nixosModules.impermanence
        inputs.home-manager.nixosModules.home-manager
        {
          nixpkgs.overlays = [
            inputs.zig.overlays.default
            inputs.niri.overlays.niri
          ];
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = { inherit (inputs) helix niri ghostty; };
            users.nathaniel = import ./home.nix;
          };
        }
        ./configuration.nix
      ];
    };
  };
}
