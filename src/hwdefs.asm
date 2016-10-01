;
; HARDWARE DEFINES
;

.define JOYP $FF00
.define SB   $FF01
.define SC   $FF02

.define DIV  $FF04
.define TIMA $FF05
.define TMA  $FF06
.define TAC  $FF07

.define IF   $FF0F

.define NR10 $FF10 ; Ch1 Sweep
.define NR11 $FF11 ; Ch1 Duty + Len
.define NR12 $FF12 ; Ch1 Vol Env
.define NR13 $FF13 ; Ch1 Freq Lo
.define NR14 $FF14 ; Ch1 Freq Hi

.define NR21 $FF16 ; Ch2 Duty + Len
.define NR22 $FF17 ; Ch2 Vol Env
.define NR23 $FF18 ; Ch2 Freq Lo
.define NR24 $FF19 ; Ch2 Freq Hi

.define NR30 $FF1A ; Ch3 On/Off
.define NR31 $FF1B ; Ch3 Len
.define NR32 $FF1C ; Ch3 Vol
.define NR33 $FF1D ; Ch3 Freq Lo
.define NR34 $FF1E ; Ch3 Freq Hi

.define NR41 $FF20 ; Ch4 Len
.define NR42 $FF21 ; Ch4 Vol Env
.define NR43 $FF22 ; Ch4 Poly/Freq
.define NR44 $FF23 ; Ch4 Start/Ctr

.define NR50 $FF24 ; Master L/R Vol + Vin enables
.define NR51 $FF25 ; Panning
.define NR52 $FF26 ; Master Enable

.define WAVR $FF30 ; 16-byte Wav RAM (Ch3), MSB first

.define LCDC $FF40
.define STAT $FF41
.define SCY  $FF42
.define SCX  $FF43
.define LY   $FF44
.define LYC  $FF45
.define DMA  $FF46
.define BGP  $FF47
.define OBP0 $FF48
.define OBP1 $FF49

.define IE   $FFFF

