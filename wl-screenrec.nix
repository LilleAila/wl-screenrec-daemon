{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  libdrm,
  ffmpeg_7,
  wayland,
}:

rustPlatform.buildRustPackage rec {
  pname = "wl-screenrec";
  version = "master";

  src = fetchFromGitHub {
    owner = "russelltg";
    repo = pname;
    rev = "e5e651c644fa0ae699dcf84ba5f140b8adc607de";
    hash = "sha256-9Csy+hEUjiiYOJeT9PoIqhOhsnHp6O5V3sKpakAgPAI=";
  };

  cargoHash = "sha256-I7ABTIb/TMJKlCr0hhRzgMXnkchw+dHgrP+ktWbSkSo=";

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    wayland
    libdrm
    ffmpeg_7
  ];

  doCheck = false; # tests use host compositor, etc

  meta = with lib; {
    description = "High performance wlroots screen recording, featuring hardware encoding";
    homepage = "https://github.com/russelltg/wl-screenrec";
    license = licenses.asl20;
    platforms = platforms.linux;
    mainProgram = "wl-screenrec";
    maintainers = with maintainers; [ colemickens ];
  };
}
