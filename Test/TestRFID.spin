{{ TestRFID.spin }}

' ==============================================================================
'
'   File...... TestRFID.spin
'   Purpose... Test the Parallax RFID reader
'   Author.... (C) 2008 Steven R. Norris -- All Rights Reserved
'   E-mail.... steve@norrislab.com
'   Started... 07/18/2008
'   Updated... 07/19/2008
'
' ==============================================================================

' ------------------------------------------------------------------------------
' Program Description
' ------------------------------------------------------------------------------
{{
  This is a description of the program.
}}


' ------------------------------------------------------------------------------
' Revision History
' ------------------------------------------------------------------------------
{{
  0829a - First version
}}


CON
' ------------------------------------------------------------------------------
' Constants
' ------------------------------------------------------------------------------

  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

  Pin_Drive     = 0
  Pin_Lift      = 1
  Pin_IR        = 2
  Pin_PingHi    = 3
  Pin_PingLo    = 4
  Pin_Power     = 5
  Pin_RfidEn    = 6
  Pin_RfidData  = 7
  Pin_IrServo   = 8
  Pin_Lcd       = 9
  Pin_TpaSDA    = 10
  Pin_TpaSCL    = 11
  Pin_ProxLeft  = 12
  Pin_ProxRight = 13
  Pin_Speaker   = 15
  Pin_Led       = 16
  Pin_DataIn    = 22
  Pin_DataOut   = 23


VAR
' ------------------------------------------------------------------------------
' Variables
' ------------------------------------------------------------------------------

  byte TagID[10]
  

OBJ
' ------------------------------------------------------------------------------
' Objects
' ------------------------------------------------------------------------------

  RFID          : "RFID"
  RfLink        : "FullDuplexSerial"
  Speaker       : "Speaker"


PUB Main | i
' ------------------------------------------------------------------------------
' Public Procedures
' ------------------------------------------------------------------------------

  ' Initialize RFID reader (uses one cog)
  RFID.Start(Pin_RfidEn, Pin_RfidData)
  RFID.Enable(true)
  
  ' Initialize RF serial link (uses 1 cog)
  RfLink.Start(Pin_DataIn, Pin_DataOut, 0, 9600)

   ' Initialize speaker (uses 1 cog when producing sound)
  Speaker.Init(Pin_Speaker)

  repeat
    if RFID.IsTag
      RFID.ReadTag(@TagID)

      repeat i from 0 to 9
        RfLink.hex(TagID[i], 2)
        RfLink.tx(" ")
      RfLink.tx(13)  

      Speaker.BeepDec(2)
      RFID.Enable(false)
      Pause_ms(1000)
      RFID.Enable(true)
    
      
PRI Pause_ms(msDelay)
  waitcnt(cnt + ((clkfreq / 1000) * msDelay))
  