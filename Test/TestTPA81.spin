{{ TestTPA81.spin }}

' ==============================================================================
'
'   File...... TestTPA81.spin
'   Purpose... Test thermal tracker components
'   Author.... (C) 2008 Steven R. Norris -- All Rights Reserved
'   E-mail.... steve@norrislabs.com
'   Started... 07/01/2008
'   Updated... 
'
' ==============================================================================

' ------------------------------------------------------------------------------
' Program Description
' ------------------------------------------------------------------------------
{{
  Program used to test the components of the Robotic Thermal Tracker.
  Components include:
        TPA81 Thermal sensor
        Horizontal and Vertical servos
        Debug LCD and LED
}}


' ------------------------------------------------------------------------------
' Revision History
' ------------------------------------------------------------------------------
{{
  0827a - First version
}}


CON
' ------------------------------------------------------------------------------
' Constants
' ------------------------------------------------------------------------------

  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000


  Pin_Lcd       = 9
  Pin_TpaSDA    = 10
  Pin_TpaSCL    = 11
  Pin_Speaker   = 15
  Pin_Led       = 16
  Pin_DataIn    = 22
  Pin_DataOut   = 23

  
DAT
        Title     byte "Test TPA81",0
        Version   byte "0827a",0


VAR
' ------------------------------------------------------------------------------
' Variables
' ------------------------------------------------------------------------------


     
OBJ
  Tpa           : "TPA81"
  RfLink        : "FullDuplexSerial"
  Speaker       : "Speaker"
  Lcd           : "debug_lcd"


PUB Start | pix
' ------------------------------------------------------------------------------
' Main Program
' ------------------------------------------------------------------------------

  ' Turn on LED
  dira[Pin_Led]~~
  outa[Pin_Led]~~

  ' Initialize the LCD
  Lcd.init(Pin_Lcd, 19200, 2)
  Lcd.cursor(0)                 ' cursor off
  Lcd.cls
  Lcd.home
  Lcd.backLight(true)

  ' Display title and version
  Lcd.str(@Title)
  Lcd.putc($0D)
  Lcd.str(@Version)

   ' Initialize speaker (uses 1 cog when producing sound)
  Speaker.Init(Pin_Speaker)

  ' Initialize RF serial link (uses 1 cog)
  RfLink.Start(Pin_DataIn, Pin_DataOut, 0, 9600)

  ' Initialize TPA81 I2C
  Tpa.Init(Pin_TpaSDA, Pin_TpaSCL)

  ' LED off
  outa[Pin_Led]~
  Speaker.BeepDec(3)

  repeat
    RfLink.dec(Tpa.GetAmbient)
    RfLink.str(string(" - "))

    repeat pix from 1 to 8
      RfLink.dec(Tpa.GetPixel(pix))
      RfLink.str(string(", "))
    RfLink.tx($0D)
    Pause_ms(1000)
  
    
PRI Pause_ms(msDelay)
  waitcnt(cnt + ((clkfreq / 1000) * msDelay))
  