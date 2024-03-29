{{ ServoPAL.spin }}

' ==============================================================================
'
'   File...... ServoPAL.spin
'   Purpose... Support functions for the Parallax ServoPAL
'   Author.... (C) 2008 Steven R. Norris -- All Rights Reserved
'   E-mail.... steve@norrislabs.com
'   Started... 07/02/2008
'   Updated... 
'
' ==============================================================================

' ------------------------------------------------------------------------------
' Program Description
' ------------------------------------------------------------------------------
{{
  These are a set of support functions for the Parallax ServoPAL. Init must be
  called first. Does not support the second servo or timer. 
}}


' ------------------------------------------------------------------------------
' Revision History
' ------------------------------------------------------------------------------
{{
  0827a - This is the first version
}}


CON
' ------------------------------------------------------------------------------
' Constants
' ------------------------------------------------------------------------------

  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000


VAR
' ------------------------------------------------------------------------------
' Variables
' ------------------------------------------------------------------------------

  long m_Init
  long m_PinPAL
  

OBJ


PUB Init(PinPAL)

  m_PinPAL := PinPAL
  
  ' Wait for ServoPAL to initialize
  dira[m_PinPAL]~
  repeat until ina[m_PinPAL] == 1

  ' Reset ServoPAL
  outa[m_PinPAL]~
  dira[m_PinPAL]~~
  Pause_ms(100)
  outa[m_PinPAL]~~

  Pause_ms(100)
  m_Init := true
    

PUB Release

  if m_Init
    dira[m_PinPAL]~


PUB SetServoPos(pos) | pw
{{
  pos is a number from -1000 to 1000
}}

  if m_Init
    pw := pos + 1500
    SetPulseWidth(pw)

  
PUB SetPulseWidth(PulseWidth)

  if m_Init
    outa[m_PinPAL]~
    Pause_us(PulseWidth)
    outa[m_PinPAL]~~


PRI Pause_ms(msDelay)
  waitcnt(cnt + ((clkfreq / 1000) * msDelay))


PRI Pause_us(usDelay)
  waitcnt(cnt + ((clkfreq / 1000000) * usDelay))