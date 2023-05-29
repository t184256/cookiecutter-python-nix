{
  description = "{{ cookiecutter.description }}";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  #inputs.nixpkgs.url = "github:NixOS/nixpkgs";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        python3Packages = pkgs.python3Packages;

        pylama = python3Packages.pylama.overridePythonAttrs (_: {
          # https://github.com/klen/pylama/issues/232
          patches = [
            (pkgs.fetchpatch {
              url = "https://github.com/klen/pylama/pull/233.patch";
              hash = "sha256-jaVG/vuhkPiHEL+28Pf1VuClBVlFtlzDohT0mZasL04=";
            })
          ];
        });

        deps = pyPackages: with pyPackages; [
          # TODO: list python dependencies
        ];
        tools = pkgs: pyPackages: (with pyPackages; [
          pytest pytestCheckHook
          coverage pytest-cov
          mypy pytest-mypy
          pylama pyflakes pycodestyle pydocstyle mccabe pylint
          eradicate
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
{%- if cookiecutter.kind == 'application' %}
        app = flake-utils.lib.mkApp { drv = {{ cookiecutter.nix_name }}; };
{%- endif %}
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
{%- if cookiecutter.kind == 'application' %}
        apps.{{ cookiecutter.nix_name }} = app;
        apps.default = app;
{%- endif %}
      }
    );
}
