# home.nix
# home-manager switch 

{ config, pkgs, lib, ... }:

{
  home.username = "olafhaase";
  home.homeDirectory = "/Users/olafhaase";
  home.stateVersion = "24.11"; # Please read the comment before changing.


# Makes sense for user specific applications that shouldn't be available system-wide
  home.packages = [
          #pkgs.skim
          #pkgs.wezterm
          #pkgs.starship
          #pkgs.nushellPlugins.query
          #pkgs.nushellPlugins.skim
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
#    ".zshrc".source = ~/dotfiles/zshrc/.zshrc;
#    ".config/wezterm".source = ~/dotfiles/wezterm;
#    ".config/skhd".source = ~/dotfiles/skhd;
#    ".config/starship".source = ~/dotfiles/starship;
#    ".config/zellij".source = ~/dotfiles/zellij;
#    ".config/nvim".source = ~/dotfiles/nvim;
#    ".config/nix".source = ~/dotfiles/nix;
#    ".config/nix-darwin".source = ~/dotfiles/nix-darwin;
#    ".config/tmux".source = ~/dotfiles/tmux;
#    ".config/ghostty".source = ~/dotfiles/ghostty;
  };

  home.sessionVariables = {
  };

  home.sessionPath = [
    "/run/current-system/sw/bin"
      "$HOME/.nix-profile/bin"
      "/usr/local/share/dotnet"
  ];

  # # Need to create aliases because Launchbar doesn't look through symlinks.
  # home.activation.link-apps = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
  #   new_nix_apps="${config.home.homeDirectory}/Applications/Nix"
  #   rm -rf "$new_nix_apps"
  #   mkdir -p "$new_nix_apps"
  #   find -H -L "$genProfilePath/home-files/Applications" -name "*.app" -type d -print | while read -r app; do
  #     real_app=$(readlink -f "$app")
  #     app_name=$(basename "$app")
  #     target_app="$new_nix_apps/$app_name"
  #     echo "Alias '$real_app' to '$target_app'"
  #     ${pkgs.mkalias}/bin/mkalias "$real_app" "$target_app"
  #   done
  # '';

  programs.home-manager.enable = true;

  programs.nushell = {
    enable = true;
    # carapace.enable = true;
    # carapace.enableNushellIntegration = true;
  };

  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;
    extraConfig = ''
      local wezterm = require 'wezterm'
      local config = wezterm.config_builder()
      --config.color_scheme = "catppuccino-macchiato"
      config.color_scheme = "Catppuccin Mocha"
      config.front_end = "WebGpu"
      config.font_size = 15.0
      config.font = wezterm.font "JetBrains Mono"
      config.macos_window_background_blur = 30
      config.window_background_opacity = 1
      config.window_decorations = 'RESIZE'
      config.audible_bell = "Disabled"

      return config
    '';
  };

  programs.skim.enable = true;

  programs.zsh = {
    enable = true;
    initExtra = ''
      # Add any additional configurations here
      export PATH=/run/current-system/sw/bin:$HOME/.nix-profile/bin:$PATH
      if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
      fi
    '';
  };
  programs.starship = {
    enable = true;
    # theme = "minimal";
    settings = {
         add_newline = true;
         character = { 
         success_symbol = "[➜](bold green)";
         error_symbol = "[➜](bold red)";
       };
    };
  };

    programs.git = {
    enable = true;
    userName  = "Olaf Haase";
    userEmail = "olaf.haase@bob.ch";
    extraConfig.credential.helper = "manager";
    extraConfig.credential."https://dev.azure.com".usehttppath = "true";
    extraConfig.credential."https://github.com".username = "ohaase-dev";
    extraConfig.credential.credentialStore = "cache";
  };

}
