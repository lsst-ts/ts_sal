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

__all__ = ["make_salpy_lib"]

import glob
import os
import shutil
import subprocess

import lsst.ts.xml
from . import utils


def get_env_dir(name, err_msg):
    path = os.environ.get(name)
    if path is None:
        raise RuntimeError(err_msg)
    if not os.path.isdir(path):
        raise RuntimeError(f"{path} is not a directory")
    print(f"${name} = {path}")
    return path


class MakeSalpyLib:
    """Make the SALPY library for a specified SAL component.

    Parameters
    ----------
    sal_name : `str`
        Name of SAL component, e.g. ``"ScriptQueue"``.
    """
    def __init__(self, sal_name):
        self.sal_name = sal_name
        self.sal_dir = utils.get_pkg_root()
        self.xml_dir = lsst.ts.xml.get_pkg_root()
        self.sal_work_dir = get_env_dir("SAL_WORK_DIR", "$SAL_WORK_DIR must be defined")
        self.ld_lib_path_name = "LD_LIBRARY_PATH"
        self.initial_ld_lib_path = os.environ[self.ld_lib_path_name]
        self.lib_names = dict(
            cpp=f"libsacpp_{sal_name}_types.so",
            python=f"SALPY_{sal_name}.so")
        self.src_lib_paths = dict(
            cpp=os.path.join(self.sal_work_dir, self.sal_name, "cpp", self.lib_names["cpp"]),
            python=os.path.join(self.sal_work_dir, self.sal_name, "cpp", "src", self.lib_names["python"]))
        self.dest_lib_paths = dict(
            cpp=os.path.join(self.sal_dir, "lib", self.lib_names["cpp"]),
            python=os.path.join(self.sal_dir, "python", self.lib_names["python"]))

    def copy_xml_files(self):
        interfaces_dir = os.path.join(self.xml_dir, "sal_interfaces")
        std_xml_paths = [os.path.join(interfaces_dir, f"{n}.xml") for n in ("SALGenerics", "SALSubsystems")]
        sal_xml_paths = glob.glob(os.path.join(interfaces_dir, self.sal_name, "*.xml"))
        if not sal_xml_paths:
            raise RuntimeError(f"Could not find any XML files for SAL component {self.sal_name}")
        for xmlpath in std_xml_paths + sal_xml_paths:
            shutil.copy(xmlpath, self.sal_work_dir)

    def delete_files(self, keep_most=False):
        """Delete unwanted files for this SAL component.

        Parameters
        ----------
        keep_most : `bool` (optional)
            If True then keep most generated files, e.g.
            the files in {sal_name} and each {sal_name}_{topic_name}
            directory.
        """
        xmlfiles = glob.glob(os.path.join(self.sal_work_dir, "*.xml"))
        for f in xmlfiles:
            os.remove(f)

        for subdir in ("include", "lib"):
            print(f"Remove subdir {subdir}")
            shutil.rmtree(os.path.join(self.sal_work_dir, subdir), ignore_errors=True)

        if not keep_most:
            print(f"Removing demos")
            sal_name_dirs = glob.glob(os.path.join(self.sal_work_dir, f"{self.sal_name}*"))
            for name_dir in sal_name_dirs:
                print(f"Remove {name_dir}")
                shutil.rmtree(name_dir, ignore_errors=True)

    def make_libraries(self, demo):
        """Make SALPY libraries and, optionally, topic readers and writers.

        Parameters
        ----------
        demo : `bool`
            If True build a demo reader and writer for each topic.
        """
        try:
            os.environ[self.ld_lib_path_name] = f"{self.sal_work_dir}/lib:{self.initial_ld_lib_path}"
            demo_suffix = "" if demo else " fastest"
            for command in ("validate", f"sal cpp{demo_suffix}", f"sal python{demo_suffix}"):
                cmd_args = ["salgenerator", self.sal_name] + command.split()
                print(f"***** {' '.join(cmd_args)}")
                subprocess.run(cmd_args, check=True, cwd=self.sal_work_dir)
        finally:
            os.environ[self.ld_lib_path_name] = self.initial_ld_lib_path

    def move_libraries(self):
        """Move the SALPY libraries to their final destination."""
        for path in self.src_lib_paths.values():
            if not os.path.isfile(path):
                raise RuntimeError(f"{path} not generated")
        for name in self.src_lib_paths.keys():
            src_path = self.src_lib_paths[name]
            dest_path = self.dest_lib_paths[name]
            if os.path.exists(dest_path):
                os.remove(dest_path)
            shutil.copy(src_path, dest_path)

    def run(self, demo=False):
        """Make a SALPY library for the given component.

        Parameters
        ----------
        demo : `bool`
            If True build and keep a demo reader and writer for each topic.
            This also keeps most of the generated files.
        """
        print(f"* Make SALPY_{self.sal_name} libraries ***")

        print(f"*** Cleanup old {self.sal_name} files ***")
        self.delete_files()

        print(f"*** Copy {self.sal_name} XML files ***")
        self.copy_xml_files()

        print(f"*** Validate and generate {self.sal_name} libraries ***")
        self.make_libraries(demo=demo)

        print(f"*** Move {self.sal_name} libraries into place ***")
        self.move_libraries()

        print(f"*** Final cleanup ***")
        self.delete_files(keep_most=demo)

        print(f"*** Done generating SALPY_{self.sal_name} ***")


def make_salpy_lib(sal_name, demo=False):
    """Make the SALPY library for a specified SAL component.

    Parameters
    ----------
    sal_name : `str`
        Name of SAL component, e.g. ``"ScriptQueue"``.
    demo : `bool`
        If True build and keep a demo reader and writer for each topic.
        This also keeps most of the generated files.
    """
    maker = MakeSalpyLib(sal_name)
    maker.run(demo=demo)
