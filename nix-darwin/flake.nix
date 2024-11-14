{
  description = "My Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mac-app-util.url = "github:hraban/mac-app-util";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    # Optional: Declarative tap management
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    homebrew-dotnet-sdks = {
      url = "github:isen-ng/homebrew-dotnet-sdk-versions";
      flake = false;
    };
    homebrew-ohtap = {
      url = "github:ohaase-dev/homebrew-ohtap";
      flake = false;
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager, mac-app-util, nix-homebrew, homebrew-core,  homebrew-cask, homebrew-bundle, homebrew-dotnet-sdks, homebrew-ohtap }:
  let
    configuration = { pkgs, config, ... }: {
      nixpkgs.config.allowUnfree = true;

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [ 
#          pkgs.nushell
          # pkgs.gitFull
          pkgs.git
          pkgs.git-credential-manager
          pkgs.vim
          pkgs.k9s
          #pkgs.kubectx
          pkgs.vscode
          pkgs.jetbrains.rider
          pkgs.jetbrains.datagrip
          pkgs.jetbrains.gateway
          pkgs.wezterm
          pkgs.kubectl
          pkgs.kubeswitch
          pkgs.kubelogin
          pkgs.kubelogin-oidc
          #(pkgs.azure-cli.withExtensions [ pkgs.azure-cli.extensions.aks-preview ])
          pkgs.flameshot
          # pkgs.dotnetCorePackages.sdk_6_0_1xx
          # pkgs.dotnetCorePackages.dotnet_8.sdk
          # pkgs.dotnetCorePackages.dotnet_9.sdk
#          pkgs.direnv
#          pkgs.sshs
#          pkgs.glow
        ];
      # system.activationScripts.applications.text = let
      #   env = pkgs.buildEnv {
      #     name = "system-applications";
      #     paths = config.environment.systemPackages;
      #     pathsToLink = "/Applications";
      #   };
      # in
      #   pkgs.lib.mkForce ''
      #     # Set up applications.
      #     echo "setting up /Applications..." >&2
      #     rm -rf /Applications/Nix\ Apps
      #     mkdir -p /Applications/Nix\ Apps
      #     find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
      #     while read -r src; do
      #       app_name=$(basename "$src")
      #       echo "copying $src" >&2
      #       ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
      #     done
      #   '';

      services.nix-daemon.enable = true;
      nix.settings.experimental-features = "nix-command flakes";
      programs.zsh.enable = true;  # default shell on catalina
      system.configurationRevision = self.rev or self.dirtyRev or null;
      system.stateVersion = 4;
      nixpkgs.hostPlatform = "aarch64-darwin";
      security.pam.enableSudoTouchIdAuth = true;

      #fonts.fontconfig.enable = true;
      fonts.packages = with pkgs; [
        (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
      ];

      users.users.olafhaase ={
          home = "/Users/olafhaase";
          shell = pkgs.nushell;
      };


      home-manager.backupFileExtension = "backup";
      ids.gids.nixbld = 350;
      nix.configureBuildUsers = true;
      nix.useDaemon = true;

      system.defaults = {
        dock.autohide = true;
        dock.mru-spaces = false;
        dock.expose-animation-duration = 0.0;
        dock.autohide-delay = 0.0;
        dock.autohide-time-modifier = 0.0;
        finder.AppleShowAllExtensions = true;
        finder.FXPreferredViewStyle = "clmv";
        #loginwindow.LoginwindowText = "devops-toolbox";
        screencapture.location = "~/Pictures/screenshots";
        #screensaver.askForPasswordDelay = 10;
      };

      # Homebrew needs to be installed on its own!
      homebrew = {
        enable = true;
        casks = [
          "intune-company-portal"
          "microsoft-edge"
          "microsoft-teams"
          "microsoft-office"
          "1password"
          "1password-cli"
          "obsidian"
          "orbstack"
          "dotnet-sdk9"
          "dotnet-sdk8"
          "dotnet-sdk6"
          "switchbar"
          "omnidisksweeper"
          "commander-one"
        ];
        brews = [
          "mas"
        ];
        masApps = {
          OnePasswordSafari = 1569813296;
          Greenshot = 1103915944;
          Whatsapp = 310633997;
          BlackmagicDiskSpeedTest = 425264550;
        };
      };
    };
  in
  {
    darwinConfigurations."Olafs-MacBook-Air" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [ 
	      configuration
        mac-app-util.darwinModules.default
        home-manager.darwinModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.olafhaase = import ./home.nix;
          # To enable it for all users:
          home-manager.sharedModules = [
            mac-app-util.homeManagerModules.default
          ];
        }
      ];
    };

    darwinConfigurations."BF00223" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [ 
	      configuration
        mac-app-util.darwinModules.default
        home-manager.darwinModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.olafhaase = import ./home.nix;
          # To enable it for all users:
          home-manager.sharedModules = [
            mac-app-util.homeManagerModules.default
          ];
        }
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            # Install Homebrew under the default prefix
            enable = true;

            # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
            enableRosetta = true;

            # User owning the Homebrew prefix
            user = "olafhaase";

            # Optional: Declarative tap management
            taps = {
              "homebrew/homebrew-core" = homebrew-core;
              "homebrew/homebrew-cask" = homebrew-cask;
              "homebrew/homebrew-bundle" = homebrew-bundle;
              "isen-ng/homebrew-dotnet-sdks" =  homebrew-dotnet-sdks;
              "ohaase-dev/homebrew-ohtap" =  homebrew-ohtap;
            };

            # Optional: Enable fully-declarative tap management
            #
            # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
            mutableTaps = false;
          };
        }
      ];
    };
    # Expose the package set, including overlays, for convenience.
    # darwinPackages = self.darwinConfigurations."BF00223".pkgs;
  };
}
