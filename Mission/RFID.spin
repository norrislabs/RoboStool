{{ RFID.spin }}

' ==============================================================================
'
'   File...... RFID.spin
'   Purpose... Parallax RFID reader object
'   Author.... (C) 2008 Steven R. Norris -- All Rights Reserved
'   E-mail.... steve@norrislab.com
'   Started... 07/19/2008
'   Updated...
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


VAR
' ------------------------------------------------------------------------------
' Variables
' ------------------------------------------------------------------------------

  long m_PinEnable
  long m_PinDataIn
  

OBJ
' ------------------------------------------------------------------------------
' Objects
' ------------------------------------------------------------------------------

  RFID  : "FullDuplexSerial128"


PUB Start(PinEnable,PinDataIn)
' ------------------------------------------------------------------------------
' Public Procedures
' ------------------------------------------------------------------------------

  m_PinEnable := PinEnable
  m_PinDataIn := PinDataIn

  ' Initialize enable pin
  outa[m_PinEnable]~~
  dira[m_PinEnable]~~

  ' Initialize RFID serial link (uses 1 cog)
  RFID.Start(m_PinDataIn, -1, 0, 2400)


PUB Stop

  RFID.Stop
  

PUB Enable(yesno)

  if yesno
    outa[m_PinEnable]~
  else
    outa[m_PinEnable]~~

  RFID.rxflush
  

PUB CheckTag : yesno | data

    ' Check for start byte            
    data := RFID.rxcheck
    if data == $0A
      return true
    else
      return false
      

PUB ReadTag(TagBuf) | i

  repeat i from 0 to 9
    byte[TagBuf + i] := RFID.rx

  ' Throw away stop byte
  RFID.rx
  