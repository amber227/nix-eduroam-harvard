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
        pythonWithDeps = pkgs.python3.withPackages (ps: [
          ps.dbus-python
          # ps.websso-backends
          # Add other Python packages here if needed
        ]);
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.openssl
            pkgs.openssl.bin
            pythonWithDeps
            pkgs.coreutils-full
            pkgs.firefox
            pkgs.xdg-utils
            # Additional packages if needed:
            # pkgs.python3Packages.pip
            # pkgs.python3Packages.virtualenv
          ];

          # Ensure Python can find OpenSSL libraries
          LD_LIBRARY_PATH = "${pkgs.openssl.out}/lib";

          # Some Python packages need these environment variables
          OPENSSL_DIR = "${pkgs.openssl.out}";
          OPENSSL_LIBRARIES = "${pkgs.openssl.out}/lib";
          # shellHook = ''
          #   export OPENSSL_BIN="${pkgs.openssl.bin}/bin/openssl"
          #   export PATH="${pkgs.openssl.bin}/bin:$PATH"
          #   export LD_LIBRARY_PATH="${pkgs.openssl.out}/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
          # '';
          # shellHook = ''
          #   # Directly patch the Python package's openssl detection
          #   export SSLENGINE_OPENSSL_PATH="${pkgs.openssl.bin}/bin/openssl"
          # '';
          shellHook = ''
            # # Create virtual environment if it doesn't exist
            # if [ ! -d venv ]; then
            #   python -m venv venv
            #   source venv/bin/activate
            #   pip install websso-backends
            # else
            #   source venv/bin/activate
            # fi

            mkdir -p /usr/bin
            sudo ln -sf ${pkgs.openssl.bin}/bin/openssl /usr/bin/openssl
            sudo ln -sf $(which xdg-open) /usr/bin/xdg-open

            # 1. Configure browser selection
            export BROWSER="${pkgs.firefox}/bin/firefox"
            export DEFAULT_BROWSER="$BROWSER

            # 2. SSL configuration for websso_backends
            export SSL_CERT_FILE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
            export OPENSSL_BIN="${pkgs.openssl.bin}/bin/openssl"
            export PATH="${pkgs.openssl.bin}/bin:$PATH"

            # 3. Library paths
            export LD_LIBRARY_PATH="${pkgs.openssl.out}/lib:${pkgs.dbus.lib}/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

            # 4. Verify configuration
            echo "Configured browser: $BROWSER"
            echo "OpenSSL available at: $(which openssl)"
          '';
          # shellHook = ''
          #   # Create symlinks to where sslengine looks for openssl
          #   mkdir -p $out/bin
          #   ln -sf ${pkgs.openssl.bin}/bin/openssl $out/bin/openssl
          #   export PATH="$out/bin:$PATH"

          #   # Verify openssl is found
          #   if ! command -v openssl >/dev/null; then
          #     echo "ERROR: openssl still not found in PATH"
          #     exit 1
          #   fi
          # '';
        };
      }
    );
}
