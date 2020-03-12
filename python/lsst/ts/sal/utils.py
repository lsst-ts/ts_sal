# This file is part of ts_sal.
#
# Developed for the LSST Telescope and Site Systems.
# This product includes software developed by the LSST Project
# (https://www.lsst.org).
# See the COPYRIGHT file at the top-level directory of this distribution
# for details of code ownership.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

__all__ = ["get_env_dir", "get_pkg_root"]

import os
import pathlib


def get_env_dir(name, err_msg):
    """Get a directory from an environment variable.

    Parameters
    ----------
    name : `str`
        Name of environment variable, such as "SAL_WORK_DIR".
    err_msg : `str`
        Message to print if the variable does not exist.
        (A different message is printed if the variable
        does not point to an existing directory.)

    Returns
    -------
    path : `str`
        The path pointed to by environment variable ``name``.
    """
    path = os.environ.get(name)
    if path is None:
        raise RuntimeError(err_msg)
    path = pathlib.Path(path)
    if not path.is_dir():
        raise RuntimeError(f"{path} is not a directory")
    print(f"${name} = {path}")
    return path


def get_pkg_root():
    """Return the root directory of this package."""
    return pathlib.Path(__file__).resolve().parents[4]
