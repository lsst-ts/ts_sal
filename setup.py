from setuptools import setup, find_namespace_packages

install_requires = []
tests_require = []
dev_requires = install_requires + tests_require + ["documenteer[pipelines]"]

setup(
    name="ts_sal",
    description="Only sets up the python code written for SAL.",
    setup_requires=["setuptools_scm"],
    package_dir={"": "python"},
    packages=find_namespace_packages(where="python"),
    scripts=["bin/make_idl_files.py", "bin/make_salpy_libs.py"],
    # tests_require=tests_require,
    extras_require={"dev": dev_requires},
    license="GPL",
    project_url={
        "Bug Tracker": "https://jira.lsstcorp.org/secure/Dashboard.jspa",
        "Source Code": "https://github.com/lsst-ts/ts_idl",
    },
)
