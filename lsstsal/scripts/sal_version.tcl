if  { [info exists SALVERSION] == 0 } {
  set SALVERSION [exec cat $env(TS_SAL_ROOT)/VERSION]
}
set SAL_BASE_DIR $env(SAL_DIR)/scripts
set SAL_CMAKE_DIR $SAL_BASE_DIR/code/simd/cmake

