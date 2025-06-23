{
  description = "Python environment with OpenSSL support";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.openssl
            pkgs.python3
            # Additional packages if needed:
            # pkgs.python3Packages.pip
            # pkgs.python3Packages.virtualenv
          ];

          # Ensure Python can find OpenSSL libraries
          LD_LIBRARY_PATH = "${pkgs.openssl.out}/lib";

          # Some Python packages need these environment variables
          OPENSSL_DIR = "${pkgs.openssl.out}";
          OPENSSL_LIBRARIES = "${pkgs.openssl.out}/lib";
        };
      }
    );
}
