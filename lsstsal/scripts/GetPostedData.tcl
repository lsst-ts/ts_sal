# Filename GetPostedData.tcl.
# Intended to be 'source'd by a Tcl script which is attached to 
# a HTML FORM. A call from the script to the GetPostedData 
# procedure will obtain all the name/value pairs from the 
# protocol stream, decode them and place them in the associative 
# array FormData().
#
# Fintan Culwin, fintan@sbu.ac.uk, v 0.2, March 1996
#        0.2 produces lists in FormData() from checkboxes




########################################################
# SubHexCodes                                          #
# Substitute URL hex codes with equivalent characters  #
########################################################

proc SubHexCodes { HexLine} {

set HoldLine $HexLine 
   # Replace any + with hexcode for space
   regsub -all \\+ $HoldLine %20 HoldLine
   # Iterate whilst there is a hex code to substitute
   while { [regexp {%[0-9A-F][0-9A-F]} $HoldLine HexCode]} {

      # == sybols 0x3D must not be substituted yet ...
      if { $HexCode == "%3D" } {
          regsub -all $HexCode $HoldLine 0x3D HoldLine
      } else {
         # convert %ff format into 0xff format & obtain character
         regsub \% $HexCode 0x  HexVal
         set CharCode [format "%c" $HexVal]
         # Substitute back into the string treating & / \ separately
         if { $HexVal == 0x26} {
           regsub -all $HexCode $HoldLine  \\&  HoldLine
         } else {
           if { $HexVal == 0x2F} {
              regsub -all $HexCode $HoldLine  /  HoldLine
           } else {
              regsub -all $HexCode $HoldLine $CharCode HoldLine
           }
         }
      } 
   }
   return $HoldLine
}

########################################################
# GetPostedData                                        #
# Extract the name/value pairs obtained from stdin,    #
# storing in an associative array called FormData      #
########################################################
proc GetPostedData {} {

global FormData
global env

   # Obtain env(CONTENT_LENGTH) characters from stdin
   set line [read stdin $env(CONTENT_LENGTH)]

   # Prepend an '&' to assit with splitting.
   set line &$line

   set line [ SubHexCodes $line ]

   # Iteratively split the line on '&' and then the last field 
   # on '=' to obtain name/value pairs.
   while {[regexp {(.*)&(.*)=(.*)} $line foo first name value]} {
      # take care of any = symbols
      regsub -all 0x3D $name  "=" name
      regsub -all 0x3D $value "=" value
      # Store the first part back into line
      set line $first
      # Store value in the array indexed by name
      if { [info exists FormData($name) ] } { 
          lappend FormData($name) $value
      } else { 
         set FormData($name) $value
      } 
   } 
}
