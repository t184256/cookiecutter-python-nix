# SPDX-FileCopyrightText: 2023 Alexander Sosedkin <monk@unboiled.info>
# SPDX-License-Identifier: CC0-1.0

"""Test main module of ex_am_ple."""

import ex_am_ple.main


def test_main(capsys):
    """Test that main() prints 'Hello world!'."""
    ex_am_ple.main.main()
    assert capsys.readouterr().out == "Hello world!\n"
