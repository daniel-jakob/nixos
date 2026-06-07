{ lib, config, pkgs, ... }:
let
  myAliases = import ./aliases.nix;
in
{
  programs.zsh = {
    enable = true;
    shellAliases = myAliases;
    enableCompletion = true;
    autosuggestion.enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
    syntaxHighlighting.enable = true;
    history = {
      path = "$XDG_CACHE_HOME/zsh/history";
      save = 10000;
      size = 10000;
    };
    plugins = [
    # Add your zsh plugins here
    ];
    initContent = lib.mkMerge [
      (lib.mkOrder 500 ''
        # If non-interactive shell: stop immediately
        if [[ ! -o interactive ]]; then
          return
        fi
      '')

      (lib.mkOrder 900 ''
        #   # Completion files: Use XDG dirs
        #   [ -d "$XDG_CACHE_HOME"/zsh ] || mkdir -p "$XDG_CACHE_HOME"/zsh
        #   zstyle ':completion:*' cache-path "$XDG_CACHE_HOME"/zsh/zcompcache
        #   compinit -d "$XDG_CACHE_HOME"/zsh/zcompdump-$ZSH_VERSION

        #   fastfetch
        export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --inline-info"
      '')
    ];
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    tmux.enableShellIntegration = true;
  };
}
