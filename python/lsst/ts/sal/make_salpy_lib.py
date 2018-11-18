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


def get_env_dir(name, err_msg):
    path = os.environ.get(name)
    if path is None:
        raise RuntimeError(err_msg)
    if not os.path.isdir(path):
        raise RuntimeError(f"{path} is not a directory")
    print(f"${name} = {path}")
    return path


def make_salpy_lib(sal_name):
    """Make a SALPY library for the given component"""
    print(f"*** Make SALPY_{sal_name} library ***")
    sal_dir = get_env_dir("TS_SAL_DIR", "ts_sal not setup")
    xml_dir = get_env_dir("TS_XML_DIR", "ts_xml not setup")
    sal_work_dir = get_env_dir("SAL_WORK_DIR", "$SAL_WORK_DIR must be defined")
    ld_lib_path_name = "LD_LIBRARY_PATH"
    initial_ld_lib_path = os.environ[ld_lib_path_name]

    try:
        os.environ[ld_lib_path_name] = f"{sal_work_dir}/lib:{initial_ld_lib_path}"
        lib_names = dict(
            cpp=f"libsacpp_{sal_name}_types.so",
            python=f"SALPY_{sal_name}.so")
        src_lib_paths = dict(
            cpp=os.path.join(sal_work_dir, sal_name, "cpp", lib_names["cpp"]),
            python=os.path.join(sal_work_dir, sal_name, "cpp", "src", lib_names["python"]))
        dest_lib_paths = dict(
            cpp=os.path.join(sal_dir, "lib", lib_names["cpp"]),
            python=os.path.join(sal_dir, "python", lib_names["python"]))

        for path in src_lib_paths.values():
            if os.path.isfile(path):
                print(f"Remove {path}")
                os.remove(path)

        print(f"*** Copy {sal_name} XML files ***")
        interfaces_dir = os.path.join(xml_dir, "sal_interfaces")
        std_xml_paths = [os.path.join(interfaces_dir, f"{n}.xml") for n in ("SALGenerics", "SALSubsystems")]
        sal_xml_paths = glob.glob(os.path.join(interfaces_dir, sal_name, "*.xml"))
        if not sal_xml_paths:
            raise RuntimeError(f"Could not find any XML files for SAL component {sal_name}")
        for xmlpath in std_xml_paths + sal_xml_paths:
            shutil.copy(xmlpath, sal_work_dir)

        print(f"*** Validate and generate {sal_name} libraries ***")
        for command in ("validate", "html", "sal cpp", "sal python"):
            full_cmd = f"salgenerator {sal_name} {command}"
            print(full_cmd)
            subprocess.run(full_cmd, check=True, cwd=sal_work_dir, shell=True)

        print(f"*** Move {sal_name} libraries into place ***")
        for path in src_lib_paths.values():
            if not os.path.isfile(path):
                raise RuntimeError(f"{path} not generated")
        for name in src_lib_paths.keys():
            src_path = src_lib_paths[name]
            dest_path = dest_lib_paths[name]
            if os.path.exists(dest_path):
                os.remove(dest_path)
            os.rename(src_path, dest_path)

    finally:
        print(f"*** Cleanup {sal_name} files ***")
        os.environ[ld_lib_path_name] = initial_ld_lib_path
        xmlfiles = glob.glob(os.path.join(sal_work_dir, "*.xml"))
        for f in xmlfiles:
            os.remove(f)

        sal_name_dirs = glob.glob(os.path.join(sal_work_dir, f"{sal_name}*"))
        for name_dir in sal_name_dirs:
            shutil.rmtree(os.path.join(name_dir), ignore_errors=True)

        for subdir in ("html", "idl-templates", "include", "lib", "sql"):
            shutil.rmtree(os.path.join(sal_work_dir, subdir), ignore_errors=True)
        print(f"*** Done generating SALPY_{sal_name} ***")
