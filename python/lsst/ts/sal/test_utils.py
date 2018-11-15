# This file is part of salobj.
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

__all__ = ["index_generator", "SalInfo", "set_random_lsst_dds_domain"]

import os
import random
import socket
import string
import time

import numpy as np


MAX_SAL_INDEX = (2 << 30) - 1


def index_generator(imin=1, imax=MAX_SAL_INDEX):
    """Sequential index generator, e.g. for SAL components.

    Returns values min, min+1, ..., max, min, min + 1, ...

    Parameters
    ----------
    imin : `int`
        Minimum index (inclusive).
    imax : `int`
        Maximum index (inclusive).

    Raises
    ------
    ValueError
        If imin >= imax
    """
    if imax <= imin:
        raise ValueError(f"imin={imin} must be less than imax={imax}")

    # define an inner generator and return that
    # in order to get immediate argument checking
    def index_impl():
        index = imin - 1
        while True:
            index += 1
            if index > imax:
                index = imin

            yield index

    return index_impl()


class SalInfo:
    """SALPY information for a component, including the
    SALPY library, component name, component index and SALPY manager

    Parameters
    ----------
    sallib : `module`
        SALPY library for a SAL component
    index : `int` or `None`
        SAL component index, or 0 or None if the component is not indexed.
    """
    def __init__(self, sallib, index=None):
        self.lib = sallib
        self.name = sallib.componentName[4:]  # lop off leading SAL_
        if sallib.componentIsMultiple:
            if index is None:
                raise RuntimeError(f"Component {self.name} is indexed, so index cannot be None")
        else:
            if index not in (0, None):
                raise RuntimeError(f"Component {self.name} is not indexed so index={index} must be None or 0")
            index = 0
        self.index = index
        Manager = getattr(self.lib, "SAL_" + self.name)
        self.manager = Manager(self.index)
        self._AckType = getattr(self.lib, self.name + "_ackcmdC")

    def __str__(self):
        return f"SalInfo({self.name}, {self.index})"

    @property
    def AckType(self):
        """The class of command acknowledgement.

        It is contructed with the following parameters
        and has these fields:

        ack : `int`
            Acknowledgement code; one of the ``self.lib.SAL__CMD_``
            constants, such as ``self.lib.SAL__CMD_COMPLETE``.
        error : `int`
            Error code; 0 for no error.
        result : `str`
            Explanatory message, or "" for no message.
        """
        return self._AckType

    def makeAck(self, ack, error=0, result=""):
        """Make an AckType object from keyword arguments.
        """
        data = self.AckType()
        data.ack = ack
        data.error = error
        data.result = result
        return data

    def __del__(self):
        if self.manager:
            self.manager.salShutdown()


def set_random_lsst_dds_domain():
    """Set a random value for environment variable LSST_DDS_DOMAIN

    Call this for each unit test method that uses SAL message passing,
    in order to avoid collisions with other tests. Note that pytest
    can run unit test methods in parallel.

    The set name will contain the hostname and current time
    as well as a random integer.
    """
    hostname = socket.gethostname()
    curr_time = time.time()
    random_int = random.randint(0, 999999)
    os.environ["LSST_DDS_DOMAIN"] = f"Test-{hostname}-{curr_time}-{random_int}"


class TestWrapper:
    """Wrap Test and provide access to the commands and topics.
    """
    __test__ = False  # stop pytest from warning that this is not a test

    def __init__(self, salinfo):
        self.salinfo = salinfo
        lib = salinfo.lib
        manager = salinfo.manager

        for name in manager.getCommandNames():
            topic = f"Test_command_{name}"
            assert manager.salCommand(topic) == lib.SAL__OK
            assert manager.salProcessor(topic) == lib.SAL__OK

        for name in manager.getEventNames():
            topic = f"Test_logevent_{name}"
            assert manager.salEventPub(topic) == lib.SAL__OK
            assert manager.salEventSub(topic) == lib.SAL__OK

        for name in manager.getTelemetryNames():
            topic = f"Test_{name}"
            assert manager.salTelemetryPub(topic) == lib.SAL__OK
            assert manager.salTelemetrySub(topic) == lib.SAL__OK

    @property
    def arrays_fields(self):
        """Get a tuple of the fields in an arrays struct."""
        return (
            "boolean0", "byte0", "char0", "short0",
            "int0", "long0", "longLong0", "octet0",
            "unsignedShort0", "unsignedInt0", "unsignedLong0",
            "float0", "double0")

    @property
    def scalars_fields(self):
        """Get a tuple of the fields in a scalars struct."""
        return (
            "boolean0", "byte0", "char0", "short0",
            "int0", "long0", "longLong0", "octet0",
            "unsignedShort0", "unsignedInt0", "unsignedLong0",
            "float0", "double0", "string0")

    def assert_arrays_equal(self, arrays1, arrays2):
        """Assert that two arrays data structs are equal.

        The types need not match; each struct can be command, event
        or telemetry data.
        """
        # use reversed so boolean1 is not compared first,
        # as a discrepancy there is harder to interpret
        for field in reversed(self.arrays_fields):
            if np.any(getattr(arrays1, field) != getattr(arrays2, field)):
                raise AssertionError("arrays1.{} = {} != {} = arrays2.{}".format(
                    field, getattr(arrays1, field), getattr(arrays2, field), field))

    def assert_scalars_equal(self, scalars1, scalars2):
        """Assert that two scalars data structs are equal.

        The types need not match; each struct can be command, event
        or telemetry data.
        """
        # use reversed so boolean1 is not compared first,
        # as a discrepancy there is harder to interpret
        for field in reversed(self.scalars_fields):
            if getattr(scalars1, field) != getattr(scalars2, field):
                raise AssertionError("scalars1.{} = {} != {} = scalars2.{}".format(
                    field, getattr(scalars1, field), getattr(scalars2, field), field))

    def copy_arrays(self, src_arrays, dest_arrays):
        """Copy arrays data from one struct to another.

        The types need not match; each struct can be command, event
        or telemetry data.
        """
        for field_name in self.arrays_fields:
            data = getattr(src_arrays, field_name)
            if isinstance(data, np.ndarray):
                getattr(dest_arrays, field_name)[:] = data
            else:
                setattr(dest_arrays, field_name, data)

    def copy_scalars(self, src_scalars, dest_scalars):
        """Copy scalars data from one struct to another.

        The types need not match; each struct can be command, event
        or telemetry data.
        """
        for field_name in self.scalars_fields:
            setattr(dest_scalars, field_name, getattr(src_scalars, field_name))

    def make_random_cmd_arrays(self):
        """Make random data for cmd_setArrays using numpy.random."""
        nelts = 5
        data = self.salinfo.lib.Test_command_setArraysC()
        data.boolean1[:] = np.random.choice([False, True], size=(nelts,))
        printable_chars = [c for c in string.ascii_letters + string.digits]
        data.char1 = "".join(np.random.choice(printable_chars, size=(nelts,)))
        for field_name in (
            "byte0",
            "octet0",
            "short0",
            "int0",
            "long0",
            "longLong0",
            "unsignedShort0",
            "unsignedInt0",
            "unsignedLong0",
        ):
            field = getattr(data, field_name)
            iinfo = np.iinfo(field.dtype)
            print(f"{field_name} has type {field.dtype}")
            field[:] = np.random.randint(iinfo.min, iinfo.max, size=(nelts,), dtype=field.dtype)
        data.float1[:] = np.random.uniform(-1e5, 1e5, size=(nelts,))
        data.double1[:] = np.random.uniform(-1e5, 1e5, size=(nelts,))
        return data

    def make_random_cmd_scalars(self):
        """Make random data for cmd_setScalars using numpy.random."""
        data = self.salinfo.lib.Test_command_setScalarsC()
        # also make an empty arrays struct to get dtype of int fields,
        # since that information is lost in the scalars pybind11 wrapper
        empty_arrays = self.salinfo.lib.Test_command_setScalarsC()
        data.boolean1 = np.random.choice([False, True])
        printable_chars = [c for c in string.ascii_letters + string.digits]
        data.char1 = np.random.choice(printable_chars)
        data.string1 = "".join(np.random.choice(printable_chars, size=(20,)))
        for field_name in (
            "byte0",
            "octet0",
            "short0",
            "int0",
            "long0",
            "longLong0",
            "unsignedShort0",
            "unsignedInt0",
            "unsignedLong0",
        ):
            dtype = getattr(empty_arrays, field_name).dtype
            # work around a bug in numpy 1.14.5 that causes
            # TypeError: 'numpy.dtype' object is not callable
            if dtype == np.int64:
                dtype = np.int64
            iinfo = np.iinfo(dtype)
            setattr(data, field_name, np.random.randint(iinfo.min, iinfo.max, dtype=dtype))
        data.float1 = np.random.uniform(-1e5, 1e5)
        data.double1 = np.random.uniform(-1e5, 1e5)
        return data
