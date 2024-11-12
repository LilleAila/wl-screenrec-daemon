{
  wl-screenrec-src,
  lib,
  rustPlatform,
  pkg-config,
  libdrm,
  ffmpeg_7,
  wayland,
}:

rustPlatform.buildRustPackage {
  pname = "wl-screenrec";
  version = "master";

  src = wl-screenrec-src;

  cargoHash = "sha256-KKNjuwGGCBabeCOw95D2MWGn7BXIoC12AGvZPLnFUoc=";

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
