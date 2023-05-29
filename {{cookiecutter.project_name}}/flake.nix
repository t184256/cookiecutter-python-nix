{
  description = "{{ cookiecutter.description }}";

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

      {{ cookiecutter.nix_name }}-package = {pkgs, python3Packages}:
        python3Packages.buildPythonPackage {
          pname = "{{ cookiecutter.nix_name }}";
          version = "{{ cookiecutter.version }}";
          src = ./.;
          format = "pyproject";
          propagatedBuildInputs = deps python3Packages;
          nativeBuildInputs = [ python3Packages.setuptools ];
          checkInputs = tools pkgs python3Packages;
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
    in
      flake-utils.lib.eachDefaultSystem (system:
        let
          pkgs = import nixpkgs { inherit system; overlays = [ overlay ]; };
          defaultPython3Packages = pkgs.python{{ cookiecutter.min_python.replace('.', '') }}Packages;  # force {{ cookiecutter.min_python }}

          {{ cookiecutter.nix_name }} = pkgs.callPackage {{ cookiecutter.nix_name }}-package {
            python3Packages = defaultPython3Packages;
          };
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
            buildInputs = [(defaultPython3Packages.python.withPackages deps)];
            nativeBuildInputs = tools pkgs defaultPython3Packages;
            shellHook = ''
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
