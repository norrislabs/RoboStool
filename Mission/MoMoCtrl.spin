{{ MoMoCtrl.spin }}

' ==============================================================================
'
'   File...... MoMoCtrl.spin
'   Purpose... Support functions for the Parallax Motor Mount & Wheel Kit
'   Author.... (C) 2008 Steven R. Norris - See end of file for terms of use 
'   E-mail.... steve@norrislabs.com
'   Started... 07/02/2008
'   Updated... 03/26/2009
'
' ==============================================================================

' ------------------------------------------------------------------------------
' Program Description
' ------------------------------------------------------------------------------
{{
  This is a collection of support functions for the Parallax Motor Mount
  and Wheel Kit/Position Controller using HB-25 motor controllers.
  Start must be called first with the pin number of the serial line. 
}}


' ------------------------------------------------------------------------------
' Revision History
' ------------------------------------------------------------------------------
{{
  0827a - This is the first version
  0913a - Call EmergencyHalt one second after normal Halt to reset position
}}


CON
' ------------------------------------------------------------------------------
' Constants
' ------------------------------------------------------------------------------

  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000
  
  ' Drive/Position controller commands 
  QPOS          = $08   'Query Position
  QSPD          = $10   'Query Speed
  CHFA          = $18   'Check for Arrival
  TRVL          = $20   'Travel Number of Positions
  CLRP          = $28   'Clear Position
  SREV          = $30   'Set Orientation as Reversed
  STXD          = $38   'Set TX Delay
  SMAX          = $40   'Set Speed Maximum
  SSRR          = $48   'Set Speed Ramp Rate

  ' Wheels
  AllWheels     = 0
  RightWheel    = 1     'ID of the right side Position Controller
  LeftWheel     = 2     'ID of the left side Position Controller



VAR
' ------------------------------------------------------------------------------
' Variables
' ------------------------------------------------------------------------------

  long m_Init
  

OBJ

  DriveCom         : "FullDuplexSerial128"


PUB Start(PinDrive)

  if m_Init
    DriveCom.Stop
    
  DriveCom.Start(PinDrive, PinDrive, 4, 19200)
  m_Init := true

  Pause_ms(250)
  ResetDrive

  ' Reverse the sensor on the right
  DriveCom.tx(SREV + RightWheel)
  

PUB Stop

  DriveCom.Stop
  m_Init := false

  
PUB GoDistance(Wheel, Distance)

  if m_Init
    DriveCom.tx(TRVL + Wheel)
    DriveCom.tx(Distance.byte[1])
    DriveCom.tx(Distance.byte[0])
  

PUB SetSpeed(Wheel, Speed)

  if m_Init
    DriveCom.tx(SMAX + Wheel)
    DriveCom.tx(Speed.byte[1])
    DriveCom.tx(Speed.byte[0])


PUB SpinCW(Degrees) | dist

  dist := Degrees / 6
  SetSpeed(AllWheels, 5)
  GoDistance(LeftWheel, dist)
  GoDistance(RightWheel, -dist)


PUB SpinCCW(Degrees) | dist

  dist := Degrees / 6
  SetSpeed(AllWheels, 5)
  GoDistance(RightWheel, dist)
  GoDistance(LeftWheel, -dist)


PUB Halt

  GoDistance(AllWheels, 0)
  Pause_ms(1000)
  EmergencyHalt
    

PUB EmergencyHalt

  if m_Init
    DriveCom.tx(CLRP + RightWheel)
    DriveCom.tx(CLRP + LeftWheel)


PUB WaitArrived(Wheel)

  repeat while HasArrived(Wheel, 1) == false
    Pause_ms(10)


PUB HasArrived(Wheel, Tolerance) : yesno | data

  if m_Init  
    DriveCom.rxflush

    DriveCom.tx(CHFA + Wheel)
    DriveCom.tx(Tolerance)

    ' Receive what was just sent
    ' TX and RX are the same pin
    DriveCom.rx
    DriveCom.rx
  
    if DriveCom.rx == $FF
      yesno := true
    else
      yesno := false
  else
    yesno := true
      

PUB ResetDrive

  if m_Init
    repeat 3
      DriveCom.tx(CLRP + RightWheel)
      DriveCom.tx(CLRP + LeftWheel)
      Pause_ms(100)


PRI Pause_ms(msDelay)
  waitcnt(cnt + ((clkfreq / 1000) * msDelay))


DAT
{<end of object code>}
     
{{
┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                   TERMS OF USE: MIT License                                                  │                                                            
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    │ 
│files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    │
│modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software│
│is furnished to do so, subject to the following conditions:                                                                   │
│                                                                                                                              │
│The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.│
│                                                                                                                              │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          │
│WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         │
│COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   │
│ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
}}      