{
  description = "{{ cookiecutter.description }}";

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

      {{ cookiecutter.nix_name }}-package = {pkgs, python3Packages}:
        python3Packages.buildPythonPackage {
          pname = "{{ cookiecutter.nix_name }}";
          version = "{{ cookiecutter.version }}";
          src = ./.;
          disabled = python3Packages.pythonOlder "{{ cookiecutter.min_python }}";
          format = "pyproject";
          build-system = [ python3Packages.setuptools ];
          propagatedBuildInputs = pyDeps python3Packages;
          checkInputs = pyTestDeps python3Packages;
{%- if cookiecutter.kind == 'application' and cookiecutter.package_name != cookiecutter.project_name %}
          postInstall = "mv $out/bin/{{ cookiecutter.package_name }} $out/bin/{{ cookiecutter.project_name }}";
{%- endif %}
        };

      overlay = final: prev: {
        pythonPackagesExtensions =
          prev.pythonPackagesExtensions ++ [(pyFinal: pyPrev: {
            {{ cookiecutter.nix_name }} = final.callPackage {{ cookiecutter.nix_name }}-package {
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
          defaultPython3Packages = pkgs.python{{ cookiecutter.min_python.replace('.', '') }}Packages;  # force {{ cookiecutter.min_python }}

          {{ cookiecutter.nix_name }} = defaultPython3Packages.{{ cookiecutter.nix_name }};
{%- if cookiecutter.kind == 'application' and cookiecutter.package_name != cookiecutter.project_name %}
          app = flake-utils.lib.mkApp {
            drv = {{ cookiecutter.nix_name }};
            exePath = "/bin/{{ cookiecutter.project_name }}";
          };
{%- elif cookiecutter.kind == 'application' %}
          app = flake-utils.lib.mkApp { drv = {{ cookiecutter.nix_name }}; };
{%- endif %}
        in
        {
          devShells.default = pkgs.mkShell {
            buildInputs = [(defaultPython3Packages.python.withPackages (
              pyPkgs: pyDeps pyPkgs ++ pyTestDeps pyPkgs ++ pyTools pyPkgs
            ))];
            nativeBuildInputs = [(pkgs.buildEnv {
              name = "{{ cookiecutter.nix_name }}-tools-env";
              pathsToLink = [ "/bin" ];
              paths = tools pkgs;
            })];
            shellHook = ''
              [ -e .git/hooks/pre-commit ] || \
                echo "suggestion: pre-commit install --install-hooks" >&2
              export PYTHONASYNCIODEBUG=1 PYTHONWARNINGS=error
            '';
          };
          packages.{{ cookiecutter.nix_name }} = {{ cookiecutter.nix_name }};
          packages.default = {{ cookiecutter.nix_name }};
{%- if cookiecutter.kind == 'application' %}
          apps.{{ cookiecutter.nix_name }} = app;
          apps.default = app;
{%- endif %}
        }
    ) // { overlays.default = overlay; };
}
