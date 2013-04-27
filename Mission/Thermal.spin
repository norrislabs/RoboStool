{{ Thermal.spin }}

' ==============================================================================
'
'   File...... Thermal.spin
'   Purpose... Thermal Detection and Tracking object
'   Author.... (C) 2007 Steven R. Norris -- All Rights Reserved
'   E-mail.... norris56@comcast.net
'   Started... 04/23/2007
'   Updated... 07/01/2008
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
  0719a - First version
  0827a - Modified for ServoPAL. Remove support for vertical servo.
}}


CON
' ------------------------------------------------------------------------------
' Constants
' ------------------------------------------------------------------------------

  ' Threshold Types
  Thres_None     = 0
  Thres_Hot      = 1
  Thres_Cold     = 2

  ' Scan max parameters (degrees)
  FullLeftPos    = 1
  FullRightPos   = 180

  ' Servo parameters (servo units: -1000 to 0 to +1000)
  Center_Horz    = 80
  FullLeft_Horz  = -800
  FullRight_Horz = 980


DAT

        HScan long      30,60,90,120,90,60

                
VAR
' ------------------------------------------------------------------------------
' Variables
' ------------------------------------------------------------------------------

  ' Cog maintenance variables
  byte m_Cog
  long m_Stack[50]

  byte m_TrackCog
  long m_TrackStack[50]

  byte m_PinTpaSCL
  byte m_PinTpaSDA
  byte m_PinServo
  
  byte m_Init
  
  long m_Ambient
  long m_Pixels[8]
  byte m_Update

  long m_HotThreshold
  long m_HottestPixel
  long m_HottestTemp
  
  long m_ColdThreshold
  long m_ColdestPixel
  long m_ColdestTemp

  ' Tracking
  byte m_TrackInit
  byte m_ThresholdType
  long m_ThermalPos
  long m_CurrentHPos
    
     
OBJ

  Tpa           : "TPA81"
  Servo         : "ServoPAL"


PUB Start(PinTpaSDA, PinTpaSCL, PinServo) : Success | pix
' ------------------------------------------------------------------------------
' Start
' ------------------------------------------------------------------------------
{{
  Starts the Thermal object in a seperate cog. Pass the pin numbers that are
  connected to the SCL and SDA lines of the TPA81. Pass pin servo,
  Returns a true if the startup was successful.
}}

  m_PinTpaSDA := PinTpaSDA
  m_PinTpaSCL := PinTpaSCL
  m_PinServo := PinServo

  m_HotThreshold := 20
  m_ColdThreshold := 15

  m_Ambient := 0
  repeat pix from 0 to 7
    m_Pixels[pix] := 0
  
  Stop
  Success := (m_Cog := cognew(Main,@m_Stack) + 1) 
  m_Init := Success

  ' Wait for the first update
  if Success > 0
    repeat until m_Pixels[7] > 0



PUB Stop
{{
  Stops the execution of the Thermal object.
}}
  
  if m_Cog > 0
    cogstop(m_Cog~ - 1)


PUB IsActive :YesNo
{{
  Determines if the Thermal object is running in a cog.
}}

  YesNo := m_Cog > 0


PUB Track(ThresholdType, ThresholdTemp) : Success
{{
  Starts thermal tracking in a separate cog. Main thermal must be started first.
  Pass threshold type (0 = hot, 1 = cold) and temperature.
  Returns true if successful.
}}

  if m_Init
    m_ThresholdType := ThresholdType
    if m_ThresholdType == Thres_Hot
      SetHotThreshold(ThresholdTemp)
    else
      SetColdThreshold(ThresholdTemp)
     
    Halt
    Success := (m_TrackCog := cognew(TrackMain, @m_TrackStack) + 1) 
    m_TrackInit := Success
  else
    Success := false
    

PUB ScanAndTrack(ThresholdType, ThresholdTemp) : Success
{{
  Starts thermal scanning and tracking in a separate cog. Main thermal must be started first.
  Pass threshold type (0 = hot, 1 = cold) and temperature.
  Returns true if successful.
}}

  if m_Init
    m_ThresholdType := ThresholdType
    if m_ThresholdType == Thres_Hot
      SetHotThreshold(ThresholdTemp)
    else
      SetColdThreshold(ThresholdTemp)
     
    Halt
    Success := (m_TrackCog := cognew(ScanTrackMain, @m_TrackStack) + 1) 
    m_TrackInit := Success
  else
    Success := false
    

PUB Halt
{{
  Stops the execution of scanning/tracking.
}}
  
  if m_TrackCog > 0
    m_ThermalPos := 0
    m_TrackInit := false
    cogstop(m_TrackCog~ - 1)


PUB Hold
{{
  Stops the execution of scanning/tracking.
  Does not reset servo positions.
}}
  
  if m_TrackCog
    m_ThermalPos := 0
    m_TrackInit := false
    cogstop(m_TrackCog~ - 1)


PUB IsTrackActive :YesNo
{{
  Determines if the tracking is running in a cog.
}}

  YesNo := m_TrackCog > 0


PUB SetHorzPos(Pos)

  if m_Init
    m_CurrentHPos := Pos
    Servo.SetServoPos(Deg2Width(Pos))


PUB GetHorzPos : pos

  if m_Init
    pos := m_CurrentHPos
  else
    pos := 0


PUB GetAmbient : data
{{
  Returns the current ambient temperature.
}}

  if m_Init
    data := m_Ambient
  else
    data := 0

    
PUB GetPixel(Pixel) : data
{{
  Returns the current temperature of a pixel (1-8).
}}

  if m_Init
    data := m_Pixels[Pixel-1]
  else
    data := 0

    
PUB GetHottestPixel : data
{{
  Returns the pixel that is the hottest above the set threshold (1-8).
}}

  if m_Init
    repeat while m_Update == true
    data := m_HottestPixel
  else
    data := 0

    
PUB GetHottestTemp : data
{{
  Returns the temperature of the pixel that is the hottest.
}}

  if m_Init
    repeat while m_Update == true
    data := m_HottestTemp
  else
    data := 0

    
PUB GetColdestPixel : data
{{
  Returns the pixel that is the coldest below the set threshold (1-8).
}}

  if m_Init
    repeat while m_Update == true
    data := m_ColdestPixel
  else
    data := 0


PUB GetColdestTemp : data
{{
  Returns the temperature of the pixel that is the coldest.
}}

  if m_Init
    repeat while m_Update == true
    data := m_ColdestTemp
  else
    data := 0


PUB SetHotThreshold(value)

  repeat while m_Update == true
  m_HotThreshold := value

       
PUB SetColdThreshold(value)

  repeat while m_Update == true
  m_ColdThreshold := value


PUB GetBearing : bearing
{{
  Returns the bearing of the thermal source.

  0       - Target not found
  1..180  - Target at this bearing
}}

  if m_TrackInit
    return m_ThermalPos
  else
    return 0

       
PRI Main | pix

  if tpa.init(m_PinTpaSDA,m_PinTpaSCL)
    repeat
      m_Ambient := tpa.GetAmbient
     
      m_Update := true
      repeat pix from 1 to 8
        m_Pixels[pix-1] := tpa.GetPixel(pix)
             
      FindHottestPixel
      FindColdestPixel
      m_Update := false

    
PRI FindHottestPixel | hottest,left,right,temp,i

  ' Scan left
  left := 0
  temp := m_HotThreshold
  repeat i from 0 to 7
    if m_Pixels[i] > temp
      temp := m_Pixels[i]
      left := i + 1
  if left == 0
    m_HottestTemp := 0
    m_HottestPixel := 0
    return

  ' Scan right
  right := 0
  temp := m_HotThreshold
  repeat i from 7 to 0
    if m_Pixels[i] > temp
      temp := m_Pixels[i]
      right := i + 1
  if right == 0
    m_HottestTemp := 0
    m_HottestPixel := 0
    return
  
  ' Find the center of the heat
  if right > left
    hottest := right - ((right - left) / 2)
  elseif left > right
    hottest := left + ((left - right) / 2)
  else
    hottest := right

  m_HottestTemp := m_Pixels[hottest-1]
  m_HottestPixel := hottest
    

PRI FindColdestPixel | coldest,left,right,temp,i

  ' Scan left
  left := 0
  temp := m_ColdThreshold
  repeat i from 0 to 7
    if m_Pixels[i] < temp
      temp := m_Pixels[i]
      left := i + 1
  if left == 0
    m_ColdestTemp := 0
    m_ColdestPixel := 0
    return

  ' Scan right
  right := 0
  temp := m_ColdThreshold
  repeat i from 7 to 0
    if m_Pixels[i] < temp
      temp := m_Pixels[i]
      right := i + 1
  if right == 0
    m_ColdestTemp := 0
    m_ColdestPixel := 0
    return
  
  ' Find the center of the cold
  if right > left
    coldest := right - ((right - left) / 2)
  elseif left > right
    coldest := left + ((left - right) / 2)
  else
    coldest := right

  m_ColdestTemp := m_Pixels[coldest-1]
  m_ColdestPixel := coldest


PRI TrackMain | pos,pix

  ' Initialize servo
  Servo.Init(m_PinServo)
       
  m_ThermalPos := 0
  pos := 90
  SetHorzPos(pos)
  Pause_ms(1000)

  repeat
    pos := Tracker(pos)
            

PRI ScanTrackMain | h,pix

  ' Initialize servo
  Servo.Init(m_PinServo)
       
  m_ThermalPos := 0
  h := 0

  repeat
    repeat h from 0 to 5
      SetHorzPos(HScan[h])
      Pause_ms(200)
                
      if m_ThresholdType == Thres_Hot
        pix := GetHottestPixel
      else
        pix := GetColdestPixel

      if pix > 0
        Tracker(HScan[h])
          
    
PRI Tracker(CurrentPos) : LastPos | pix,lost

  lost := 0
  repeat
    if m_ThresholdType == Thres_Hot
      pix := GetHottestPixel
    else
      pix := GetColdestPixel

    case pix
      0:
        lost++
        if lost > 16
          m_ThermalPos := 0
          return CurrentPos
            
      1..3:
        CurrentPos := (CurrentPos + 1) <# 180
        m_ThermalPos := CurrentPos
        lost := 0

      4..5:
        m_ThermalPos := CurrentPos
        lost := 0
                
      6..8:
        CurrentPos := (CurrentPos - 1) #> 1
        m_ThermalPos := CurrentPos
        lost := 0
        
    SetHorzPos(CurrentPos)
    Pause_ms(15)


PRI Deg2Width(deg) : width

  if deg => 90
    width := (deg - 90) * round(float(FullRight_Horz) / 90.0)  
  else
    width := (90 - deg) * round(float(FullLeft_Horz) / 90.0)

  width += Center_Horz  


PRI Pause_ms(msDelay)
  waitcnt(cnt + ((clkfreq / 1000) * msDelay))
  