{ pkgs }:

let
  imgLink = "https://w.wallhaven.cc/full/ey/wallhaven-ey261k.jpg";

  image = pkgs.fetchurl {
    url = imgLink;
    sha256 = "9ec054b1a0ac751a5331c084931b76a594d1ed9cce982f3ff7e069be37d0f664";
  };
in
pkgs.stdenv.mkDerivation {
  name = "sddm-theme";
  src = pkgs.fetchFromGitHub {
    owner = "MarianArlt";
    repo = "sddm-sugar-dark";
    rev = "ceb2c455663429be03ba62d9f898c571650ef7fe";
    sha256 = "0153z1kylbhc9d12nxy9vpn0spxgrhgy36wy37pk6ysq7akaqlvy";
  };
  installPhase = ''
    mkdir -p $out
    cp -R ./* $out/
    cd $out/
    rm Background.jpg
    cp -r ${image} $out/Background.jpg
   '';
}
