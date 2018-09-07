import os
import importlib
import unittest
import lsst.utils.tests


class TestImportingLibraries(unittest.TestCase):

    def testImporting(self):
        subsystems = os.getenv('SUBSYSTEMS')
        if subsystems is None:
            subsystems = ['archiver', 'camera', 'catchuparchiver', 'dome', 
                          'domeADB', 'domeAPS', 'domeLouvers', 'domeLWS',
                          'domeMONCS', 'domeTHCS', 'hexapod', 'm1m3', 'm2ms',
                          'MTMount', 'ocs', 'processingcluster',
                          'rotator', 'scheduler', 'tcs']
        else:
            subsystems = subsystems.split(' ')
        print('Testing subsystems: %s' % (subsystems))

        for subsys in subsystems:
            try:
                libname = 'SALPY_%s' % (subsys)
                mylib = importlib.import_module(libname)
            except ImportError:
                self.fail("Could not import %s library" % (libname))
            except ModuleNotFoundError:
                self.fail("Could not find %s library" % (libname))

class TestMemory(lsst.utils.tests.MemoryTestCase):
    pass


def setup_module(module):
    lsst.utils.tests.init()


if __name__ == "__main__":
    lsst.utils.tests.init()
    unittest.main()
