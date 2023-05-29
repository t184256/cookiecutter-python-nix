{
  description = "{{ cookiecutter.description }}";

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

        {{ cookiecutter.nix_name }} = python3Packages.buildPythonPackage {
          pname = "{{ cookiecutter.nix_name }}";
          version = "{{ cookiecutter.version }}";
          src = ./.;
          format = "pyproject";
          propagatedBuildInputs = deps python3Packages;
          nativeBuildInputs = [ python3Packages.setuptools ];
          checkInputs = tools pkgs python3Packages;
        };
        app = flake-utils.lib.mkApp { drv = {{ cookiecutter.nix_name }}; };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [(python3Packages.python.withPackages deps)];
          nativeBuildInputs = tools pkgs python3Packages;
          shellHook = ''
            export PYTHONDEVMODE=1 PYTHONWARNINGS=error PYTHONTRACEMALLOC=1
          '';
        };
        packages.{{ cookiecutter.nix_name }} = {{ cookiecutter.nix_name }};
        packages.default = {{ cookiecutter.nix_name }};
        apps.{{ cookiecutter.nix_name }} = app;
        apps.default = app;
      }
    );
}
