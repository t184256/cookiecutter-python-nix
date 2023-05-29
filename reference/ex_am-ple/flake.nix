{
  description = "TODO: fill in";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  #inputs.nixpkgs.url = "github:NixOS/nixpkgs";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        python3Packages = pkgs.python3Packages;
        deps = pyPackages: with pyPackages; [
          # TODO: list python dependencies
        ];
        tools = pkgs: pyPackages: (with pyPackages; [
          pytest pytestCheckHook
          coverage pytest-cov
          pylama pyflakes pycodestyle pydocstyle mypy mccabe pylint
          eradicate vulture
        ]);

        ex-am-ple = python3Packages.buildPythonPackage {
          pname = "ex-am-ple";
          version = "0.0.1";
          src = ./.;
          format = "pyproject";
          propagatedBuildInputs = deps python3Packages;
          nativeBuildInputs = [ python3Packages.setuptools ];
          checkInputs = tools pkgs python3Packages;
        };
        app = flake-utils.lib.mkApp { drv = ex-am-ple; };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [(python3Packages.python.withPackages deps)];
          nativeBuildInputs = tools pkgs python3Packages;
          shellHook = ''
            export PYTHONDEVMODE=1 PYTHONWARNINGS=error PYTHONTRACEMALLOC=1
          '';
        };
        packages.ex-am-ple = ex-am-ple;
        packages.default = ex-am-ple;
        apps.ex-am-ple = app;
        apps.default = app;
      }
    );
}
