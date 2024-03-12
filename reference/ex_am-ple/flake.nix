{
  description = "TODO: fill in";

  outputs = { self, nixpkgs, flake-utils }@inputs:
    let
      pyDeps = pyPackages: with pyPackages; [
        # TODO: list python dependencies
      ];
      pyTestDeps = pyPackages: with pyPackages; [
        pytest pytestCheckHook
        coverage pytest-cov
      ];
      pyTools = pyPackages: with pyPackages; [ mypy ];

      tools = pkgs: with pkgs; [
        pre-commit
        ruff
        codespell
        actionlint
        python3Packages.pre-commit-hooks
      ];

      ex-am-ple-package = {pkgs, python3Packages}:
        python3Packages.buildPythonPackage {
          pname = "ex-am-ple";
          version = "0.0.1";
          src = ./.;
          disabled = python3Packages.pythonOlder "3.12";
          format = "pyproject";
          build-system = [ python3Packages.setuptools ];
          propagatedBuildInputs = pyDeps python3Packages;
          checkInputs = pyTestDeps python3Packages;
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
            buildInputs = [(defaultPython3Packages.python.withPackages (
              pyPkgs: pyDeps pyPkgs ++ pyTestDeps pyPkgs ++ pyTools pyPkgs
            ))];
            nativeBuildInputs = [(pkgs.buildEnv {
              name = "ex-am-ple-tools-env";
              pathsToLink = [ "/bin" ];
              paths = tools pkgs;
            })];
            shellHook = ''
              [ -e .git/hooks/pre-commit ] || \
                echo "suggestion: pre-commit install --install-hooks" >&2
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
