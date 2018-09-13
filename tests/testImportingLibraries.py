import os
import importlib
import unittest
import lsst.utils.tests


class TestImportingLibraries(unittest.TestCase):

    def testImporting(self):
        subsystems = os.getenv('SUBSYSTEMS')
        if subsystems is None:
            # Remove catchuparchiver from unit test, as this will not build currently.
            # subsystems = ['archiver', 'camera', 'catchuparchiver', 'dome', 
            subsystems = ['archiver', 'camera', 'dome', 
                          'domeADB', 'domeAPS', 'domeLouvers', 'domeLWS',
                          'domeMONCS', 'domeTHCS', 'hexapod', 'm1m3', 'm2ms',
                          'MTMount', 'ocs', 'processingcluster',
                          'rotator', 'scheduler', 'tcs']
        else:
            subsystems = subsystems.split(' ')
        print('Testing subsystems: %s' % (subsystems))

        for subsys in subsystems:
            # If the library was not copied to the correct location, 
            # then this will trigger an exception and unit test will fail.
            libname = 'SALPY_%s' % (subsys)
            mylib = importlib.import_module(libname)


class TestMemory(lsst.utils.tests.MemoryTestCase):
    pass


def setup_module(module):
    lsst.utils.tests.init()


if __name__ == "__main__":
    lsst.utils.tests.init()
    unittest.main()
