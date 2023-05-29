# SPDX-FileCopyrightText: {{ cookiecutter.initial_year }} {{ cookiecutter.full_name }} <{{ cookiecutter.email }}>
# SPDX-License-Identifier: {{ cookiecutter.license_spdx }}

"""Main module of {{ cookiecutter.package_name }}."""


def main() -> None:
    """
    Print a greeting.

    >>> main()
    Hello world!
    """
    print('Hello world!')


if __name__ == '__main__':
    main()
