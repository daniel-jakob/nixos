{ inputs, config, lib, pkgs, ... }:
{  
  programs.git = {
    userName = config.hostSpec.handle;
    userEmail = config.hostSpec.email;

    # Enforce SSH to leverage yubikey
    extraConfig = {
      log.showSignature = "true";
      init.defaultBranch = "main";
      pull.rebase = "true";
      credential.help = "store";
      core.editor = "vim";
      core.pager = "delta";
      help.autocorrect = "prompt";
      user.signingkey = "${publicKey}";

      commit.gpgsign = true;
      gpg.format = "ssh";
    };
    ignores = [
      ".direnv"
      "result"
    ];
  };
}