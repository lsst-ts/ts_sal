
proc pythonprinter { fout topic } {
global TLMS TLM_ALIASES CMDS CMD_ALIASES EVTS EVENT_ALIASES
  set base [split $topic _]
  set subsys [lindex $base 0]
  set alias [getAlias $topic]
  if { $alias != "ackcmd" } {
    if { [lindex $base 1] == "command" } {
      set items $CMDS($subsys,$alias,param)
    } else {
      if { [lindex $base 1] == "logevent" } {
        set items $EVTS($subsys,$alias,param)
      } else {
        set items $TLMS($subsys,$alias,param)
      }
    }
    foreach item $items {
      set id [lindex $item end]
      if { [llength [split $item "()"]] > 1 } {
        set xid [lindex [split $id ()] 0]
        puts $fout "    print(\"$id = \" + str(list(myData.$xid)))"
      } else {
        puts $fout "    print(\"$id = \" + str(myData.$id))"
      }
    }
  }
}

