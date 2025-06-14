{ ... }:
let
  myAliases = import ./aliases.nix;
in
{
  programs.zsh = {
    enable = true;
    shellAliases = myAliases;
    enableCompletion = true;
    autosuggestion.enable = true;
    dotDir = ".config/zsh";
    syntaxHighlighting.enable = true;
    history = {
      path = "$XDG_CACHE_HOME/zsh/history";
      save = 10000;
      size = 10000;
    };
    plugins = [
      # Add your zsh plugins here
    ];
    initContent = ''
      # Completion files: Use XDG dirs
      [ -d "$XDG_CACHE_HOME"/zsh ] || mkdir -p "$XDG_CACHE_HOME"/zsh
      zstyle ':completion:*' cache-path "$XDG_CACHE_HOME"/zsh/zcompcache
      compinit -d "$XDG_CACHE_HOME"/zsh/zcompdump-$ZSH_VERSION

      fastfetch
    '';
  };
}