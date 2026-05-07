{ inputs, config, lib, pkgs, ... }:
let
  hostSpec = config.hostSpec;
in
{  
  programs.git = {
    package = pkgs.gitFull;
    enable = true;

    settings = {
      user.name = hostSpec.handle;
      user.email = hostSpec.email.personal;

      log.showSignature = "true";
      init.defaultBranch = "main";
      pull.rebase = "true";
      credential.help = "store";
      core.editor = "vim";
      core.pager = "delta";
      help.autocorrect = "prompt";
      # user.signingkey = "${publicKey}";

      # commit.gpgsign = true;
      gpg.format = "ssh";
    };
    ignores = [
      ".direnv"
      "result"
    ];
  };
}
