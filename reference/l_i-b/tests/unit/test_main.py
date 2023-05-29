# SPDX-FileCopyrightText: 2023 Alexander Sosedkin <monk@unboiled.info>
# SPDX-License-Identifier: CC0-1.0

"""Test main module of l_i_b."""

import _pytest.capture

import l_i_b.main


def test_main(capsys: _pytest.capture.CaptureFixture[str]) -> None:
    """Test that main() prints 'Hello world!'."""
    l_i_b.main.main()
    assert capsys.readouterr().out == 'Hello world!\n'
