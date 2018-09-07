#!/usr/bin/env tclsh
set SAL_DIR $env(SAL_DIR)
set SAL_WORK_DIR $env(SAL_WORK_DIR)

source $env(SAL_DIR)/gengenericefd.tcl
set staging /data/staging/efd-base
source $env(SAL_DIR)/sal_version.tcl

updateefdtables
updateefdschema

puts stdout "Updating shared libraries"
set ltypes [glob $SAL_WORK_DIR/*/cpp/libsacpp*.so]
foreach i $ltypes {
  exec cp $i $staging/lib/.
}

set ltypes [glob $SAL_WORK_DIR/lib/libSAL*.so]
foreach i $ltypes {
  exec cp $i $staging/lib/.
}

puts stdout "Updating executables"
set btypes [glob $SAL_WORK_DIR/*/cpp/src/sacpp*writer]
foreach i $btypes {
  exec cp $i $staging/bin/.
}

puts stdout "Updating scripts"
set stypes [glob $SAL_DIR/*efd*]
foreach i $stypes {
  exec cp $i $staging/lsstsal/scripts/.
}

puts stdout "Updating SQL scripts"
exec cp -r $SAL_WORK_DIR/sql $staging/.

puts stdout "Update sources"
set stypes [glob $SAL_WORK_DIR/*/cpp/*.cpp]
foreach i $stypes {
  exec cp $i $staging/src/.
}
set stypes [glob $SAL_WORK_DIR/*/cpp/*.h]
foreach i $stypes {
  exec cp $i $staging/src/.
}
set stypes [glob $SAL_WORK_DIR/*/cpp/src/*.cpp]
foreach i $stypes {
  exec cp $i $staging/src/.
}
set stypes [glob $SAL_WORK_DIR/*/cpp/src/*.h]
foreach i $stypes {
  exec cp $i $staging/src/.
}

cd $staging/..
exec tar czf efd-base-$SALVERSION.tgz efd-base
exec ls -l efd-base-$SALVERSION.tgz


