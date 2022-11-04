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

__all__ = ["make_idl_file"]

import glob
import os
import shutil
import subprocess

from lsst.ts import idl
import lsst.ts.xml
from . import utils


class MakeIdlFile:
    """Make the IDL file for a specified SAL component.

    Parameters
    ----------
    name : `str`
        Name of SAL component, e.g. ``"ScriptQueue"``.
    keep_all : `bool`
        Keep intermediate files generated in ``SAL_WORK_DIR``?
    """

    def __init__(self, name, keep_all):
        self.name = name
        self.keep_all = keep_all
        self.xml_dir = lsst.ts.xml.get_data_dir()
        self.sal_work_dir = utils.get_env_dir(
            "SAL_WORK_DIR", "$SAL_WORK_DIR must be defined"
        )
        idl_file_name = f"sal_revCoded_{self.name}.idl"
        self.idl_file_from_path = (
            self.sal_work_dir / "idl-templates" / "validated" / "sal" / idl_file_name
        )
        self.idl_file_to_path = idl.get_idl_dir() / idl_file_name

    def delete_files(self):
        """Delete unwanted files for this SAL component."""
        xmlfiles = glob.glob(os.path.join(self.sal_work_dir, "*.xml"))
        for f in xmlfiles:
            os.remove(f)

        for path in glob.glob(os.path.join(self.sal_work_dir, f"{self.name}*")):
            print(f"Remove {path}")
            shutil.rmtree(path, ignore_errors=True)
        for subdir in ["idl-templates", "html", "include", "sql"]:
            path = os.path.join(self.sal_work_dir, subdir)
            print(f"Remove {path}")
            shutil.rmtree(path, ignore_errors=True)

    def make_idl_file(self):
        """Make the IDL file."""
        for command in ["validate", "sal idl"]:
            cmd_args = ["salgenerator", self.name] + command.split()
            print(f"***** {' '.join(cmd_args)}")
            subprocess.run(cmd_args, check=True, cwd=self.sal_work_dir)

    def run(self):
        """Make the IDL file and move it to the idl directory."""
        print(f"* Make {self.name} IDL file *")

        print(f"*** Validate and generate {self.name} libraries ***")
        self.make_idl_file()

        print(f"*** Copy {self.idl_file_from_path} to {self.idl_file_to_path} ***")
        shutil.copy(self.idl_file_from_path, self.idl_file_to_path)

        if not self.keep_all:
            print(f"*** Cleanup {self.name} files ***")
            self.delete_files()

        print(f"*** Done generating {self.name} IDL file ***")


def make_idl_file(name, keep_all):
    """Make the IDL file for a specified SAL component.

    Parameters
    ----------
    name : `str`
        Name of SAL component, e.g. ``"ScriptQueue"``.
    keep_all : `bool`
        Keep all generated files?
    """
    maker = MakeIdlFile(name=name, keep_all=keep_all)
    maker.run()
