# SPDX-FileCopyrightText: {{ cookiecutter.initial_year }} {{ cookiecutter.full_name }} <{{ cookiecutter.email }}>
# SPDX-License-Identifier: {{ cookiecutter.license_spdx }}

"""
Execute {{ cookiecutter.package_name }}.main().

Provided so that one can execute it with `python <souces-directory>`.
"""

import {{ cookiecutter.package_name }}.main
{{ cookiecutter.package_name }}.main.main()
