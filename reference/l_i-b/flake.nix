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

      l-i-b-package = {pkgs, python3Packages}:
        python3Packages.buildPythonPackage {
          pname = "l-i-b";
          version = "0.0.1";
          src = ./.;
          disabled = python3Packages.pythonOlder "3.12";
          format = "pyproject";
          build-system = [ python3Packages.setuptools ];
          propagatedBuildInputs = pyDeps python3Packages;
          checkInputs = pyTestDeps python3Packages;
        };

      overlay = final: prev: {
        pythonPackagesExtensions =
          prev.pythonPackagesExtensions ++ [(pyFinal: pyPrev: {
            l-i-b = final.callPackage l-i-b-package {
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

          l-i-b = defaultPython3Packages.l-i-b;
        in
        {
          devShells.default = pkgs.mkShell {
            buildInputs = [(defaultPython3Packages.python.withPackages (
              pyPkgs: pyDeps pyPkgs ++ pyTestDeps pyPkgs ++ pyTools pyPkgs
            ))];
            nativeBuildInputs = [(pkgs.buildEnv {
              name = "l-i-b-tools-env";
              pathsToLink = [ "/bin" ];
              paths = tools pkgs;
            })];
            shellHook = ''
              [ -e .git/hooks/pre-commit ] || \
                echo "suggestion: pre-commit install --install-hooks" >&2
              export PYTHONASYNCIODEBUG=1 PYTHONWARNINGS=error
            '';
          };
          packages.l-i-b = l-i-b;
          packages.default = l-i-b;
        }
    ) // { overlays.default = overlay; };
}
