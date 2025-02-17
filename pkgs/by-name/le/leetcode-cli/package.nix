{
  lib,
  fetchCrate,
  rustPlatform,
  pkg-config,
  installShellFiles,
  openssl,
  dbus,
  sqlite,
  stdenv,
  darwin,
  testers,
  leetcode-cli,
}:

rustPlatform.buildRustPackage rec {
  pname = "leetcode-cli";
  version = "0.4.5";

  src = fetchCrate {
    inherit pname version;
    hash = "sha256-Jc0akHj2DHbkF7sjslOwdeI1piW2gnhoalBz18lpQdQ=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-rr/8rbgjGr1npkimJK8rpZcsRFP0ACx+a1x0ITI71G0=";

  nativeBuildInputs = [
    pkg-config
    installShellFiles
  ];

  buildInputs =
    [
      openssl
      dbus
      sqlite
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      darwin.apple_sdk.frameworks.Security
      darwin.apple_sdk.frameworks.SystemConfiguration
    ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd leetcode \
      --bash <($out/bin/leetcode completions bash) \
      --fish <($out/bin/leetcode completions fish) \
      --zsh <($out/bin/leetcode completions zsh)
  '';

  passthru.tests = testers.testVersion {
    package = leetcode-cli;
    command = "leetcode -V";
    version = "leetcode ${version}";
  };

  meta = with lib; {
    description = "May the code be with you 👻";
    longDescription = "Use leetcode.com in command line";
    homepage = "https://github.com/clearloop/leetcode-cli";
    license = licenses.mit;
    maintainers = with maintainers; [ congee ];
    mainProgram = "leetcode";
  };
}
