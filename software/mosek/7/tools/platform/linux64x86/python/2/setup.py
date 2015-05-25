
from distutils.core import setup
from distutils.command.install import INSTALL_SCHEMES
import distutils.cmd
import platform,sys
import os,os.path


major,minor,_,_,_ = sys.version_info
if major != 2 or minor < 5:
    print "Python 2.5+ required, got %d.%d" % (major,minor)

instdir = os.path.abspath(os.path.join(__file__,'..'))
platformid = os.path.basename(os.path.abspath(os.path.join(instdir,'..','..')))

liblist = { 'linux32x86' : [ 'libmosek.so.7.1',
                             'libiomp5.so',
                             'libmosekxx7_1.so',
                             'libmosekglb.so.7.1' ],
            'linux64x86' : [ 'libmosek64.so.7.1',
                             'libiomp5.so',
                             'libmosekxx7_1.so',
                             'libmosekglb64.so.7.1' ],
            'osx64x86'   : [ 'libmosek64.7.1.dylib',
                             'libmosekglb64.7.1.dylib',
                             'libiomp5.dylib',
                             'libmosekxx7_1.dylib' ],
            'win64x86'   : [ 'mosek64_7_1.dll',
                             'mosekglb64_7_1.dll',
                             'mosekxx7_1.dll',
                             'libiomp5md.dll' ],
            'win32x86'   : [ 'mosek7_1.dll',
                             'mosekglb7_1.dll',
                             'mosekxx7_1.dll',
                             'libiomp5md.dll' ],
            }

# hack so data files are copied to the module directory
for k in INSTALL_SCHEMES.keys():
  INSTALL_SCHEMES[k]['data'] = INSTALL_SCHEMES[k]['purelib']

os.chdir(os.path.abspath(os.path.dirname(__file__)))

setup( name='Mosek',
       version      = '7.1.31',
       description  = 'Mosek/Python APIs',
       long_description = 'Interface for MOSEK',
       author       = 'Mosek ApS',
       author_email = "support@mosek.com",
       license      = "See license.pdf in the MOSEK distribution",
       url          = 'http://www.mosek.com',
       packages     = [ 'mosek', 'mosek.fusion' ],
       data_files   = [ ('mosek',[os.path.join(instdir,'../../bin',l)]) for l in liblist[platformid] ] +
                      [ ('mosek',[os.path.join(instdir,'../../../../../license.pdf')])],
       )
print("Please review the MOSEK license conditions in license.pdf")
