{{ Mission.spin }}

' ==============================================================================
'
'   File...... Mission.spin
'   Purpose... Mission application for N19-RoboStool
'   Author.... (C) 2008-2011 Steven R. Norris -- All Rights Reserved
'   E-mail.... steve@norrislabs.com
'   Started... 05/21/2008
'   Updated... 12/23/2011
'
' ==============================================================================

' ------------------------------------------------------------------------------
' Program Description
' ------------------------------------------------------------------------------
{{
   This is mission code for RoboStool.
}}


' ------------------------------------------------------------------------------
' Revision History
' ------------------------------------------------------------------------------
{{
  0825a - This is the first version
  0826a - Added support for dual (upper/lower) Pings
          New rear caster - added support for full reverse
  0827a - Created objects for ServoPAL and motor drive
          Added support for Follow-Me thermal tracking
  0828a - Added support for lift/drive power relay
  0830a - Added support for RFID reader
  0833a - Added support for lift toggle command (LX)
          Reduced proximity veer time
  0913a - Flush buffer after backup
          Updated Halt procedure in MoMoCtrl
  0951a - Modified LF/RT commands to work like CoolerBot
  1113a - Remove problematic lower Ping, updated to new link protocol
  1151a - Remove all RFID support        
}}


CON
' ------------------------------------------------------------------------------
' Constants
' ------------------------------------------------------------------------------

  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

  ' IDs
  NetID         = "R"           ' Robot Network
  DevID         = "1"           ' RoboStool ID

  ' Pins
  Pin_Drive     = 0
  Pin_Lift      = 1
  Pin_IR        = 2
  Pin_PingHi    = 3
  Pin_PingLo    = 4             ' Not used
  Pin_Power     = 5
  Pin_RfidEn    = 6             ' Not used
  Pin_RfidData  = 7             ' Not used
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

  ' Servo IDs
  Servo_IR      = 0

  ' Move Directions
  Mov_Halt      = 0
  Mov_Fwd       = 1
  Mov_Rev       = 2
  Mov_SpinCW    = 3
  Mov_SpinCCW   = 4

  ' Route IDs
  Rt_None       = 0
  Rt_PingPong   = 1
  Rt_Left_L     = 2
  Rt_Right_L    = 3  
  Rt_Left_U     = 4
  Rt_Right_U    = 5  
  Rt_Left_Z     = 6
  Rt_Right_Z    = 7  

  ' Route Operators
  Op_Home       = 0
  Op_GotoBeacon = 1
  Op_Fwd        = 2
  Op_Stop       = 3
  Op_SpinLeft   = 4
  Op_SpinRight  = 5
  Op_FindBeacon = 6
  Op_Pause      = 7
  Op_Repeat     = 8
  Op_LiftUp     = 9
  Op_LiftDn     = 10

  ' Function return codes
  Ret_None      = 0
  Ret_Complete  = 1
  Ret_Canceled  = 2

  ' Servo storage position (robot's full right)
  ServoStorePos = -800

  
DAT
        Title     byte "N19-RoboStool",0
        Version   byte "1151a",0

        ' Routes
        PingPong  long Op_GotoBeacon, Op_FindBeacon, Mov_SpinCCW
                  long Op_Repeat
                  long $FF

        Goto      long Op_GotoBeacon, Op_FindBeacon, Mov_SpinCCW
                  long $FF

        GotoSit   long Op_GotoBeacon, Op_LiftDn
                  long $FF

        Left_L    long Op_GotoBeacon, Op_FindBeacon, Mov_SpinCW
                  long Op_GotoBeacon, Op_FindBeacon, Mov_SpinCW
                  long Op_GotoBeacon, Op_FindBeacon, Mov_SpinCCW
                  long Op_GotoBeacon, Op_FindBeacon, Mov_SpinCCW
                  long Op_Repeat
                  long $FF

        Right_L   long Op_GotoBeacon, Op_FindBeacon, Mov_SpinCCW
                  long Op_GotoBeacon, Op_FindBeacon, Mov_SpinCCW
                  long Op_GotoBeacon, Op_FindBeacon, Mov_SpinCW
                  long Op_GotoBeacon, Op_FindBeacon, Mov_SpinCW
                  long Op_Repeat
                  long $FF

        Left_U    long Op_GotoBeacon, Op_FindBeacon, Mov_SpinCW
                  long Op_GotoBeacon, Op_FindBeacon, Mov_SpinCW
                  long Op_GotoBeacon, Op_FindBeacon, Mov_SpinCW
                  long Op_GotoBeacon, Op_FindBeacon, Mov_SpinCCW
                  long Op_GotoBeacon, Op_FindBeacon, Mov_SpinCCW
                  long Op_GotoBeacon, Op_FindBeacon, Mov_SpinCCW
                  long Op_Repeat
                  long $FF

        Right_U   long Op_GotoBeacon, Op_FindBeacon, Mov_SpinCCW
                  long Op_GotoBeacon, Op_FindBeacon, Mov_SpinCCW
                  long Op_GotoBeacon, Op_FindBeacon, Mov_SpinCCW
                  long Op_GotoBeacon, Op_FindBeacon, Mov_SpinCW
                  long Op_GotoBeacon, Op_FindBeacon, Mov_SpinCW
                  long Op_GotoBeacon, Op_FindBeacon, Mov_SpinCW
                  long Op_Repeat
                  long $FF

        Left_Z    long Op_GotoBeacon, Op_FindBeacon, Mov_SpinCW
                  long Op_GotoBeacon, Op_FindBeacon, Mov_SpinCCW
                  long Op_GotoBeacon, Op_FindBeacon, Mov_SpinCCW
                  long Op_GotoBeacon, Op_FindBeacon, Mov_SpinCW
                  long Op_GotoBeacon, Op_FindBeacon, Mov_SpinCCW
                  long Op_GotoBeacon, Op_FindBeacon, Mov_SpinCCW
                  long Op_Repeat
                  long $FF

        Right_Z   long Op_GotoBeacon, Op_FindBeacon, Mov_SpinCCW
                  long Op_GotoBeacon, Op_FindBeacon, Mov_SpinCW
                  long Op_GotoBeacon, Op_FindBeacon, Mov_SpinCW
                  long Op_GotoBeacon, Op_FindBeacon, Mov_SpinCCW
                  long Op_GotoBeacon, Op_FindBeacon, Mov_SpinCW
                  long Op_GotoBeacon, Op_FindBeacon, Mov_SpinCW
                  long Op_Repeat
                  long $FF

        Left_Tri  long Op_GotoBeacon, Op_FindBeacon, Mov_SpinCW
                  long Op_GotoBeacon, Op_FindBeacon, Mov_SpinCW
                  long Op_GotoBeacon, Op_FindBeacon, Mov_SpinCW
                  long Op_Repeat
                  long $FF

        Right_Tri long Op_GotoBeacon, Op_FindBeacon, Mov_SpinCCW
                  long Op_GotoBeacon, Op_FindBeacon, Mov_SpinCCW
                  long Op_GotoBeacon, Op_FindBeacon, Mov_SpinCCW
                  long Op_Repeat
                  long $FF


VAR
' ------------------------------------------------------------------------------
' Variables
' ------------------------------------------------------------------------------

  long m_CurrentSpeed
  long m_CurrentDir

  long m_DistFwd
  
  long m_LiftUp
  long m_Rolling

  byte m_Buffer[32]
  long m_Stack[60]


OBJ

  Drive         : "MoMoCtrl"
  RfLink        : "FullDuplexSerial128"
  Ping          : "Ping"
  ADF           : "ADF"
  TPA           : "Thermal"
  Servo         : "ServoPAL"
  Speaker       : "Speaker"

  
PUB Init
' ------------------------------------------------------------------------------
' Initialize
' ------------------------------------------------------------------------------

  ' Turn on LED
  dira[Pin_Led]~~
  outa[Pin_Led]~~

  ' Setup HB-25 pin for lift motors
  outa[Pin_Lift]~
  dira[Pin_Lift]~~

  ' Initialize speaker (uses 1 cog when producing sound)
  Speaker.Init(Pin_Speaker)

  ' Initialize RF serial link (uses 1 cog)
  RfLink.Start(Pin_DataIn, Pin_DataOut, 0, 9600)

  ' Start sensor scan (uses 1 cog)
  cognew(SensorScan, @m_Stack)

  ' LED off
  outa[Pin_Led]~
  Speaker.BeepDec(3)

  ' Initial state is remote control
  Reset
  RemoteControl


PRI Reset

  ' Stop beacon navigation if active
  ADF.Halt
  ADF.Stop

  ' Stop thermal tracking if active
  TPA.Halt
  TPA.Stop

  ' Initialize ServoPAL
  ' Make sure servo is in storage position
  Servo.Init(Pin_IrServo)
  Servo.SetServoPos(ServoStorePos)
  Servo.Release


' ------------------------------------------------------------------------------
' Remote Control
' ------------------------------------------------------------------------------
PRI RemoteControl | curdir,data,speed,dist,tag

  speed := 12
  curdir := Mov_Halt
  repeat
    if curdir == Mov_Fwd
      if m_DistFwd < 16
        Backup
        curdir := Mov_Halt
        RfLink.rxflush                
        next

   ' Check for and process remote commands
    if GetHeader
      if GetCmd
      ' Lift up
        if strcomp(@m_Buffer, string("F1"))
          LiftUp
          
      ' Lift down
        if strcomp(@m_Buffer, string("F2"))
          if curdir <> Mov_Halt
            Drive.Halt
          LiftDown

      ' Lift toggle
        if strcomp(@m_Buffer, string("F3"))
          if curdir <> Mov_Halt
            Drive.Halt
          if m_LiftUp
            ' Up
            LiftDown
          else
            ' Down
            LiftUp
          

      ' Pace Free
        if strcomp(@m_Buffer, string("M1"))
          if curdir <> Mov_Halt
            Drive.Halt 

          if !m_LiftUp
            LiftUp
           
            PaceFree
            Reset
          curdir := Mov_Halt
            
      ' Follow Me
        if strcomp(@m_Buffer, string("M2"))
          if curdir <> Mov_Halt
            Drive.Halt 

          if !m_LiftUp
            LiftUp
           
            FollowMe(3)
            Reset
          curdir := Mov_Halt
            
      ' Beacon navigation - Goto and Sit
        if strcomp(@m_Buffer, string("M3"))
          if curdir <> Mov_Halt
            Drive.Halt 

          if !m_LiftUp
            LiftUp
           
            BeaconNav(@GotoSit)
            Reset
          curdir := Mov_Halt
            
     ' Query Status
        if strcomp(@m_Buffer, string("T1")) 
          SendSensorData

      ' Forward
        if strcomp(@m_Buffer, string("FW"))
          if !m_LiftUp
            LiftUp

          if curdir <> Mov_Halt and curdir <> Mov_Fwd
            Drive.Halt
          Drive.SetSpeed(Drive#AllWheels, speed)
          Drive.GoDistance(Drive#AllWheels, 1000)
          curdir := Mov_Fwd

      ' Reverse
        if strcomp(@m_Buffer, string("BK"))
          if !m_LiftUp
            LiftUp

          if curdir <> Mov_Halt and curdir <> Mov_Rev
            Drive.Halt
          Drive.SetSpeed(Drive#AllWheels, speed)
          Drive.GoDistance(Drive#AllWheels, -1000)
          curdir := Mov_Rev
          
      ' Halt
        if strcomp(@m_Buffer, string("HL"))
          if(curdir == Mov_SpinCCW or curdir == Mov_SpinCW)
            Drive.EmergencyHalt
          else
            Drive.Halt
          Pause_ms(250)
          RfLink.rxflush
          curdir := Mov_Halt
            
      ' Emergency Stop
        if strcomp(@m_Buffer, string("ES"))
          Drive.EmergencyHalt
          Pause_ms(250)
          RfLink.rxflush
          curdir := Mov_Halt
            
      ' Left
        if strcomp(@m_Buffer, string("LF"))
          if curdir == Mov_Fwd
            VeerLeft(speed,0)
          elseif curdir == Mov_Rev
            VeerRight(speed,0)
          elseif curdir == Mov_Halt
            if !m_LiftUp
              LiftUp
            Drive.SpinCCW(360)
            curdir := Mov_SpinCCW
                         
      ' Right
        if strcomp(@m_Buffer, string("RT"))
          if curdir == Mov_Fwd
            VeerRight(speed,0)
          elseif curdir == Mov_Rev
            VeerLeft(speed,0)
          else
            if !m_LiftUp
              LiftUp
            Drive.SpinCW(360)
            curdir := Mov_SpinCW


PRI VeerRight(speed,time)

  Drive.SetSpeed(Drive#RightWheel, speed - 4)
  Drive.SetSpeed(Drive#LeftWheel, speed)
  if(time > 0)
    Pause_ms(time)
    Drive.SetSpeed(Drive#AllWheels, speed)


PRI VeerLeft(speed,time)

  Drive.SetSpeed(Drive#RightWheel, speed)
  Drive.SetSpeed(Drive#LeftWheel, speed - 4)
  if(time > 0)
    Pause_ms(time)
    Drive.SetSpeed(Drive#AllWheels, speed)


PRI Backup

  Drive.Halt
  Drive.SetSpeed(Drive#AllWheels, 12)
  Drive.GoDistance(Drive#AllWheels, -20)
  Pause_ms(2000)
  Drive.Halt


PRI GetHeader : status | data

  status := false
  data := RfLink.rxcheck
  if data == ">"
    data := RfLink.rxtime(5000)
    if data == NetID
      data := RfLink.rxtime(5000)
      if data == DevID
        status := true
   
        
PRI GetCmd : status | data,i

  i := 0
  data := 0
  repeat while data <> -1
    data := RfLink.rxtime(5000)

    if data == 13
      m_Buffer[i] := 0
      status := true
      return

    m_Buffer[i] := data

    i++
    m_Buffer[i] := 0
    if i == 31
      quit

  status := false  


' ------------------------------------------------------------------------------
' Pace Free
' ------------------------------------------------------------------------------
PRI PaceFree : status | rolling

  ' Make sure we are not doing beacon navigation
  ADF.Halt
  ADF.Stop

  rolling := false
  repeat
    if IsCanceled
      Drive.Halt
      return Ret_Canceled

    if rolling
      if m_DistFwd < 16
        Drive.Halt
        TurnAround
        rolling := false        
        next
        
    ' Avoid stuff here
      if ina[Pin_ProxLeft] == 1
        VeerRight(12, 0)

      if ina[Pin_ProxRight] == 1
         VeerLeft(12, 0)
     
      if Drive.HasArrived(Drive#LeftWheel, 5)
        Drive.Halt
        TurnAround
        rolling := false
    else        
      Drive.SetSpeed(Drive#AllWheels, 12)
      Drive.GoDistance(Drive#AllWheels, 48)
      rolling := true


PRI TurnAround

  Drive.SpinCW(180)
  Drive.WaitArrived(Drive#LeftWheel)

' ------------------------------------------------------------------------------
' Follow Me/Thermal Tracking
' ------------------------------------------------------------------------------
PRI FollowMe(AmbientOffset) : status | dist,speed,bearing,error,corr,rolling

  ' Make sure we are not doing beacon navigation
  ADF.Halt
  ADF.Stop

  ' Initialize thermal tracking  
  TPA.Start(Pin_TpaSDA, Pin_TpaSCL, Pin_IrServo)
  TPA.Track(0, TPA.GetAmbient + AmbientOffset)

  rolling := false
  repeat
    if IsCanceled
      StopFM
      return Ret_Canceled

    ' Get bearing to target and calculate drive correction
    bearing := TPA.GetBearing
    if bearing > 0
      error := ((bearing - 90) / 5)
      corr := ||error
      corr <#= 8
    else
      corr := 0
      
    ' Set speed or stop based on distance 
    if m_DistFwd < 16
      if rolling
        if corr > 1
          Drive.Halt
          Drive.SetSpeed(Drive#AllWheels, 12)
          Drive.GoDistance(Drive#AllWheels, -100)
          repeat while m_DistFwd < 18
          Drive.Halt
        else
          Drive.Halt
        speed := 0
        rolling := false
      next
    else
      speed := 12

    ' Steer towards the target
    if bearing > 0
      ' If we were not rolling, start up
      if rolling == false
        Drive.SetSpeed(Drive#AllWheels, speed)
        Drive.GoDistance(Drive#AllWheels, 1000)
        Pause_ms(500)
        rolling := true
        next

      ' Correct for any error              
      if corr > 0
        if error > 0
          ' Left turn
          Drive.SetSpeed(Drive#RightWheel, speed)
          Drive.SetSpeed(Drive#LeftWheel, speed - corr)
        else
          ' Right turn 
          Drive.SetSpeed(Drive#RightWheel, speed - corr)
          Drive.SetSpeed(Drive#LeftWheel, speed)
      else
        ' Straight ahead
        Drive.SetSpeed(Drive#AllWheels, speed)
      
    ' Avoid stuff here
'      if ina[Pin_ProxLeft] == 1
'        VeerRight(speed,300)
      
'      if ina[Pin_ProxRight] == 1
'         VeerLeft(speed,300)
     
    else
      Drive.Halt
      speed := 0
      rolling := false


PRI StopFM

  Drive.Halt
  TPA.Halt
  

' ------------------------------------------------------------------------------
' Beacon Navigation
' ------------------------------------------------------------------------------
PRI BeaconNav(Route) : status | idx,opcode

  ' Make sure we are not thermal tracking
  TPA.Halt
  TPA.Stop

  ' Initial ADF
  ADF.Start(Pin_IR, Pin_IrServo, Pin_Led)

  idx := 0
  opcode := 0

  repeat while opcode <> $FF
    if IsCanceled
      StopBNav
      return Ret_Canceled

    opcode := LONG[Route][idx]
    case opcode
      Op_GotoBeacon:
        status := GotoBeacon
        if status <> Ret_Complete
          StopBNav
          return Ret_Canceled
        idx++
        
      Op_Stop:
        StopBNav
        idx++

      Op_FindBeacon:
        idx++
        FindBeacon(LONG[Route][idx])
        idx++

      Op_Pause:
        ADF.Halt
        idx++
        Pause_ms(LONG[Route][idx])
        idx++

      Op_Repeat:
        idx := 0

      Op_LiftUp:
        LiftUp
        idx++

      Op_LiftDn:
        LiftDown
        idx++

  StopBNav
  

PRI GotoBeacon : status | speed,bearing,error,corr,rolling 

  if !m_LiftUp
    LiftUp
    
  ADF.SetScanRange(45,135)
  ADF.Scan

  rolling := false
  repeat
    if IsCanceled
      StopBNav
      return Ret_Canceled

    ' Set speed or stop based on distance 
    if m_DistFwd < 24
      StopBNav
      return Ret_Complete
    else
      speed := 12

    ' Steer towards the beacon
    bearing := ADF.GetBearing
    if bearing > 0
      ' Calculate drive correction
      error := ((bearing - 90) / 5)
      corr := ||error
      corr <#= 4
      
      ' If we were not rolling, start up
      if not rolling
        Drive.SetSpeed(Drive#AllWheels, speed)
        Drive.GoDistance(Drive#AllWheels, 1000)
        Pause_ms(500)
        m_CurrentDir := Mov_Fwd
        rolling := true
        next

      ' Correct for any error
      if corr > 0
        if error > 0
          ' Left turn
          Drive.SetSpeed(Drive#LeftWheel, speed - corr)
        else
          ' Right turn 
          Drive.SetSpeed(Drive#RightWheel, speed - corr)
      else
        ' Straight ahead
        Drive.SetSpeed(Drive#AllWheels, speed)
      
    else
      Drive.EmergencyHalt
      speed := 0
      rolling := false
     
           
PRI FindBeacon(Turn) | dir,timeout

  Drive.Halt

  ADF.Halt
  ADF.SetPosition(90)

  ' Move away from the current beacon
  if Turn == Mov_SpinCW
    Drive.SpinCW(270)
  else
    Drive.SpinCCW(270)
    
  Pause_ms(1000)

  ' Setup counter A for 5 second timeout
  timeout := clkfreq * 5
  ctra[30..26] := %11111
  frqa := 1
  phsa := 0

  ' Search for beacon for 5 seconds
  repeat while phsa < timeout
    if ina[Pin_IR] == 0
      quit

  ' Stop      
  Drive.EmergencyHalt


PRI StopBNav

  Drive.EmergencyHalt
  ADF.Halt
  

PRI IsCanceled : yesno

  yesno := false
  if GetHeader
    if GetCmd
      yesno := true
      
   
PRI SendSensorData

  RfLink.tx("<")
  RfLink.tx(NetID)
  RfLink.tx(DevID)

  RfLink.dec(m_DistFwd)
  RfLink.tx(",")
    
  if ina[Pin_ProxLeft] == 1
    RfLink.tx("L")
  else
    RfLink.tx("-")
              
  if ina[Pin_ProxRight] == 1
    RfLink.tx("R")
  else
    RfLink.tx("-")

  RfLink.tx(13)


' ------------------------------------------------------------------------------
' Lift Functions
' ------------------------------------------------------------------------------

PRI InitLift

  Pause_ms(10)
  PulseHB25(1500)
  Pause_ms(10)


PRI LiftUp

  if !m_LiftUp
    PowerOn
    
    PulseHB25(1050)
    Pause_ms(9000)
    PulseHB25(1500)

    m_LiftUp := true
  
    
PRI LiftDown

  if m_LiftUp
    Reset

    PulseHB25(1950)
    Pause_ms(8000)
    PulseHB25(1500)

    m_LiftUp := false

    PowerOff
  
    
PRI PulseHB25(pulse) | pwidth

  pwidth := ((pulse * (clkfreq / 1_000_000)) - 1200) #> 381  ' calculate pulse width

  outa[Pin_Lift]~~                                              
  waitcnt(pwidth + cnt)                                                
  outa[Pin_Lift]~                                                                           
  Pause_ms(5)


' ------------------------------------------------------------------------------
' Lift/Drive Power Functions
' ------------------------------------------------------------------------------

PRI PowerOn

  ' Energize the lift/drive power relay
  dira[Pin_Power]~~
  outa[Pin_Power]~~
  Pause_ms(1000)
  
  ' Initialize drive/position system (uses 1 cog)
  Drive.Start(Pin_Drive)

  ' Initialize lift motors controller (HB25)
  InitLift
  

PRI PowerOff
  
  ' De-energize the lift/drive power relay
  dira[Pin_Power]~~
  outa[Pin_Power]~
  Pause_ms(500)
  
  Drive.Stop

  
' ------------------------------------------------------------------------------
' Ping
' ------------------------------------------------------------------------------
PRI SensorScan | i,heading

  repeat
    if m_LiftUp
      m_DistFwd := Ping.Inches(Pin_PingHi)
    else
      m_DistFwd := 100

    Pause_ms(250)


PRI Pause_ms(msDelay)
  waitcnt(cnt + ((clkfreq / 1000) * msDelay))
      