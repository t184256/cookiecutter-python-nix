{
  description = "TODO: fill in";

  outputs = { self, nixpkgs, flake-utils }:
    let
      deps = pyPackages: with pyPackages; [
        # TODO: list python dependencies
      ];
      tools = pkgs: pyPackages: (with pyPackages; [
        pytest pytestCheckHook
        coverage pytest-cov
        mypy pytest-mypy
        yapf
      ] ++ [pkgs.ruff]);

      l-i-b-package = {pkgs, python3Packages}:
        python3Packages.buildPythonPackage {
          pname = "l-i-b";
          version = "0.0.1";
          src = ./.;
          format = "pyproject";
          propagatedBuildInputs = deps python3Packages;
          nativeBuildInputs = [ python3Packages.setuptools ];
          checkInputs = tools pkgs python3Packages;
        };

      overlay = final: prev: {
        pythonPackagesExtensions =
          prev.pythonPackagesExtensions ++ [(pyFinal: pyPrev: {
            l-i-b = final.callPackage l-i-b-package {
              python3Packages = pyFinal;
            };
          })];
      };
    in
      flake-utils.lib.eachDefaultSystem (system:
        let
          pkgs = import nixpkgs { inherit system; overlays = [ overlay ]; };
          defaultPython3Packages = pkgs.python310Packages;  # force 3.10

          l-i-b = pkgs.callPackage l-i-b-package {
            python3Packages = defaultPython3Packages;
          };
        in
        {
          devShells.default = pkgs.mkShell {
            buildInputs = [(defaultPython3Packages.python.withPackages deps)];
            nativeBuildInputs = tools pkgs defaultPython3Packages;
            shellHook = ''
              export PYTHONASYNCIODEBUG=1 PYTHONWARNINGS=error
            '';
          };
          packages.l-i-b = l-i-b;
          packages.default = l-i-b;
        }
    ) // { overlays.default = overlay; };
}
