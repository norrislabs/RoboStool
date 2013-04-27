{{ TPA81.spin }}

' ==============================================================================
'
'   File...... TPA81.spin
'   Purpose... TPA81 Thermal Array Sensor object
'   Author.... (C) 2007 Steven R. Norris -- All Rights Reserved
'   E-mail.... norris56@comcast.net
'   Started... 04/23/2007
'   Updated...
'
' ==============================================================================

' ------------------------------------------------------------------------------
' Program Description
' ------------------------------------------------------------------------------
{{
}}


' ------------------------------------------------------------------------------
' Revision History
' ------------------------------------------------------------------------------
{{
  0717a - First version
}}


CON
' ------------------------------------------------------------------------------
' Constants
' ------------------------------------------------------------------------------

  Tpa_Address   = $D0
    
  Reg_Version   = 0
  Reg_Ambient   = 1
  Reg_Pixel1    = 2
  Reg_Pixel2    = 3
  Reg_Pixel3    = 4
  Reg_Pixel4    = 5
  Reg_Pixel5    = 6
  Reg_Pixel6    = 7
  Reg_Pixel7    = 7
  Reg_Pixel8    = 9

  
VAR
' ------------------------------------------------------------------------------
' Variables
' ------------------------------------------------------------------------------

OBJ

  Tpa           : "i2cObject"


PUB Init(PinSDA, PinSCL) : okay
' ------------------------------------------------------------------------------
' Initialize
' ------------------------------------------------------------------------------

  okay := tpa.init(PinSDA,PinSCL,false)
     

PUB GetAmbient : data

  data := tpa.ReadLocation(Tpa_Address,Reg_Ambient,8,8)
  

PUB GetPixel(Pixel) : data

  if lookdown(Pixel : 1..8) > 0   
    data := tpa.ReadLocation(Tpa_Address,Pixel + 1,8,8)
  else
    data := 0
  