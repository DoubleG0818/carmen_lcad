' File: GPS.spin
' Desc: To access the GPS unit: EM-408
' Detail:
'  * The GPS will receive data and process it right away
'  * Using command Get____ to get either raw data (add D/M/S at the back) or string (no back)
'  * comments using - or = extending is the important part to read or modify
CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000
  charCR = $0D
  charLF = $0A
  ColdStartTime = 42 'Cold start need 42s, Warm 38s, Hot 8s
  WarmStartTime = 38
  HotStartTime  = 8
  
OBJ
  SerialGPS: "FullDuplexSerial"
  'Terminal : "FullDuplexSerial"

VAR
  'COG Variables
  long cog
  long stack[100]

  byte rxpin
  byte txpin
  
  'GPS Variables
  byte Data[100]
  byte DataValid 'This is the overall data validity
  'byte DataValidChecksum 'This is data valid for checksum
  byte DataValidStream 'This is data valid coming from the GPS
  byte DataCounter
  byte MsgID[6]
     ' $GPGGA / $GPGLL / $GPGSA / $GPGSV / $GPRMC / $GPVTG
  byte UTCTimeHour ' The time from GPS unit
  byte UTCTimeMin  ' format: ddmmss.mmm
  byte UTCTimeSec
  word UTCTimeMiliSec
  byte LatitudeDD  ' north/south position
  byte LatitudeMM  ' format: ddmm.mmmm
  word LatitudeMMMM' range DD:0~180 MM:0-60 MMMM:0~9999
  byte NSIndicator
  byte LongitudeDD ' east/west position
  byte LongitudeMM ' format: ddmm.mmmm
  word LongitudeMMMM
  byte EWIndicator
  byte PositionFixIndicator
     ' 0 = Fix not avail/invalid
     ' 1 = GPS SPS
     ' 2 = Differential GPS SPS mode
     ' 3 = GPS PPS
  byte SatelliteUsed
  byte PrecisionDD
  byte PrecisionM
  long MSLAltitudeDD 'format: DD.M
  byte MSLAltitudeM  'range: 0.0 ~ unspecified
  byte MSLAltitudeSign 'plus = 0, minus = 1
  byte MSLAltitudeUnit
  long GeoidDD
  byte GeoidM
  byte GeoidSign
  byte GeoidUnit
  long SurfaceAltitudeDD
  byte SurfaceAltitudeM
  byte SurfaceAltitudeSign 
  byte SurfaceAltitudeUnit
  byte Units
  'byte RefStationID[4]
  'byte Checksum
  long SpeedDD
  byte SpeedMM
  long DirectionDD
  byte DirectionMM

PUB Start (rx, tx) : okay

  Stop
  okay := cog := cognew(StartGPS(rx, tx), @stack[0]) + 1
  
PUB Stop

  if cog
    cogstop(cog~ - 1)

PRI StartGPS (rx, tx)

  InitGPS (rx, tx)
  'Terminal.start (31, 30, 0, 115200) 'REMOVE ME

  'DisableGPS
  'EnableGPS
  DataValid := 1
  repeat
    ReceiveGPS
    'AverageData
'    SendToTerminal
    'waitcnt(clkfreq/2 + cnt)
    'waitcnt (clkfreq/10 + cnt) 'delay 1/2s      

PUB EnableGPS
  outa[11]~~
  
PUB DisableGPS
  outa[11]~
' The following functions are for getting the normal hex datas===========================================
'------------------------------------------------Time
PUB GetHour: GPShh
  if DataValid == 1
    GPShh := UTCTimeHour
  else
    GPShh := -1
PUB GetMin: GPSmm
  if DataValid == 1
    GPSmm := UTCTimeMin
  else
    GPSmm := -1
PUB GetSec: GPSss
  if DataValid == 1
    GPSss := UTCTimeSec
  else
    GPSss := -1
PUB GetMiliSec: GPSms
  if DataValid == 1
    GPSms := UTCTimeMiliSec
  else
    GPSms := -1
'-----------------------------------------------Longitude and Latitude
PUB GetLongitudeDD: DataOut
  if DataValid == 1
    DataOut := LongitudeDD
  else
    DataOut := -1
PUB GetLongitudeMM: DataOut
  if DataValid == 1
    DataOut := LongitudeMM
  else
    DataOut := -1
PUB GetLongitudeMMMM: DataOut
  if DataValid == 1
    DataOut := LongitudeMMMM
  else
    DataOut := -1

PUB GetLatitudeDD: DataOut
  if DataValid == 1
    DataOut := LatitudeDD
  else
    DataOut := -1
PUB GetLatitudeMM: DataOut
  if DataValid == 1
    DataOut := LatitudeMM
  else
    DataOut := -1
PUB GetLatitudeMMMM: DataOut
  if DataValid == 1
    DataOut := LatitudeMMMM
  else
    DataOut := -1

PUB GetLatitudeNS: DataOut
  if DataValid == 1
    DataOut := NSIndicator 
  else
    DataOut := -1  
PUB GetLongitudeEW: DataOut
  if DataValid == 1
    DataOut := EWIndicator 
  else
    DataOut := -1
'-----------------------------------------Satellite Seen
PUB GetSatelliteNumberD: DataOut
  if DataValid == 1
    DataOut := SatelliteUsed 
  else
    DataOut := -1
'-----------------------------------------Altitude
PUB GetAltitudeMSLDD: DataOut
  if DataValid == 1
    DataOut := MSLAltitudeDD 
  else
    DataOut := -1
PUB GetAltitudeMSLM : DataOut
  if DataValid == 1
    DataOut := MSLAltitudeM 
  else
    DataOut := -1
PUB GetAltitudeMSLSign : DataOut
  if DataValid == 1
    DataOut := MSLAltitudeSign 
  else
    DataOut := -1
PUB GetAltitudeMSLUnit : DataOut
  if DataValid == 1
    DataOut := MSLAltitudeUnit 
  else
    DataOut := -1
PUB GetAltitudeDD: DataOut
  if DataValid == 1
    DataOut := SurfaceAltitudeDD 
  else
    DataOut := -1
PUB GetAltitudeM : DataOut
  if DataValid == 1
    DataOut := SurfaceAltitudeM 
  else
    DataOut := -1
PUB GetAltitudeSign : DataOut
  if DataValid == 1
    DataOut := SurfaceAltitudeSign 
  else
    DataOut := -1
PUB GetAltitudeUnit : DataOut
  if DataValid == 1
    DataOut := SurfaceAltitudeUnit 
  else
    DataOut := -1

'------------------------------------------------------Precision Status
PUB GetPrecisionDD : DataOut
  if DataValid == 1
    DataOut := PrecisionDD 
  else
    DataOut := -1
PUB GetPrecisionM  : DataOut
  if DataValid == 1
    DataOut := PrecisionM 
  else
    DataOut := -1
'------------------------------------------------------Speed & Direction
PUB GetSpeedDD : DataOut
  if DataValid == 1
    DataOut := SpeedDD 
  else
    DataOut := -1  
PUB GetSpeedMM : DataOut 
  if DataValid == 1
    DataOut := SpeedMM 
  else
    DataOut := -1  
PUB GetDirectionDD : DataOut
  if DataValid == 1
    DataOut := DirectionDD 
  else
    DataOut := -1  
PUB GetDirectionMM : DataOut
  if DataValid == 1
    DataOut := DirectionMM 
  else
    DataOut := -1

' The following function is for getting string data======================================================

PUB GetTime : DataOut
  if DataValid == 1
    return @UTCTime
  else
    return @InvalidData

PUB GetLatitude : DataOut
  if DataValid == 1
    return @Latitude
  else
    return @InvalidData
    
PUB GetLongitude : DataOut
  if DataValid == 1
    return @Longitude
  else
    return @InvalidData

PUB GetPrecision : DataOut
  if DataValid == 1
    case PrecisionDD
      -1,0:
          return @InvalidData
      1:
        if PrecisionM == 0
          return @Precision1
        else
          return @Precision2
      2,3,4:
          return @Precision3
      5,6,7,8,9:
          return @Precision4
      10,11,12,13,14,15,16,17,18,19:
          return @Precision5
      20:
        if PrecisionM == 0
          return @Precision5
        else
          return @Precision6
      other:
          return @Precision6
  else
    return @InvalidData

PUB GetSatelliteNumber: DataOut | Temp
  if DataValid == 1
    if SatelliteUsed > 10
      BYTE[@SatelliteNumber][0] := "1"
      SatelliteUsed -= 10
      BYTE[@SatelliteNumber][1] := SatelliteUsed + $30
    else
      BYTE[@SatelliteNumber][0] := "0" 
      BYTE[@SatelliteNumber][1] := SatelliteUsed + $30
     
    return @SatelliteNumber 
  else
    return @InvalidData 
    
PUB InvalidateData '-->REMOVE ME<--------------------------
  DataValid := 0
   

  

PRI InitGPS(rx,tx) 'Initialization of GPS unit and enabling
  '  ┌P12─────RX┐
  'uP┤           ├GPS
  '  └P13─────TX┘
  ' Enable is in P11
  dira[11]~~   'Out - Enable
  'dira[12]~~   'Out - Rx to   GPS  
  'dira[13]~    'In  - Tx from GPS
  'SerialGPS.start( 13, 12, 0, 4800)
  rxpin := rx
  txpin := tx

  SerialGPS.start( rxpin, txpin, 0, 4800) 'This was set to port 3 to receive data
    'The initial design does not have a pull-up resistor, so the system didnt work
    '  the cable is rerouted to other available port
  'outa[12]~~
  EnableGPS
  'waitcnt (clkfreq * ColdStartTime + cnt)
   
  
  
PRI ReceiveGPS | DataIn, i, ii 'Receive datas from GPS
  i := 0
  DataIn := 0
  'enChkSum := 0
    
  
  repeat until DataIn == charLF
      DataIn := SerialGPS.rx 'Consider changing to rxcheck to avoid waiting for data
    'SendToTerminal(DataIn) '--------------------Test point
    ProcessData(DataIn)
    'CheckSum(DataIn)
    Data[i++] := DataIn 'Move datas to an array 
    'SendToTerminal(Data[i-1]) '-----------------------------Test point: output RAW data
    
  'repeat until DataIn == charLF
    'DataIn := SerialGPS.rx
    'Data[i++] := DataIn
    'SendToTerminal (DataIn[i-1])
    
  'Data[i] := 0
  'ii := 0
  'repeat i
    'SendToTerminal(Data[ii++])
'  Data[DataCounter++] := DataIn
'  if DataCounter == 50
'     DataCounter := 0

PRI ProcessData(DataIn)
  'Data counter is for counting the comma number
  if DataIn == "$"
    DataCounter := 0
  elseif DataIn == ","
    DataCounter++
  elseif DataIn == "*"
    DataCounter := -1
  elseif DataIn == charLF
    DataCounter := -1

  'Terminal.dec(DataCounter)
  'Terminal.tx(string(" "))

  if Data[3] == "G" AND Data[4] == "G" AND Data[5] == "A"
      ProcessGPGGA (DataIn)   'GGA : Global Positioning System Fixed Data
      'Terminal.str (string ("GPGGA Accessed",13))
  elseif Data[3] == "G" AND Data[4] == "L" AND Data[5] == "L"
      ProcessGPGLL (DataIn)   'GLL : Geographic Position-Latitude/Longitude
  elseif Data[3] == "G" AND Data[4] == "S" AND Data[5] == "A"
      ProcessGPGSA (DataIn)   'GSA : GNSS DOP and Active Satellites
  elseif Data[3] == "G" AND Data[4] == "S" AND Data[5] == "V"
      ProcessGPGSV (DataIn)   'GSV : GNSS Satellites in View
  elseif Data[3] == "R" AND Data[4] == "M" AND Data[5] == "C"
      ProcessGPRMC (DataIn)   'RMC : Recommended Minimum Specific GNSS Data
  elseif Data[3] == "V" AND Data[4] == "T" AND Data[5] == "G"
      ProcessGPVTG (DataIn)   'VTG : Course Over Ground and Ground Speed 

PRI ProcessGPGGA(DataIn) | Temp, CharNo, HexA, HexB, HexC, HexD, HexE
  'Temp := "X"
  'SendToTerminal (Temp)
  if DataIn == ","
    CharNo := 0  'Character numbering, 0 is the comma, useful for inits
    'Terminal.dec (0)
  else
    CharNo ++
    'Terminal.dec (CharNo)
  
  case DataCounter 
          'Sample Data GPGGA:
          '$GPGGA,161229.487,3723.2475,N,12158.3416,W,1,07,1.0,9.0,M,,,,0000*18
          '___________________________________________________
          '  Name       │   Sample   │ Units │ Description
          '─────────────┼────────────┼───────┼────────────────
      0:  'Message ID   │ $GPGGA     │       │ GGA protocol header
          '─────────────┼────────────┼───────┼────────────────
      1:  'UTC Time     │ 161229.487 │       │ hhmmss.sss
          case CharNo  '│            │       │   
            0:         '│            │       │
              UTCTimeHour    := 0'   │       │
              UTCTimeMin     := 0'   │       │
              UTCTimeSec     := 0'   │       │
              UTCTimeMiliSec := 0'   │       │              
            1:         '│            │       │
              HexA := DataIn
              BYTE[@UTCTime][0] := DataIn
            2:
              UTCTimeHour := StrHexToDec (HexA, DataIn)
              BYTE[@UTCTime][1] := DataIn
            3:
              HexB := DataIn
              BYTE[@UTCTime][3] := DataIn
            4:
              UTCTimeMin := StrHexToDec (HexB, DataIn)
              BYTE[@UTCTime][4] := DataIn
            5:
              HexC := DataIn
              BYTE[@UTCTime][6] := DataIn
            6:
              UTCTimeSec := StrHexToDec (HexC, DataIn)
              BYTE[@UTCTime][7] := DataIn
            7: 'dot
            8:
              HexA := DataIn
              BYTE[@UTCTime][9] := DataIn
            9:
              HexB := DataIn
              BYTE[@UTCTime][10] := DataIn
            10:
              UTCTimeMiliSec := StrHextoDecWord ("0",HexA, HexB, DataIn)
              BYTE[@UTCTime][11] := DataIn
          '─────────────┼────────────┼───────┼────────────────
      2:  'Latitude     │ 3723.2475  │       │ ddmm.mmmm
          case CharNo
            0: 'Comma
              LatitudeDD   := 0
              LatitudeMM   := 0
              LatitudeMMMM := 0 
            1:
              HexA := DataIn
            2:
              'LatitudeDD := StrHexToDec (HexA, DataIn)
              'Terminal.dec (LatitudeDD) '--------------------test point
              HexB := DataIn 
            3:
              HexC := DataIn
            4:
              'LatitudeMM := StrHexToDec (HexA, DataIn)
              'Terminal.dec (LatitudeMM) '--------------------test point
              if DataIn == "." ' if the data set:  DMM.MMMM
                LatitudeDD := StrHexToDec ( "0", HexA)
                LatitudeMM := StrHexToDec (HexB, HexC)
                CharNo:= 10   'this is the dot
                BYTE[@Latitude][0] := " "  '  __A°BC.0000'  <==========================change " " to "0"
                BYTE[@Latitude][1] := " "
                BYTE[@Latitude][2] := HexA
                BYTE[@Latitude][4] := HexB
                BYTE[@Latitude][5] := HexC 
              else
                HexD := DataIn
            5:
              if DataIn == "." ' if the data set: DDMM.MMMM
                LatitudeDD := StrHexToDec (HexA, HexB)
                LatitudeMM := StrHexToDec (HexC, HexD)
                CharNo := 10  'this is the dot
                BYTE[@Latitude][0] := " "  '  _AB°CD.0000'
                BYTE[@Latitude][1] := HexA
                BYTE[@Latitude][2] := HexB 
                BYTE[@Latitude][4] := HexC
                BYTE[@Latitude][5] := HexD   
              else             ' if the data set: DDDMM.MMMM
                LatitudeDD := StrHexToDecWord ("0",HexA, HexB, HexC)
                LatitudeMM := StrHexToDec (HexD, DataIn)
                CharNo := 9   'the dot is the next char
                BYTE[@Latitude][0] := HexA  '  ABC°DE.0000'
                BYTE[@Latitude][1] := HexB
                BYTE[@Latitude][2] := HexC 
                BYTE[@Latitude][4] := HexD
                BYTE[@Latitude][5] := DataIn                 
            10: 'the dot
            11:
              HexA := DataIn
              BYTE[@Latitude][7] := DataIn
            12:
              HexB := DataIn
              BYTE[@Latitude][8] := DataIn 
            13:
              HexC := DataIn
              BYTE[@Latitude][9] := DataIn
            14:
              LatitudeMMMM := StrHextoDecWord (HexA, HexB, HexC, DataIn)
              BYTE[@Latitude][10] := DataIn
              'Terminal.tx(string("."))
              'Terminal.dec(LatitudeMMMM) '--------------------test point 
             
          '─────────────┼────────────┼───────┼────────────────
      3:  'N/S Indicator│ N          │       │ N=north or S=south
          if CharNo == 1
            NSIndicator := DataIn             
          else
            NSIndicator := "-"
          BYTE[@Latitude][13] := NSIndicator
          '─────────────┼────────────┼───────┼────────────────
      4:  'Longitude    │ 12158.3416 │       │ dddmm.mmmm
          case CharNo
            0: 'Comma
              LongitudeDD   := 0
              LongitudeMM   := 0
              LongitudeMMMM := 0 
            1:
              HexA := DataIn
            2:
              'LongitudeDD := StrHexToDec (HexA, DataIn)
              'Terminal.dec (LatitudeDD) '--------------------test point
              HexB := DataIn 
            3:
              HexC := DataIn
            4:
              'LongitudeMM := StrHexToDec (HexA, DataIn)
              'Terminal.dec (LatitudeMM) '--------------------test point
              if DataIn == "." ' if the data set:  DMM.MMMM
                LongitudeDD := StrHexToDec ( "0", HexA)
                LongitudeMM := StrHexToDec (HexB, HexC)
                CharNo:= 10   'this is the dot
                BYTE[@Longitude][0] := " "  '  __A°BC.0000'  <==========================change " " to "0"
                BYTE[@Longitude][1] := " "
                BYTE[@Longitude][2] := HexA
                BYTE[@Longitude][4] := HexB
                BYTE[@Longitude][5] := HexC 
              else
                HexD := DataIn
            5:
              if DataIn == "."  ' if the data set:  DDMM.MMMM
                LongitudeDD := StrHexToDec (HexA, HexB)
                LongitudeMM := StrHexToDec (HexC, HexD)
                CharNo := 10  'this is the dot
                BYTE[@Longitude][0] := " "  '  _AB°CD.0000'
                BYTE[@Longitude][1] := HexA
                BYTE[@Longitude][2] := HexB 
                BYTE[@Longitude][4] := HexC
                BYTE[@Longitude][5] := HexD  
              else              ' if the data set:  DDDMM.MMMM
                LongitudeDD := StrHexToDecWord ("0",HexA, HexB, HexC)
                LongitudeMM := StrHexToDec (HexD, DataIn)
                CharNo := 9   'the dot is the next char
                BYTE[@Longitude][0] := HexA  '  ABC°DE.0000'
                BYTE[@Longitude][1] := HexB
                BYTE[@Longitude][2] := HexC 
                BYTE[@Longitude][4] := HexD
                BYTE[@Longitude][5] := DataIn
            10: 'dot 
            11:
              HexA := DataIn
              BYTE[@Longitude][7] := DataIn
            12:
              HexB := DataIn
              BYTE[@Longitude][8] := DataIn 
            13:
              HexC := DataIn
              BYTE[@Longitude][9] := DataIn
            14:
              LongitudeMMMM := StrHextoDecWord (HexA, HexB, HexC, DataIn)
              BYTE[@Longitude][10] := DataIn
              'Terminal.tx(string("."))
              'Terminal.dec(LatitudeMMMM) '--------------------test point
          '─────────────┼────────────┼───────┼────────────────
      5:  'E/W Indicator│ W          │       │ E=east or W=west
          if CharNo == 1
            EWIndicator := DataIn
          else
            EWIndicator := "-"
          BYTE[@Longitude][13] := EWIndicator      
          '─────────────┼────────────┼───────┼────────────────
      6:  'Position Fix │ 1          │       │ '0 = Fix not avail/invalid     │ 1 = GPS SPS 
          ' Indicator   │            │       │ '2 = Differential GPS SPS mode │ 3 = GPS PPS
          if CharNo == 1
            PositionFixIndicator := DataIn - $30
          else
            PositionFixIndicator := -1
          '─────────────┼────────────┼───────┼────────────────
      7:  'Satellites   │ 07         │       │ Range 0 to 12
          ' Used        │            │       │
          if CharNo == 1
            HexA := DataIn
          elseif CharNo == 2
            SatelliteUsed := StrHextoDec( HexA, DataIn )
          else
            SatelliteUsed := -1
          '─────────────┼────────────┼───────┼────────────────
      8:  'HDOP         │ 1.0        │       │ Horizontal Dilution of Precision
          case CharNo
            0: 'comma
              PrecisionDD := 0
              PrecisionM  := 0
              Temp := 0
            1,2,3,4,5,6,7,8,9:
              if DataIn == "."
                CharNo := 10
                PrecisionDD := Temp
              else
                Temp := (Temp * 10) + StrHextoHalfByteHex(DataIn) 
            10: 'dot
            11:
              PrecisionM := StrHextoHalfByteHex(DataIn)
          '─────────────┼────────────┼───────┼────────────────
      9:  'MSL Altitude │ 9.0        │meters │
          case CharNo
            0: 'comma
              MSLAltitudeDD := 0
              MSLAltitudeM  := 0
              MSLAltitudeSign := 0
              Temp := 0
            1: 'there is a probability it has minus sign
              if DataIn == "-"
                MSLAltitudeSign := 1
              else
                Temp := StrHextoHalfByteHex(DataIn)
            2,3,4,5,6,7,8,9: 'assuming the altitude maxed at 999,999,999.9 or -99,999,999.9
              if DataIn == "."
                CharNo := 10
                MSLAltitudeDD := Temp
              else
                Temp := (Temp * 10) + StrHextoHalfByteHex(DataIn) 
            10: 'the dot
            11:
              MSLAltitudeM := StrHextoHalfByteHex(DataIn) 
              
          '─────────────┼────────────┼───────┼────────────────
      10: 'Units        │ M          │meters │
          case CharNo
            1:
              MSLAltitudeUnit := DataIn
            other:
              MSLAltitudeUnit := "-"
          '─────────────┼────────────┼───────┼────────────────
      11: 'Geoid        │            │meters │
          ' Separation  │            │       │
          case CharNo
            0: 'comma
              GeoidDD := 0
              GeoidM  := 0
              GeoidSign := 0
              Temp := 0
            1: 'there is a probability it has minus sign
              if DataIn == "-"
                GeoidSign := 1
              else
                Temp := StrHextoHalfByteHex(DataIn)
            2,3,4,5,6,7,8,9: 'assuming the altitude maxed at 999,999,999.9 or -99,999,999.9
              if DataIn == "."
                CharNo := 10
                GeoidDD := Temp
              else
                Temp := (Temp * 10) + StrHextoHalfByteHex(DataIn) 
            10: 'the dot
            11:
              GeoidM := StrHextoHalfByteHex(DataIn)
              CalculateAltitude
          '─────────────┼────────────┼───────┼──────────────── 
      12: 'Units        │ M          │meters │
          case CharNo
            1:
              GeoidUnit := DataIn
            other:
              GeoidUnit := "-" 
          '─────────────┼────────────┼───────┼────────────────
      13: 'Age of Diff. │            │second │ Null fields when DGPS is not used
          ' Corr.       │            │       │
          '─────────────┼────────────┼───────┼────────────────
      14: 'Diff. Ref.   │ 0000       │       │
          ' Station ID  │            │       │
          '─────────────┼────────────┼───────┼────────────────
      15: 'Checksum     │ *18        │       │
          '             │ <CR><LF>   │       │ End of message termination
     
PRI ProcessGPGLL(DataIn) | Temp, CharNo, HexA, HexB, HexC, HexD, HexE 'TODO: the gps doesnt give this data 
  if DataIn == ","
    CharNo := 0  'Character numbering, 0 is the comma, useful for inits
  else
    CharNo ++

  case DataCounter

        '$GPGLL,3723.2475,N,12158.3416,W,161229.487,A*2C
        'Name          │Example    │ Description
    0:  'Message ID    │ $GPGLL    │ GLL protocol header
    1:  'Latitude      │ 3723.2475 │ ddmm.mmmm
    2:  'N/S Indicator │ N         │ N=north or S=south
    3:  'Longitude     │ 12158.3416│ dddmm.mmmm
    4:  'E/W Indicator │ W         │ E=east or W=west
    5:  'UTC Position  │ 161229.487│ hhmmss.sss
    6:  'Status        │ A         │ A=data valid or V=data not valid
        'Checksum      │ *2C       │
        '              │ <CR><LF>  │ End of message termination 
         
PRI ProcessGPGSA(DataIn) 'TODO: Not important
  '$GPGSA,A,3,07,02,26,27,09,04,15,,,,,,1.8,1.0,1.5*33
  'Message ID $GPGSA GSA protocol header
  'Mode1 A See Table B-6
               ' M Manual-forced to operate in 2D or 3D mode
               ' A 2D automatic-allowed to automatically switch 2D/3D
  'Mode2 3 See Table B-7
               ' 1 Fix Not Available
               ' 2 2D
               ' 3 3D
  'Satellite Used1 07 Sv on Channel 1
  'Satellite Used1 02 Sv on Channel 2
  '.
  'Satellite Used1 Sv on Channel 12
  'PDOP 1.8 Position dilution of Precision
  'HDOP 1.0 Horizontal dilution of Precision
  'VDOP 1.5 Vertical dilution of Precision
  'Checksum *33
  '<CR><LF> End of message termination
PRI ProcessGPGSV(DataIn) 'TODO: not important
  '$GPGSV,2,1,07,07,79,048,42,02,51,062,43,26,36,256,42,27,27,138,42*71
  '$GPGSV,2,2,07,09,23,313,42,04,19,159,41,15,12,041,42*41
  'Message ID $GPGSV GSV protocol header
  'Number of Messages1 2 Range 1 to 3
  'Message Number1 1 Range 1 to 3
  'Satellites in View 07
  'Satellite ID 07 Channel 1(Range 1 to 32)
  'Elevation 79 degrees Channel 1(Maximum90)
  'Azimuth 048 degrees Channel 1(True, Range 0 to 35
  'SNR(C/No) 42 dBHz Range 0 to 99,null when not tra
  '........
  'Satellite ID 27 Channel 4 (Range 1 to 32)
  'Elevation 27 Degrees Channel 4(Maximum90)
  'Azimuth 138 Degrees Channel 4(True, Range 0 to 35
  'SNR(C/No) 42 dBHz Range 0 to 99,null when not tra
  'Checksum *71
  '<CR><LF> End of message termination
PRI ProcessGPRMC(DataIn) | Temp, CharNo, HexA, HexB, HexC, HexD, HexE 'TODO: get lat,long
  if DataIn == ","
    CharNo := 0  'Character numbering, 0 is the comma, useful for inits
  else
    CharNo ++

  case DataCounter

        '$GPRMC,161229.487,A,3723.2475,N,12158.3416,W,0.13,309.62,120598,,*10
        'Name Example Units Description
    0:  'Message ID $GPRMC RMC protocol header
    1:  'UTC Time 161229.487 hhmmss.sss
    2:  'Status A A=data valid or V=data not valid
          if CharNo == 1
            DataValidStream := DataIn
          else
            DataValidStream := "V"      

    3:  'Latitude 3723.2475 ddmm.mmmm
    4:  'N/S Indicator N N=north or S=south
    5:  'Longitude 12158.3416 dddmm.mmmm
    6:  'E/W Indicator W E=east or W=west
    7:  'Speed Over Ground 0.13 knots
                      'SpeedDD SpeedMM  DirectionDD DirectionMM
          case CharNo
            0: 'comma
              SpeedDD := 0
              SpeedMM := 0
              Temp := 0
            1,2,3,4,5,6,7,8,9: 'assuming the altitude maxed at 999,999,999.9
              if DataIn == "."
                CharNo := 10
                SpeedDD := Temp
              else
                Temp := (Temp * 10) + StrHextoHalfByteHex(DataIn) 
            10: 'the dot
            11:
              HexA := DataIn
            12:
              SpeedMM := StrHexToDec(HexA,DataIn) 
    8:  'Course Over Ground 309.62 degrees True
          case CharNo
            0: 'comma
              DirectionDD := 0
              DirectionMM := 0
              Temp := 0
            1,2,3,4,5,6,7,8,9: 'assuming the altitude maxed at 999,999,999.9
              if DataIn == "."
                CharNo := 10
                DirectionDD := Temp
              else
                Temp := (Temp * 10) + StrHextoHalfByteHex(DataIn) 
            10: 'the dot
            11:
              HexA := DataIn
            12:
              DirectionMM := StrHexToDec(HexA,DataIn)     
    9:  'Date 120598 ddmmyy
    10: 'Magnetic Variation2 degrees E=east or W=west
        'Checksum *10
        '<CR><LF> End of message termination

PRI ProcessGPVTG(DataIn) 'TODO: get speed,degree  ** gps doesnt give this data
  '$GPVTG,309.62,T,,M,0.13,N,0.2,K*6E
  'Name Example Units Description
  'Message ID $GPVTG VTG protocol header
  'Course 309.62 degrees Measured heading
  'Reference T True
  'Course degrees Measured heading
  'Reference M Magnetic
  'Speed 0.13 knots Measured horizontal speed
  'Units N Knots
  'Speed 0.2 Km/hr Measured horizontal speed
  'Units K Kilometers per hour
  'Checksum *6E
  '<CR><LF> End of message termination


PRI CheckSum(DataIn) | ChkSumMaster, ChkSumSlave, enChkSum
  ' The Checksum calculation
  '   enChkSum value:
  '   0 = before new data, init
  '   1 = between $ and * (both char are not included), calculating the checksum
  '   2 = the *
  '   3&4 = the 2 checksum characters
  '   5 = making sure the data is valid
  
  case enChkSum  
    0: 'Before $ sign
      ChkSumMaster := 0
    1: 'Calculate Checksum 
      if DataIn == "*" 'Stop checksum calculation
        enChkSum := 2
      else
        ChkSumMaster ^= DataIn '<-- Current Checksum XOR New Data
    2: 'The * sign, stop checksum calculation
      enChkSum := 3
    3: 'First char
      ChkSumSlave := StrHextoHalfByteHex(DataIn)
      ChkSumSlave <<= 4
      enChkSum := 4
    4: 'Second char
      ChkSumSlave := ChkSumSlave + StrHextoHalfByteHex(DataIn)
      enChkSum := 5
    5: 'Checking validity of checksum
      if ChkSumMaster == ChkSumSlave
        DataValid := 1
      else
        DataValid := 0    
    other: '---- Invalid condition
      enChkSum := 0
         
  if DataIn == "$" 'Start checksum calculation, override all previous condition
    enChkSum := 1

'  Terminal.hex(ChkSumMaster,2)
'  Terminal.hex(ChkSumSlave,2)

 

'PRI SendToTerminal (DataSendTerminal) 'For testing purpose only<========================
  'Terminal.tx(DataSendTerminal)
  
PRI StrHextoHalfByteHex ( StrHex ) : HalfByteHex | Temp  ' Convert single character hex string to half hex
  if StrHex < $3A AND StrHex > $2F 'Normal number 0-9
    Temp := StrHex & $0F
  elseif StrHex < $47 AND StrHex > $40 'Capital letters A-F
    Temp := (StrHex & $0F) + 9
  elseif StrHex < $67 AND StrHex > $61 'Non-capital letters a-f
    Temp := (StrHex & $0F) + 9
  else
    Temp := -1 'Invalid

  HalfByteHex := (Temp & $0F)

PRI StrHextoDec ( HexDataHigh,HexDataLow ) : DecData | Temp 'Convert 2 hex character numbers to 1 decimal
  if HexDataHigh < $3A AND HexDataHigh > $2F AND HexDataLow < $3A AND HexDataLow > $2F 'Both are normal numbers 0-9
    Temp := ((HexDataHigh - $30) * 10) + (HexDataLow - $30)
  else
    Temp := -1 'Invalid

  DecData := Temp

PRI StrHextoDecWord (HexA, HexB, HexC, HexD) : DecWord | Temp
  if HexA < $3A AND HexA > $2F AND HexB < $3A AND HexB > $2F AND HexC < $3A AND HexC > $2F AND HexD < $3A AND HexD > $2F 'All four are normal numbers 0-9
    Temp :=         (HexA - $30)  * 10  'Result:  00A0   (these are in base10, not base16)
    Temp := (Temp + (HexB - $30)) * 10  'Result:  0AB0
    Temp := (Temp + (HexC - $30)) * 10  'Result:  ABC0
    Temp :=  Temp + (HexD - $30)        'Result:  ABCD
  else
    Temp := -1

  DecWord := Temp

PRI CalculateAltitude | Temp1, Temp2, ResultA
  ' MSLAltitudeDD MSLAltitudeM MSLAltitudeSign 'plus = 0, minus = 1
  ' GeoidDD GeoidM GeoidSign
  ' SurfaceAltitudeDD SurfaceAltitudeM SurfaceAltitudeSign
  Temp1 := (MSLAltitudeDD * 10) + MSLAltitudeM
  Temp2 := (GeoidDD * 10) + GeoidM
  
  if     MSLAltitudeSign ==  0 AND GeoidSign ==  0
    ResultA := Temp1 + Temp2
  elseif MSLAltitudeSign ==  0 AND GeoidSign ==  1
    ResultA := Temp1 - Temp2
  elseif MSLAltitudeSign ==  1 AND GeoidSign ==  0
    ResultA := Temp2 - Temp1
  elseif MSLAltitudeSign ==  1 AND GeoidSign ==  1
    ResultA := 0 - Temp1 - Temp2
     
  SurfaceAltitudeDD := ResultA/10  'div 10
  SurfaceAltitudeM  := ResultA//10 'mod 10 
  SurfaceAltitudeSign := 0  
  if ResultA < 0
    SurfaceAltitudeSign := 1
  if MSLAltitudeUnit == GeoidUnit
    SurfaceAltitudeUnit := GeoidUnit
  else
    SurfaceAltitudeUnit := "?"
   
   

'TODO:
'PRI AverageData 'Data Averaging
  

DAT                    '                   1         2
                       'byte no: 012345678901234567890
  UTCTime               byte    "00:00:00.000",0   '  dd:mm:ss.mmm
  Latitude              byte    "  0°00.0000' -",0 ' ddd°mm.mmmm' <N/S> 
  Longitude             byte    "  0°00.0000' -",0 ' ddd°mm.mmmm' <E/W> 
  InvalidData           byte    "Invalid",0
  Precision1            byte    "Ideal",0       '1.0 only    > Precision Ratings
  Precision2            byte    "Excellent",0   '1.1~1.9     > based on Wikipedia
  Precision3            byte    "Good",0        '2.0~4.9     > see http://en.wikipedia.org/wiki/Dilution_of_precision_(GPS)
  Precision4            byte    "Moderate",0    '5.0~9.9     >
  Precision5            byte    "Fair",0        '10.0~20.0   >
  Precision6            byte    "Poor",0        '>20.0       >
  SatelliteNumber       byte    "00",0
  
'Programmer's Note:

'TODO: Send command: (not required)
  'TODO: Input Commands ?
  'TODO: Parameters required to start ?
  'TODO: Set Port B parameter for DGPS input ???
  'TODO: Make the GPS's baudrate higher

'TODO: Receive data:
  'TODO: Separate things: 
  'DONE: Take Longitude Latitude
  'DONE: Speed (x.xx knots / x.x km/hr)
  'TODO: Elevation(0~90 degree)
  'DONE: Course (0~359.99 degree)
  'DONE: Take number of satellites connected
  'DONE: Checksum checking

'TODO: Data processing:
  'TODO: filter

'TODO: Interface:
  'DONE: Give Time
  'DONE: Give Altitude
  'DONE: Give Longitude Latitude
  'DONE: Give Speed

'TOOD: Fixes
  'DONE: Time string func
  'DONE: Long/Lat string func
  'DONE: precision
  'DONE: number satelite
  'TODO: speed and direction


' GPS Tutorial http://www.kronosrobotics.com/Projects/GPS.shtml
' Teh GPS http://www.sparkfun.com/commerce/product_info.php?products_id=8234
' Teh LED Matrix http://www.sparkfun.com/commerce/product_info.php?products_id=760
' Teh Serial LCD Display http://www.sparkfun.com/commerce/product_info.php?products_id=8884
' Teh Compass http://www.sparkfun.com/commerce/product_info.php?products_id=418