{
  description = "Ghidra's SLEIGH compiler";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
  outputs =
    {
      self,
      nixpkgs,
    }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      requiredPkgs =
        pkgs: with pkgs; [
          bison
          cmake
          flex
          libbfd
          zlib
        ];
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { system = system; };
        in
        {
          default = pkgs.stdenv.mkDerivation {
            name = "sleighc";
            version = "11.3";
            src = self;
            cmakeFlags = [
              "-DCMAKE_INSTALL_LIBDIR=lib"
              "-DBUILD_DECOMPILER=ON"
            ];
            buildInputs = requiredPkgs pkgs;
          };
        }
      );
      devShells = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { system = system; };
        in
        {
          default = pkgs.mkShell {
            name = "sleighc-shell";
            buildInputs = requiredPkgs pkgs;
            cmakeFlags = [
              "-DCMAKE_INSTALL_LIBDIR=lib"
              "-DBUILD_DECOMPILER=ON"
            ];
            shellHook = ''
              export PATH=${self.packages.${system}.default}/bin:$PATH
            '';
          };
        }
      );
    };
}
