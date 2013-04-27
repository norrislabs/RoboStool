{{ TestRelay.spin }}

' ==============================================================================
'
'   File...... TestRelay.spin
'   Purpose... Test the power relay
'   Author.... (C) 2008 Steven R. Norris -- All Rights Reserved
'   E-mail.... steve@norrislab.com
'   Started... 07/09/2008
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
  0828a - First version
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


OBJ
' ------------------------------------------------------------------------------
' Objects
' ------------------------------------------------------------------------------


PUB Init
' ------------------------------------------------------------------------------
' Public Procedures
' ------------------------------------------------------------------------------

  ' Turn off LED
  outa[Pin_Led]~
  dira[Pin_Led]~~

  ' Turn off power
  outa[Pin_Power]~
  dira[Pin_Power]~~

  Pause_ms(1000)  

  ' Setup HB-25 pin
  outa[Pin_Lift]~
  dira[Pin_Lift]~~

  ' Turn on power
  outa[Pin_Power]~~
  Pause_ms(1000)

  outa[Pin_Led]~~
  InitLift
  Pause_ms(1000)
  LiftUp
  Pause_ms(2000)
  LiftDown

  ' Turn off power
  outa[Pin_Power]~

  outa[Pin_Led]~
  repeat
        
' ------------------------------------------------------------------------------
' Lift Functions
' ------------------------------------------------------------------------------

PRI InitLift

'  ' Wait for HB25 to power up
'  dira[Pin_Lift]~
'  repeat until ina[Pin_Lift] == 1

  ' Setup for output
'  outa[Pin_Lift]~
'  dira[Pin_Lift]~~

  Pause_ms(10)
  PulseHB25(1500)
  Pause_ms(10)


PRI LiftUp

  PulseHB25(1050)
  Pause_ms(9000)
  PulseHB25(1500)

    
PRI LiftDown

   PulseHB25(1950)
   Pause_ms(8000)
   PulseHB25(1500)
  
    
PRI PulseHB25(pulse) | pwidth

  pwidth := ((pulse * (clkfreq / 1_000_000)) - 1200) #> 381  ' calculate pulse width

  outa[Pin_Lift]~~                                              
  waitcnt(pwidth + cnt)                                                
  outa[Pin_Lift]~                                                                           
  Pause_ms(5)


PRI Pause_ms(msDelay)
  waitcnt(cnt + ((clkfreq / 1000) * msDelay))
  