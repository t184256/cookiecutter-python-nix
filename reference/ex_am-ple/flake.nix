{
  description = "TODO: fill in";

  outputs = { self, nixpkgs, flake-utils }@inputs:
    let
      deps = pyPackages: with pyPackages; [
        # TODO: list python dependencies
      ];
      tools = pkgs: pyPackages: (with pyPackages; [
        pytest pytestCheckHook
        coverage pytest-cov
        mypy pytest-mypy
      ] ++ [pkgs.ruff]);

      ex-am-ple-package = {pkgs, python3Packages}:
        python3Packages.buildPythonPackage {
          pname = "ex-am-ple";
          version = "0.0.1";
          src = ./.;
          format = "pyproject";
          propagatedBuildInputs = deps python3Packages;
          nativeBuildInputs = [ python3Packages.setuptools ];
          checkInputs = tools pkgs python3Packages;
          postInstall = "mv $out/bin/ex_am_ple $out/bin/ex_am-ple";
        };

      overlay = final: prev: {
        pythonPackagesExtensions =
          prev.pythonPackagesExtensions ++ [(pyFinal: pyPrev: {
            ex-am-ple = final.callPackage ex-am-ple-package {
              python3Packages = pyFinal;
            };
          })];
      };

      overlay-all = nixpkgs.lib.composeManyExtensions [
        overlay
      ];
    in
      flake-utils.lib.eachDefaultSystem (system:
        let
          pkgs = import nixpkgs { inherit system; overlays = [ overlay-all ]; };
          defaultPython3Packages = pkgs.python312Packages;  # force 3.12

          ex-am-ple = defaultPython3Packages.ex-am-ple;
          app = flake-utils.lib.mkApp {
            drv = ex-am-ple;
            exePath = "/bin/ex_am-ple";
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
          packages.ex-am-ple = ex-am-ple;
          packages.default = ex-am-ple;
          apps.ex-am-ple = app;
          apps.default = app;
        }
    ) // { overlays.default = overlay; };
}
