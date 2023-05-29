# SPDX-FileCopyrightText: {{ cookiecutter.initial_year }} {{ cookiecutter.full_name }} <{{ cookiecutter.email }}>
# SPDX-License-Identifier: {{ cookiecutter.license_spdx }}

"""Test main module of {{cookiecutter.package_name}}."""

import _pytest.capture

import {{ cookiecutter.package_name }}.main


def test_main(capsys: _pytest.capture.CaptureFixture[str]) -> None:
    """Test that main() prints 'Hello world!'."""
    {{ cookiecutter.package_name }}.main.main()
    assert capsys.readouterr().out == "Hello world!\n"
