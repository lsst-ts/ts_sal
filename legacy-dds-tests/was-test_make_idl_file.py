# This file is part of ts_idl.
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

import os
import unittest
import tempfile
import contextlib

from lsst.ts import idl
from lsst.ts.sal.make_idl_file import make_idl_file


class TestMakeIdlFile(unittest.TestCase):
    def setUp(self) -> None:

        self.component = "Test"
        self.idl_file_name = f"sal_revCoded_{self.component}.idl"
        self.idl_file_path = idl.get_idl_dir() / self.idl_file_name

        self.idl_file_backup_path = None
        self.temporary_directory = None

        if os.path.exists(self.idl_file_path):
            self.temporary_directory = tempfile.TemporaryDirectory()
            self.idl_file_backup_path = os.path.join(
                self.temporary_directory.name,
                self.idl_file_name,
            )

            os.rename(
                self.idl_file_path,
                self.idl_file_backup_path,
            )

    def tearDown(self) -> None:
        if self.idl_file_backup_path is not None:
            os.rename(
                self.idl_file_backup_path,
                self.idl_file_path,
            )

    def test_make_idl_file(self):

        make_idl_file(
            name=self.component,
            keep_all=False,
        )

        assert os.path.exists(self.idl_file_path)
