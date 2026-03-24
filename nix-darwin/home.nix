# home.nix
# home-manager switch 

{ config, pkgs, lib, userHome, ... }:

{
  home.username = "olafhaase";
  home.homeDirectory = "/Users/olafhaase";
  home.stateVersion = "25.11"; # Please read the comment before changing.


# Makes sense for user specific applications that shouldn't be available system-wide
#  home.packages = [
#  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
     ".config/starship.toml".source = "${userHome}/src/priv/dotfiles/starship/starship.toml";
     ".config/git/allowed_signers".source = "${userHome}/src/priv/dotfiles/git/allowed_signers";
  };

#  home.sessionVariables = {
#  };

  home.sessionPath = [
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
    "/run/current-system/sw/bin"
    "$HOME/.nix-profile/bin"
    "$HOME/.dotnet/tools"
    "/usr/local/share/dotnet"
  ];


  home.shellAliases = {
    #code = "code-insiders";
    ll = "ls -alh";
  };

  programs.home-manager.enable = true;

  programs.nushell = {
    enable = true;
    # carapace.enable = true;
    # carapace.enableNushellIntegration = true;
  };

  programs.skim.enable = true;

  programs.bash.shellAliases = config.home.shellAliases;

  programs.zsh = {
    shellAliases = config.home.shellAliases;
    enable = true;
    initContent = ''
      # Add any additional configurations here
      
      export PATH=/opt/homebrew/bin:/opt/homebrew/sbin:/run/current-system/sw/bin:$HOME/.nix-profile/bin:$HOME/.dotnet/tools:$PATH
      if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
      fi
    '';
  };

  programs.starship = {
    enable = true;
  };

  programs.git.settings = {
  enable = true;
  user.name  = "Olaf Haase";
  user.email = "olaf.haase@bob.ch";
  extraConfig.credential.helper = "manager";
  extraConfig.credential."https://dev.azure.com".usehttppath = "true";
  extraConfig.credential."https://github.com".username = "ohaase-dev";
  extraConfig.credential.credentialStore = "cache";
  extraConfig.credential."https://git.dn42.dev".provider = "generic";
  extraConfig.gpg.ssh.allowedSignersFile = "${userHome}/.config/git/allowed_signers";
};

}
