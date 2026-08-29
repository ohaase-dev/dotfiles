{
  description = "My Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";
    nix-darwin.url = "github:LnL7/nix-darwin/nix-darwin-25.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mac-app-util.url = "github:hraban/mac-app-util";

    # NEW: a nixpkgs revision where inetutils is 2.6 and builds
    nixpkgs-inetutils-2-6.url =
    "github:NixOS/nixpkgs/a1bab9e494f5f4939442a57a58d0449a109593fe";
  };
  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager, mac-app-util, nixpkgs-inetutils-2-6 }:
  let
    system = "aarch64-darwin";  # or "x86_64-darwin"
    # NEW: packages from the legacy nixpkgs revision
    pkgsInetutils26 = import nixpkgs-inetutils-2-6 { inherit system; };
    
    configuration = { pkgs, config, ... }: {
      nixpkgs.config.allowUnfree = true;


      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [ 
#          pkgs.nushell
          # pkgs.gitFull
          # pkgs.git
          # pkgs.git-credential-manager
          pkgs.vim
          pkgs.k9s
          pkgs.kubectx
          #pkgs.vscode
          #(pkgs.vscode.override { isInsiders = true; })
          pkgs.jetbrains.rider
          pkgs.jetbrains.datagrip
          pkgs.jetbrains.gateway
          #pkgs.wezterm
          pkgs.kubectl
          pkgs.kubeswitch
          pkgs.kubelogin
          pkgs.kubelogin-oidc
          (pkgs.azure-cli.withExtensions [ pkgs.azure-cli.extensions.aks-preview ])
          pkgs.nerd-fonts.jetbrains-mono
          pkgs.lazydocker
          #pkgs.tailscale
          #pkgs.zulu8
          #pkgs.flameshot
          # pkgs.direnv
          # pkgs.sshs
          # pkgs.glow
          pkgs.psqlodbc
          pkgs.raycast
          pkgs.swaks
          pkgs.inetutils
          pkgs.ddev
          pkgs.nmap
          pkgs.powershell
          pkgs.rclone
          pkgs.azure-storage-azcopy
          pkgs.restic
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
      nix.settings.experimental-features = "nix-command flakes";
      programs.zsh.enable = true;  # default shell on catalina
      system.configurationRevision = self.rev or self.dirtyRev or null;
      system.stateVersion = 4;
      system.primaryUser = "olafhaase";
      nixpkgs.hostPlatform = "aarch64-darwin";
      security.pam.services.sudo_local.touchIdAuth = true;
      #fonts.fontconfig.enable = true;
      fonts.packages = with pkgs; [
        nerd-fonts.jetbrains-mono
        # (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
      ];

      users.users.olafhaase ={
          home = "/Users/olafhaase";
          #shell = pkgs.nushell;
      };


      home-manager.backupFileExtension = "backup";
      ids.gids.nixbld = 350;
      #nix.configureBuildUsers = true;
      #nix.useDaemon = true;

      #networking.applicationFirewall = {
      #  enable = true;
      #  allowSigned = true;
      #  allowSignedApp = true;
      #  blockAllIncoming = false;
      #  enableStealthMode = false;
      #};

      system.defaults = {
        dock = {
          autohide = true;
          mru-spaces = false;
          expose-animation-duration = 0.0;
          autohide-delay = 0.0;
          autohide-time-modifier = 0.0;
        };

        finder = {
          _FXShowPosixPathInTitle = true; # show full path in finder title
          AppleShowAllExtensions = true; # show all file extensions
          FXPreferredViewStyle = "clmv";
          FXEnableExtensionChangeWarning = false; # disable warning when changing file extension
          QuitMenuItem = true; # enable quit menu item
          ShowPathbar = true; # show path bar
          ShowStatusBar = true; # show status bar
        };
        
        #loginwindow.LoginwindowText = "devops-toolbox";
        screencapture.location = "~/Pictures/screenshots";
        #screensaver.askForPasswordDelay = 10;
      };
    };
  in
  {
    darwinConfigurations."BF00223" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [ 
	      configuration
        mac-app-util.darwinModules.default

        # NEW: overlay inetutils from the legacy package set
        {
          nixpkgs.overlays = [
            (_final: _prev: {
              inetutils = pkgsInetutils26.inetutils;
            })
          ];
        }

        home-manager.darwinModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.olafhaase = import ./home.nix;
          home-manager.extraSpecialArgs = {
            userHome = "/Users/olafhaase";
          };
          # To enable it for all users:
          home-manager.sharedModules = [
            mac-app-util.homeManagerModules.default
          ];
        }
      ];
    };
    # Expose the package set, including overlays, for convenience.
    # darwinPackages = self.darwinConfigurations."BF00223".pkgs;
  };
}
