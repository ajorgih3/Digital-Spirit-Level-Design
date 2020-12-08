;; org.asm file
;; NOTE: I am implementing this with the old version of SQGen
;;		 going to modify it with SQGen+ (meme name by David)
;; I am also using a 100kHz clock for SqGen, so if the speaker sounds 
;; like its tryna kill itself then it might be because yall's SqGen is using 
;; a 10kHz clock

ORG 0

;; this loop right here just prints out ECE 2031 as shown in the 
;; 7 segment display
Print: 
	;; this loop right here just prints out ECE 2031 as shown in the 
;; 7 segment display
Playfirst:	
	LOADI 0
	OUT SqGen 
	LOAD Elec 
	OUT Hex0
	LOADI 0 
	OUT Hex1
	; plays the note C2 indicateing for a user input 
	LOAD G6
	ADDI 10
	CALL PlayNote
	JUMP Playsecond

Playthird:
	LOADI 0
	OUT SqGen 
	LOAD Elec 
	OUT Hex0
	LOADI 0 
	OUT Hex1
	LOAD  E5
	ADDI 10
	CALL PlayNote
	JUMP Playfourth
	
Playfifth:
    LOADI 0
	OUT SqGen 
	LOAD Elec 
	OUT Hex0
	LOADI 0 
	OUT Hex1
	LOAD C5
	ADDI 10
	CALL PlayNote
	JUMP Playsixth
	
Playseven:
	LOADI 0
	OUT SqGen 
	LOAD Elec 
	OUT Hex0
	LOADI 0 
	OUT Hex1
	LOAD B4
	ADDI 10
	CALL PlayNote 
	JUMP Playeigth

Playsecond:	
	;; loads 2031 to 7 segs
	LOAD twentythirtyone
	OUT Hex0
	;; plays the note C5 indicating for a user input
	LOAD F5
	ADDI 10
	CALL PlayNote
	JUMP Playthird

Playfourth:
	;; loads 2031 to 7 segs
	LOAD twentythirtyone
	OUT Hex0
	LOAD D5
	ADDI 10
	CALL PlayNote 
	JUMP Playfifth
	
Playsixth:
	;; loads 2031 to 7 segs
	LOAD twentythirtyone
	OUT Hex0
	LOAD G4
	ADDI 10 
	CALL PlayNote 
	JUMP Playseven
	
Playeigth:
	;; loads 2031 to 7 segs
	LOAD twentythirtyone
	OUT Hex0
	LOAD A4
	ADDI 10
	CALL PlayNote 
	JUMP Lowfreq
	
Lowfreq:
	LOAD c2display
	OUT Hex0
	LOAD C2
	ADDI 0
	CALL PlayNote 
	
	
	;; this is when SCOMP requests an IO data from the switches
	;; the values from the switches are then transmitted to the LEDs
	;; where it shows which switch is currently on
	IN Switches 
	OUT LEDs
	
	;; stores the information of a particular switch
	;; loads it and if that particular switch is ON 
	;; jump to different game modes
	STORE Switch9
	LOAD Switch9 
	AND Bit9
	JPOS GameModeA
	
	;; proceed to GameModeB
	IN Switches 
	OUT LEDs
	STORE Switch8
	LOAD Switch8
	AND Bit8
	JPOS GameModeB
	
	;; proceed to GameModeC
	IN Switches 
	OUT LEDs
	STORE Switch7
	LOAD Switch7
	AND Bit7
	JPOS GameModeC
	
	;; proceed to GameModeC
	IN Switches 
	OUT LEDs
	STORE Switch6
	LOAD Switch6
	AND Bit6
	JPOS CombinationGameModeD
	
	;; proceed to Error
	IN Switches 
	OUT LEDs
	STORE Switch5
	LOAD Switch5
	AND Bit5
	JPOS Error1
	
	;; proceed to Error
	IN Switches 
	OUT LEDs
	STORE Switch4
	LOAD Switch4
	AND Bit4
	JPOS Error2
	
	;; proceed to Error
	IN Switches 
	OUT LEDs
	STORE Switch3
	LOAD Switch3
	AND Bit3
	JPOS Error3
	
	;; proceed to GameModeSolution
	IN Switches 
	OUT LEDs
	STORE Switch2
	LOAD Switch2
	AND Bit2
	JPOS GameModeSolution
	
	;; proceed to the EasterEgg
	IN Switches 
	OUT LEDs
	STORE Switch1
	LOAD Switch1
	AND Bit1
	JPOS EasterEgg
	
	;; jumps back to print if the user did not input anything
	JUMP Lowfreq

Elec: DW &B0000111011001110
twentythirtyone: DW &B0010000000110001
c2display: DW &B0000000011000010
	
;; Debugging purposes
TestGame:
	LOAD C5
	ADDI 20
	CALL PlayNote
	JUMP TestGame


; note C7
C7: DW &B0000110000000000


;; this calls the acceleormeter, reads X and Y values, calculates L2Norm
;; we could just take the X and Y values and manipulate it from there
;; but maybe this could be a game mode	
GameModeA:
	IN Switches
	OUT LEDs
	LOADI &H0A
	OUT Hex1
	;LOADI 0
	;OUT SqGen
	CALL SetupI2C
	CALL ReadX
	STORE XValue
	STORE L2A
	CALL ReadY
	STORE YValue
	STORE L2B
	CALL L2Estimate
	STORE d16sN
	LOADI 64
	STORE d16sD
	CALL Div16s
	LOAD dres16sQ
	;; if the value claimed from the accelerometer is 0 
	;; then jump to the zero loop
	LOAD XValue
	STORE d16sN
	LOADI 16
	STORE d16sD
	CALL Div16s
	LOAD dres16sQ
	SHIFT 10
	CALL Abs
	STORE NoteOut
	JZERO FlatX
	
	LOAD YValue
	CALL Abs
	AND DurationMaskC
	SHIFT -4
	ADD NoteOut
	CALL PlayNote
	;JZERO ZEROO
	OUT Hex0

RestOfA:	
	;; again, stores the information of the switches to the SCOMP
	;; sends it to the LEDs 
	;; if switch0 is HIGH, freeze the last value claimed from the accelerometer
	IN Switches
	;OUT LEDs
	;STORE Switch0
	;LOAD Switch0
	AND Bit0
	JPOS Freeze
	
	;; If Switch9 is lowered then return back to print
	IN Switches
	;OUT LEDs
	;STORE Switch9
	;LOAD Switch9
	;AND Bit9
	JZERO Print
	
	;; jump back to game mode A to 
	JUMP GameModeA

FlatX:
	ADD FudgeFactor
	STORE NoteOut
	IN Switches
	OUT LEDs
	LOAD YValue
	CALL Abs
	AND DurationMaskC
	SHIFT -4
	ADD NoteOut
	CALL PlayNote
	
	JUMP RestOfA

NoteOut: DW &B0
XValue: DW &B0
YValue: DW &B0
;; x value to the accelerometer 

;; x value to the accelerometer 
GameModeB: 
	IN Switches
	OUT LEDs
	LOADI &H0B
	OUT Hex1
	;LOADI 0
	;OUT SqGen
	CALL SetupI2C
	CALL ReadX
	;STORE L2A
	;LOAD L2A
	STORE d16sN
	LOADI 16
	STORE d16sD
	CALL Div16s
	LOAD dres16sQ
	SHIFT 10
	CALL Abs
	
	AND PitchMaskB
	JZERO Flat
	;ADDI 1
	CALL PlayNote
	OUT Hex0
	
	;; again, stores the information of the switches to the SCOMP
	;; sends it to the LEDs 
	;; if switch0 is HIGH, freeze the last value claimed from the accelerometer
	IN Switches
	OUT LEDs
	;STORE Switch0
	;LOAD Switch0
	AND Bit0
	JPOS Freeze
	
	;; reset
	IN Switches
	OUT LEDs
	;STORE Switch8
	;LOAD Switch8
	;AND Bit8
	JZERO Print
	
	;; JUMP back to gameModeB if there is no user input
	JUMP GameModeB

Flat:
	ADD FudgeFactor
	Call PlayNote
Wait:
	LOADI 1
	CALL DelayAC
	IN Switches
	OUT LEDs
	CALL SetupI2C
	CALL ReadX
	STORE d16sN
	LOADI 16
	STORE d16sD
	CALL Div16s
	LOAD dres16sQ
	SHIFT 10
	CALL Abs

	;AND PitchMaskB
	JZERO Wait
	
	IN Switches 
	OUT LEDs
	JZERO Print
	
	AND Bit0
	JPOS Freeze
	
	JUMP GameModeB
	
	
DurationDeletor: DW &B1111111111000000
PitchMaskB: DW &B1111111111000000
FudgeFactor: DW &B0000001111000000

	
;; y value to the accelerometer 
;; tilt the board and increase the value of the duration
GameModeC: 

	;; okay so this part is kind of rough, so what i did 
	;; is basically get the most stable values of the increase from readX and readY
	;; and what we want to do is tkae those values and shift them to the right by 4 
	;; so we can see a stable increase in duration
	LOADI &H0C
	OUT Hex1
	;LOADI 0
	;OUT SqGen
	CALL SetupI2C
	CALL ReadY
	SHIFT 6
	CALL Abs
	SHIFT -6
	;STORE L2B
	
	;; this is the step where you get the values in the middle of being stable
	;LOAD L2B
	AND DurationMaskC
	SHIFT -4
	ADD C5
	;STORE L2B
	OUT Hex0
	;LOAD L2B
	CALL PlayNote
	
	;; again, stores the information of the switches to the SCOMP
	;; sends it to the LEDs 
	;; if switch0 is HIGH, freeze the last value claimed from the accelerometer
	IN Switches
	OUT LEDs
	;STORE Switch0
	;LOAD Switch0
	AND Bit0
	JPOS Freeze
	
	;; reset
	IN Switches
	OUT LEDs
	;STORE Switch7
	;LOAD Switch7
	;AND Bit7
	JZERO Print
	
	
	JUMP GameModeC
	
DurationMaskC: DW &B0000001111110000

CombinationGameModeD:
	
	LOADI &H0D
	OUT Hex1
	
	CALL ReadX
	STORE L2A
	CALL ReadY
	STORE L2B
	LOAD L2A
	AND DurationMaskC
	SHIFT 5
	AND DurationDeletor
	STORE L2A
	LOAD L2A
	CALL Abs
	STORE L2A
	LOAD L2B
	AND DurationMaskC
	SHIFT -4
	STORE L2B
	LOAD L2A
	ADD	 L2B
	STORE L2C
	LOAD L2C
	OUT Hex0
	CALL PlayNote
	
	;; again, stores the information of the switches to the SCOMP
	;; sends it to the LEDs 
	;; if switch0 is HIGH, freeze the last value claimed from the accelerometer
	IN Switches
	OUT LEDs
	STORE Switch0
	LOAD Switch0
	AND Bit0
	JPOS Freeze
	
	;; reset
	IN Switches
	OUT LEDs
	STORE Switch6
	LOAD Switch6
	AND Bit6
	JZERO Print
	
	JUMP CombinationGameModeD

;; christmas song for KJ
EasterEgg:
	
	LOADI &HFF
	OUT Hex1
	
	LOAD G4
	OUT SqGen 
	OUT Hex0
	LOADI 5
	CALL DelayAC
	
	LOAD C5
	OUT SqGen 
	OUT Hex0
	LOADI 5
	CALL DelayAC
	
	LOADI 0
	OUT SqGen 
	OUT Hex0
	LOADI 1
	CALL DelayAC
	
	LOAD C5
	OUT SqGen 
	OUT Hex0
	LOADI 3
	CALL DelayAC
	
	LOAD D5
	OUT SqGen 
	OUT Hex0
	LOADI 3
	CALL DelayAC
	
	LOAD C5
	OUT SqGen 
	OUT Hex0
	LOADI 3
	CALL DelayAC
	
	LOAD B4
	OUT SqGen 
	OUT Hex0
	LOADI 3
	CALL DelayAC
	
	LOAD A4
	OUT SqGen 
	OUT Hex0
	LOADI 5
	CALL DelayAC
	
	LOADI 0
	OUT SqGen 
	OUT Hex0
	LOADI 1
	CALL DelayAC
	
	LOAD A4
	OUT SqGen 
	OUT Hex0
	LOADI 5
	CALL DelayAC
	
	LOADI 0
	OUT SqGen 
	OUT Hex0
	LOADI 1
	CALL DelayAC
	
	LOAD A4
	OUT SqGen 
	OUT Hex0
	LOADI 5
	CALL DelayAC
	
	LOAD D5
	OUT SqGen 
	OUT Hex0
	LOADI 5
	CALL DelayAC
	
	LOADI 0
	OUT SqGen 
	OUT Hex0
	LOADI 1
	CALL DelayAC
	
	LOAD D5
	OUT SqGen 
	OUT Hex0
	LOADI 3
	CALL DelayAC
	
	LOAD E5
	OUT SqGen 
	OUT Hex0
	LOADI 3
	CALL DelayAC
	
	LOAD D5
	OUT SqGen 
	OUT Hex0
	LOADI 3
	CALL DelayAC
	
	LOAD C5
	OUT SqGen 
	OUT Hex0
	LOADI 3
	CALL DelayAC
	
	LOAD B4
	OUT SqGen 
	OUT Hex0
	LOADI 5
	CALL DelayAC
	
	LOAD G4
	OUT SqGen 
	OUT Hex0
	LOADI 5
	CALL DelayAC
	
	LOADI 0
	OUT SqGen 
	OUT Hex0
	LOADI 1
	CALL DelayAC
	
	LOAD G4
	OUT SqGen 
	OUT Hex0
	LOADI 5
	CALL DelayAC
	
	LOAD E5
	OUT SqGen 
	OUT Hex0
	LOADI 5
	CALL DelayAC
	
	LOADI 0
	OUT SqGen 
	OUT Hex0
	LOADI 1
	CALL DelayAC
	
	LOAD E5
	OUT SqGen 
	OUT Hex0
	LOADI 3
	CALL DelayAC
	
	LOAD F5
	OUT SqGen 
	OUT Hex0
	LOADI 3
	CALL DelayAC
	
	LOAD E5
	OUT SqGen 
	OUT Hex0
	LOADI 3
	CALL DelayAC
	
	LOAD D5
	OUT SqGen 
	OUT Hex0
	LOADI 3
	CALL DelayAC
	
	LOAD C5
	OUT SqGen 
	OUT Hex0
	LOADI 5
	CALL DelayAC
	
	LOAD A4
	OUT SqGen 
	OUT Hex0
	LOADI 5
	CALL DelayAC
	
	LOAD G4
	OUT SqGen 
	OUT Hex0
	LOADI 3
	CALL DelayAC
	
	LOADI 0
	OUT SqGen 
	OUT Hex0
	LOADI 1
	CALL DelayAC
	
	LOAD G4
	OUT SqGen 
	OUT Hex0
	LOADI 3
	CALL DelayAC
	
	LOAD A4
	OUT SqGen 
	OUT Hex0
	LOADI 5
	CALL DelayAC
	
	LOAD D5
	OUT SqGen 
	OUT Hex0
	LOADI 5
	CALL DelayAC
	
	LOAD B4
	OUT SqGen 
	OUT Hex0
	LOADI 5
	CALL DelayAC
	
	LOAD C5
	OUT SqGen 
	OUT Hex0
	LOADI 10
	CALL DelayAC
	
	IN Switches
	OUT LEDs
	STORE Switch1
	LOAD Switch1
	AND Bit1
	JZERO Print
	
	JUMP EasterEgg

C2: DW &B0101111110000000
G4:	DW &B0010000000000000
C5:	DW &B0001100000000000
D5: DW &B0001010101000000
B4: DW &B0001100101000000
A4: DW &B0001110010000000
E5: DW &B0001001100000000
F5: DW &B0001001000000000
G6: DW &B0100111111000000

GameModeSolution:
	
	LOADI &H0E
	OUT Hex1

	LOAD B4
	OUT SqGen 
	OUT Hex0
	LOADI 5
	CALL DelayAC
	
	IN Switches
	OUT LEDs
	STORE Switch2
	LOAD Switch2
	AND Bit2
	JZERO Print
	
	JUMP GameModeSolution
	

G: 	DW &B0001000000000000
G#: DW &B0000111100000000

;; this is just basically a freeze loop, if Switch0 isnt lowered
;; the loop would remain frozen just like Captain America before the first 
;; Avengers movie
Freeze:
	LOADI 0 
	OUT  SqGen
	IN Switches
	STORE Switch0
	LOAD Switch0
	AND	 Bit0
	JPOS Freeze
	
	IN Switches
	OUT LEDs
	STORE Switch9
	LOAD Switch9
	AND Bit9
	JZERO Print
	RETURN


;; zero loop, basically what it does is when L2 Norm is 0	
;; rings some sort of tone in this case C5 note, repeatedly checks
;; if the value is still 0 or it may have changed

ZEROO:
  
  LOADI 0
  OUT Hex0
  
  LOAD one
  ADDI 10
  CALL PlayNote
  
  LOAD two
  ADDI 1
  CALL PlayNote
  
  LOAD three
  ADDI 10
  CALL PlayNote
  
  LOAD four
  ADDI 1
  CALL PlayNote
  
  LOAD five
  ADDI 10
  CALL PlayNote
  
  LOAD six
  ADDI 1
  CALL PlayNote
  
  LOAD seven
  ADDI 10
  CALL PlayNote
  
  LOAD eight
  ADDI 1
  CALL PlayNote
	
	LOADI 0
	CALL SetupI2C
	CALL ReadX
	STORE L2A
	CALL ReadY
	STORE L2B
	CALL L2Estimate
	STORE d16sN
	LOADI 16
	STORE d16sD
	CALL Div16s
	LOAD dres16sQ
	JZERO ZEROO
	OUT Hex0
	
	;; same old, same old
	IN Switches
	OUT LEDs
	STORE Switch0
	LOAD Switch0
	AND Bit0
	JPOS Freeze
	
	RETURN
	

	
onee: DW &B0101111110000000
two: DW &B0101010101000000
three: DW &B0100101111000000
four: DW &B0100011110000000
five: DW &B0011111111000000
six: DW &B11100011000000
seven: DW &B11001010000000
eight: DW &B10111111000000


;; invalid inputs from the user
Error1:
	
	LOAD D0
	OUT Hex1
	LOAD DODO
	OUT Hex0
	
	LOAD AllOnes
	OUT LEDs
	
	LOAD G#
	OUT SqGen 
	LOADI 3
	CALL DelayAC
	
	LOAD AllZeroes
	OUT LEDs
	
	LOAD G
	OUT SqGen 
	LOADI 3
	CALL DelayAC
	
	;; proceed to Error
	IN Switches 
	OUT LEDs
	STORE Switch5
	LOAD Switch5
	AND Bit5
	JZERO Print
	
	JUMP Error1
	
;; invalid inputs from the user
Error2:
	
	LOAD D0
	OUT Hex1
	LOAD DODO
	OUT Hex0
	
	LOAD AllOnes
	OUT LEDs
	
	LOAD G#
	OUT SqGen 
	LOADI 3
	CALL DelayAC
	
	LOAD AllZeroes
	OUT LEDs
	
	LOAD G
	OUT SqGen 
	LOADI 3
	CALL DelayAC
	
	;; proceed to Error
	IN Switches 
	OUT LEDs
	STORE Switch4
	LOAD Switch4
	AND Bit4
	JZERO Print
	
	JUMP Error2
	
;; invalid inputs from the user
Error3:
	
	LOAD D0
	OUT Hex1
	LOAD DODO
	OUT Hex0
	
	LOAD AllOnes
	OUT LEDs
	
	LOAD G#
	OUT SqGen 
	LOADI 3
	CALL DelayAC
	
	LOAD AllZeroes
	OUT LEDs
	
	LOAD G
	OUT SqGen 
	LOADI 3
	CALL DelayAC
	
	;; proceed to Error
	IN Switches 
	OUT LEDs
	STORE Switch3
	LOAD Switch3
	AND Bit3
	JZERO Print
	
	JUMP Error3
	
AllZeroes: DW &B0000000000
AllOnes:   DW &B1111111111
D0:   	   DW &B11010000  
DODO:      DW &B0000110100000000 	   

	
PlayNote:
	OUT SqGen
	OUT LEDs
	AND DurationMask
	ADDI 1
	CALL DelayAC
	RETURN

DurationMask: DW &B111111

XDuration:
	LOAD L2A
	AND GetDuration
	OUT Hex0
	
	
GetDuration: DW &B0000000000111111

; Subroutine to configure the I2C for reading accelerometer data.
; Only needs to be done once after each reset.
SetupI2C:
	LOAD   AccCfg      ; load the number of commands
	STORE  CmdCnt
	LOADI  AccCfg      ; Load list address
	ADDI   1           ; Increment to first command
	STORE  CmdPtr
I2CCmdLoop:
	CALL   BlockI2C    ; wait for idle
	LOAD   I2CWCmd     ; load write command
	OUT    I2C_CMD     ; to I2C_CMD register
	ILOAD  CmdPtr      ; load current command
	OUT    I2C_DATA    ; to I2C_DATA register
	OUT    I2C_RDY     ; start the communication
	CALL   BlockI2C    ; wait for it to finish
	LOAD   CmdPtr
	ADDI   1           ; Increment to next command
	STORE  CmdPtr
	LOAD   CmdCnt
	ADDI   -1          ; Check if finished
	STORE  CmdCnt
	JPOS   I2CCmdLoop
	RETURN
CmdPtr: DW 0
CmdCnt: DW 0

; Subroutine to read the X-direction acceleration.
; Returns the value in AC.
ReadX:
	CALL   BlockI2C    ; ensure bus is idle
	LOAD   I2CRCmd     ; load read command
	OUT    I2C_CMD     ; send read command to I2C_CMD register
	LOAD   AccXAddr    ; load ADXL345 register address for X acceleration 
	OUT    I2C_DATA    ; send to I2C_DATA register
	OUT    I2C_RDY     ; start the communication
	CALL   BlockI2C    ; wait for it to finish
	IN     I2C_data    ; put the data in AC
	CALL   SwapBytes   ; bytes are returned in wrong order; swap them
	RETURN
ReadY:
	CALL   BlockI2C    ; ensure bus is idle
	LOAD   I2CRCmd     ; load read command
	OUT    I2C_CMD     ; send read command to I2C_CMD register
	LOAD   AccYAddr    ; load ADXL345 register address for X acceleration 
	OUT    I2C_DATA    ; send to I2C_DATA register
	OUT    I2C_RDY     ; start the communication
	CALL   BlockI2C    ; wait for it to finish
	IN     I2C_data    ; put the data in AC
	CALL   SwapBytes   ; bytes are returned in wrong order; swap them
	RETURN
		
; This subroutine swaps the high and low bytes in AC
SwapBytes:
	STORE  SBT1
	SHIFT  8
	STORE  SBT2
	LOAD   SBT1
	SHIFT  -8
	AND    LoByte
	OR     SBT2
	RETURN
SBT1: DW 0
SBT2: DW 0

; Subroutine to block until I2C device is idle.
; Enters error loop if no response for ~0.1 seconds.
BlockI2C:
	LOAD   Zero
	STORE  Temp        ; Used to check for timeout
BI2CL:
	LOAD   Temp
	ADDI   1           ; this will result in ~0.1s timeout
	STORE  Temp
	JZERO  I2CError    ; Timeout occurred; error
	IN     I2C_RDY     ; Read busy signal
	JPOS   BI2CL       ; If not 0, try again
	RETURN             ; Else return
I2CError:
	LOAD   Zero
	ADDI   &H12C       ; "I2C"
	OUT    Hex0        ; display error message
	JUMP   I2CError

;*******************************************************************************
; DelayAC: Pause for some multiple of 0.1 seconds.
; Call this with the desired delay in AC.
; E.g. if AC is 10, this will delay for 10*0.1 = 1 second
;*******************************************************************************
DelayAC:
	STORE  DelayTime   ; Save the desired delay
	OUT    Timer       ; Reset the timer
WaitingLoop:
	IN     Timer       ; Get the current timer value
	SUB    DelayTime
	JNEG   WaitingLoop ; Repeat until timer = delay value
	RETURN
DelayTime: DW 0

;*******************************************************************************
; Abs: 2's complement absolute value
; Returns abs(AC) in AC
; Neg: 2's complement negation
; Returns -AC in AC
;*******************************************************************************
Abs:
	JPOS   Abs_r
Neg:
	XOR    NegOne       ; Flip all bits
	ADDI   1            ; Add one (i.e. negate number)
Abs_r:
	RETURN

;******************************************************************************;
; Atan2: 4-quadrant arctangent calculation                                     ;
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ;
; Original code by Team AKKA, Spring 2015.                                     ;
; Based on methods by Richard Lyons                                            ;
; Code updated by Kevin Johnson to use software mult and div                   ;
; No license or copyright applied.                                             ;
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ;
; To use: store dX and dY in global variables AtanX and AtanY.                 ;
; Call Atan2                                                                   ;
; Result (angle [0,359]) is returned in AC                                     ;
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ;
; Requires additional subroutines:                                             ;
; - Mult16s: 16x16->32bit signed multiplication                                ;
; - Div16s: 16/16->16R16 signed division                                       ;
; - Abs: Absolute value                                                        ;
; Requires additional constants:                                               ;
; - One:     DW 1                                                              ;
; - NegOne:  DW -1                                                              ;
; - LoByte:  DW &HFF                                                           ;
;******************************************************************************;
Atan2:
	LOAD   AtanY
	CALL   Abs          ; abs(y)
	STORE  AtanT
	LOAD   AtanX        ; abs(x)
	CALL   Abs
	SUB    AtanT        ; abs(x) - abs(y)
	JNEG   A2_sw        ; if abs(y) > abs(x), switch arguments.
	LOAD   AtanX        ; Octants 1, 4, 5, 8
	JNEG   A2_R3
	CALL   A2_calc      ; Octants 1, 8
	JNEG   A2_R1n
	RETURN              ; Return raw value if in octant 1
A2_R1n: ; region 1 negative
	ADDI   360          ; Add 360 if we are in octant 8
	RETURN
A2_R3: ; region 3
	CALL   A2_calc      ; Octants 4, 5            
	ADDI   180          ; theta' = theta + 180
	RETURN
A2_sw: ; switch arguments; octants 2, 3, 6, 7 
	LOAD   AtanY        ; Swap input arguments
	STORE  AtanT
	LOAD   AtanX
	STORE  AtanY
	LOAD   AtanT
	STORE  AtanX
	JPOS   A2_R2        ; If Y positive, octants 2,3
	CALL   A2_calc      ; else octants 6, 7
	CALL   Neg          ; Negatge the number
	ADDI   270          ; theta' = 270 - theta
	RETURN
A2_R2: ; region 2
	CALL   A2_calc      ; Octants 2, 3
	CALL   Neg          ; negate the angle
	ADDI   90           ; theta' = 90 - theta
	RETURN
A2_calc:
	; calculates R/(1 + 0.28125*R^2)
	LOAD   AtanY
	STORE  d16sN        ; Y in numerator
	LOAD   AtanX
	STORE  d16sD        ; X in denominator
	CALL   A2_div       ; divide
	LOAD   dres16sQ     ; get the quotient (remainder ignored)
	STORE  AtanRatio
	STORE  m16sA
	STORE  m16sB
	CALL   A2_mult      ; X^2
	STORE  m16sA
	LOAD   A2c
	STORE  m16sB
	CALL   A2_mult
	ADDI   256          ; 256/256+0.28125X^2
	STORE  d16sD
	LOAD   AtanRatio
	STORE  d16sN        ; Ratio in numerator
	CALL   A2_div       ; divide
	LOAD   dres16sQ     ; get the quotient (remainder ignored)
	STORE  m16sA        ; <= result in radians
	LOAD   A2cd         ; degree conversion factor
	STORE  m16sB
	CALL   A2_mult      ; convert to degrees
	STORE  AtanT
	SHIFT  -7           ; check 7th bit
	AND    One
	JZERO  A2_rdwn      ; round down
	LOAD   AtanT
	SHIFT  -8
	ADDI   1            ; round up
	RETURN
A2_rdwn:
	LOAD   AtanT
	SHIFT  -8           ; round down
	RETURN
A2_mult: ; multiply, and return bits 23..8 of result
	CALL   Mult16s
	LOAD   mres16sH
	SHIFT  8            ; move high word of result up 8 bits
	STORE  mres16sH
	LOAD   mres16sL
	SHIFT  -8           ; move low word of result down 8 bits
	AND    LoByte
	OR     mres16sH     ; combine high and low words of result
	RETURN
A2_div: ; 16-bit division scaled by 256, minimizing error
	LOADI  9            ; loop 8 times (256 = 2^8)
	STORE  AtanT
A2_DL:
	LOAD   AtanT
	ADDI   -1
	JPOS   A2_DN        ; not done; continue shifting
	CALL   Div16s       ; do the standard division
	RETURN
A2_DN:
	STORE  AtanT
	LOAD   d16sN        ; start by trying to scale the numerator
	SHIFT  1
	XOR    d16sN        ; if the sign changed,
	JNEG   A2_DD        ; switch to scaling the denominator
	XOR    d16sN        ; get back shifted version
	STORE  d16sN
	JUMP   A2_DL
A2_DD:
	LOAD   d16sD
	SHIFT  -1           ; have to scale denominator
	STORE  d16sD
	JUMP   A2_DL
AtanX:      DW 0
AtanY:      DW 0
AtanRatio:  DW 0        ; =y/x
AtanT:      DW 0        ; temporary value
A2c:        DW 72       ; 72/256=0.28125, with 8 fractional bits
A2cd:       DW 14668    ; = 180/pi with 8 fractional bits

;*******************************************************************************
; Mult16s:  16x16 -> 32-bit signed multiplication
; Based on Booth's algorithm.
; Written by Kevin Johnson.  No licence or copyright applied.
; Warning: does not work with factor B = -32768 (most-negative number).
; To use:
; - Store factors in m16sA and m16sB.
; - Call Mult16s
; - Result is stored in mres16sH and mres16sL (high and low words).
;*******************************************************************************
Mult16s:
	LOADI  0
	STORE  m16sc        ; clear carry
	STORE  mres16sH     ; clear result
	LOADI  16           ; load 16 to counter
Mult16s_loop:
	STORE  mcnt16s      
	LOAD   m16sc        ; check the carry (from previous iteration)
	JZERO  Mult16s_noc  ; if no carry, move on
	LOAD   mres16sH     ; if a carry, 
	ADD    m16sA        ;  add multiplicand to result H
	STORE  mres16sH
Mult16s_noc: ; no carry
	LOAD   m16sB
	AND    One          ; check bit 0 of multiplier
	STORE  m16sc        ; save as next carry
	JZERO  Mult16s_sh   ; if no carry, move on to shift
	LOAD   mres16sH     ; if bit 0 set,
	SUB    m16sA        ;  subtract multiplicand from result H
	STORE  mres16sH
Mult16s_sh:
	LOAD   m16sB
	SHIFT  -1           ; shift result L >>1
	AND    c7FFF        ; clear msb
	STORE  m16sB
	LOAD   mres16sH     ; load result H
	SHIFT  15           ; move lsb to msb
	OR     m16sB
	STORE  m16sB        ; result L now includes carry out from H
	LOAD   mres16sH
	SHIFT  -1
	STORE  mres16sH     ; shift result H >>1
	LOAD   mcnt16s
	ADDI   -1           ; check counter
	JPOS   Mult16s_loop ; need to iterate 16 times
	LOAD   m16sB
	STORE  mres16sL     ; multiplier and result L shared a word
	RETURN              ; Done
c7FFF: DW &H7FFF
m16sA: DW 0 ; multiplicand
m16sB: DW 0 ; multipler
m16sc: DW 0 ; carry
mcnt16s: DW 0 ; counter
mres16sL: DW 0 ; result low
mres16sH: DW 0 ; result high

;*******************************************************************************
; Div16s:  16bit/16bit -> 16bit R16bit signed division
; Written by Kevin Johnson.  No licence or copyright applied.
; Warning: results undefined if denominator = 0.
; To use:
; - Store numerator in d16sN and denominator in d16sD.
; - Call Div16s
; - Result is stored in dres16sQ and dres16sR (quotient and remainder).
; Requires Abs subroutine
;*******************************************************************************
Div16s:
	LOADI  0
	STORE  dres16sR     ; clear remainder result
	STORE  d16sC1       ; clear carry
	LOAD   d16sN
	XOR    d16sD
	STORE  d16sS        ; sign determination = N XOR D
	LOADI  17
	STORE  d16sT        ; preload counter with 17 (16+1)
	LOAD   d16sD
	CALL   Abs          ; take absolute value of denominator
	STORE  d16sD
	LOAD   d16sN
	CALL   Abs          ; take absolute value of numerator
	STORE  d16sN
Div16s_loop:
	LOAD   d16sN
	SHIFT  -15          ; get msb
	AND    One          ; only msb (because shift is arithmetic)
	STORE  d16sC2       ; store as carry
	LOAD   d16sN
	SHIFT  1            ; shift <<1
	OR     d16sC1       ; with carry
	STORE  d16sN
	LOAD   d16sT
	ADDI   -1           ; decrement counter
	JZERO  Div16s_sign  ; if finished looping, finalize result
	STORE  d16sT
	LOAD   dres16sR
	SHIFT  1            ; shift remainder
	OR     d16sC2       ; with carry from other shift
	SUB    d16sD        ; subtract denominator from remainder
	JNEG   Div16s_add   ; if negative, need to add it back
	STORE  dres16sR
	LOADI  1
	STORE  d16sC1       ; set carry
	JUMP   Div16s_loop
Div16s_add:
	ADD    d16sD        ; add denominator back in
	STORE  dres16sR
	LOADI  0
	STORE  d16sC1       ; clear carry
	JUMP   Div16s_loop
Div16s_sign:
	LOAD   d16sN
	STORE  dres16sQ     ; numerator was used to hold quotient result
	LOAD   d16sS        ; check the sign indicator
	JNEG   Div16s_neg
	RETURN
Div16s_neg:
	LOAD   dres16sQ     ; need to negate the result
	CALL   Neg
	STORE  dres16sQ
	RETURN	
d16sN: DW 0 ; numerator
d16sD: DW 0 ; denominator
d16sS: DW 0 ; sign value
d16sT: DW 0 ; temp counter
d16sC1: DW 0 ; carry value
d16sC2: DW 0 ; carry value
dres16sQ: DW 0 ; quotient result
dres16sR: DW 0 ; remainder result

;*******************************************************************************
; L2Estimate:  Pythagorean distance estimation
; Written by Kevin Johnson.  No license or copyright applied.
; Warning: this is not an exact function, but it's pretty good.
; To use:
; - Store A and B in L2A and L2B.
; - Call L2Estimate
; - Result is returned in AC.
; Requires Abs and Mult16s subroutines.
;*******************************************************************************
L2Estimate:
	; take abs() of each value, and find the largest one
	LOAD   L2A
	CALL   Abs
	STORE  L2T1
	LOAD   L2B
	CALL   Abs
	SUB    L2T1
	JNEG   GDSwap    ; swap if needed to get largest value in X
	ADD    L2T1
CalcDist:
	; Calculation is max(X,Y)*0.961+min(X,Y)*0.406
	STORE  m16sa
	LOADI  246       ; max * 246
	STORE  m16sB
	CALL   Mult16s
	LOAD   mres16sH
	SHIFT  8
	STORE  L2T2
	LOAD   mres16sL
	SHIFT  -8        ; / 256
	AND    LoByte
	OR     L2T2
	STORE  L2T3
	LOAD   L2T1
	STORE  m16sa
	LOADI  104       ; min * 104
	STORE  m16sB
	CALL   Mult16s
	LOAD   mres16sH
	SHIFT  8
	STORE  L2T2
	LOAD   mres16sL
	SHIFT  -8        ; / 256
	AND    LoByte
	OR     L2T2
	ADD    L2T3     ; sum
	RETURN
GDSwap: ; swaps the incoming X and Y
	ADD    L2T1
	STORE  L2T2
	LOAD   L2T1
	STORE  L2T3
	LOAD   L2T2
	STORE  L2T1
	LOAD   L2T3
	JUMP   CalcDist
L2A:  DW 0
L2B:  DW 0
L2C:  DW 0
L2T1: DW 0
L2T2: DW 0
L2T3: DW 0



; Variables
Temp:      DW 0
Switch0:   DW 0
Switch1:   DW 0
Switch2:   DW 0
Switch3:   DW 0
Switch4:   DW 0
Switch5:   DW 0 
Switch6:   DW 0
Switch7:   DW 0
Switch9:   DW 0
Switch8:   DW 0
Switch98:  DW 0
Switch97:  DW 0
Switch987: DW 0
Pattern:   DW 0
Score:     DW 0

; Useful values
Zero:      DW 0
NegOne:    DW -1
One:
Bit0:      DW &B0000000001
Bit1:      DW &B0000000010
Bit2:      DW &B0000000100
Bit3:      DW &B0000001000
Bit4:      DW &B0000010000
Bit5:      DW &B0000100000
Bit6:      DW &B0001000000
Bit7:      DW &B0010000000
Bit8:      DW &B0100000000
Bit9:      DW &B1000000000
Bit98:     DW &B1100000000
Bit97:     DW &B1010000000
Bit987:    DW &B1110000000
LoByte:    DW &H00FF
HiByte:    DW &HFF00

; I2C Constants
I2CWCmd:  DW &H203A    ; write two i2c bytes, addr 0x3A
I2CRCmd:  DW &H123A    ; write one byte, read two bytes, addr 0x3A
AccXAddr: DW &H32      ; X acceleration register address.
AccYAddr: DW &H34	   ; Y acceleration register address.
AccCfg: ; List of commands to send the ADXL345 at startup
	DW 6           ; Number of commands to send
	DW &H3100      ; Dummy transaction to sync I2C bus if needed	
	DW &H3100      ; Dummy transaction to sync I2C bus if needed	
	DW &H3100      ; Right-justified 10-bit data, +/-2 G
	DW &H3800      ; No FIFO
	DW &H2C0A      ; 25 samples per second
	DW &H2D08      ; No sleep


; IO address constants
SqGen:     EQU &HF0
Switches:  EQU &H000
LEDs:      EQU &H001
Timer:     EQU &H002
Hex0:      EQU &H004
Hex1:      EQU &H005
I2C_cmd:   EQU &H090
I2C_data:  EQU &H091
I2C_rdy:   EQU &H092
DPs:       EQU &H0E0
