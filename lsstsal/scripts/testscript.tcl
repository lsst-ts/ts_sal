#!/usr/bin/env tclsh

proc printformdata { } {
global env FormData
   foreach i [lsort [array names env]] {
       puts stdout "Env $i = $env($i)<BR>"
  }
   foreach i [lsort [array names FormData]] {
       puts stdout "Form $i = $FormData($i)<BR>"
  }
}


source /usr/local/scripts/tcl/GetPostedData.tcl

GetPostedData
puts stdout "Content-type: text/html\n\n"
puts stdout "<HTML><HEAD></HEAD><BODY>"
printformdata
puts stdout "</BODY></HTML>"
