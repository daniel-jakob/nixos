{
  # Changing "ls" to "eza"
  ls = "eza --icons --color=always --group-directories-first";
  ll = "eza -alg --icons --color=always --group-directories-first";
  la = "eza -a --icons --color=always --group-directories-first";
  l = "eza -F --icons --color=always --group-directories-first";
  "l." = "eza -a | egrep '^\.' ";

  # Change directory up
  ".." = "cd ..";
  "..." = "cd ../..";
  "...." = "cd ../../..";
}
