
unit Sound;

interface

type
  TSound = (
    sndCapture,
    sndCheck,
    sndEndOfGame,
    sndIllegal,
    sndMove,
    sndPromotion
  );
  
function LoadSoundLib() : integer;
procedure Play(const aSound: TSound);

implementation

uses
  SysUtils, Classes, uos_flat;
  
const
  FILENAME: array[TSound] of string = (
    'capture.mp3',
    'sfx_alarm_loop2.wav',
    'genericnotify.mp3',
    'illegal.wav',
    'move.mp3',
    'sfx_coin_cluster1.wav'
  );  
  
var
 vsodir: string;
 vinc : shortint = 1;
 ms :  array[0..5] of Tmemorystream; 

procedure Play(const aSound: TSound);
begin
 uos_PlayNoFree(0);
end;

function LoadSoundLib() : integer;
var
 PA_FileName, MP_FileName, vaudir: string;
 x : integer;
begin
 vaudir := ExtractFilePath(ParamStr(0)) + 'audio' + directoryseparator ;
 vsodir := vaudir +  'sound' + directoryseparator;

 {$IFDEF Windows}
    {$if defined(cpu64)}
    PA_FileName := vaudir + 'lib\Windows\64bit\LibPortaudio-64.dll';
    MP_FileName := vaudir + 'lib\Windows\64bit\LibMpg123-64.dll';
    {$else}
    PA_FileName := vaudir + 'lib\Windows\32bit\LibPortaudio-32.dll';
    MP_FileName := vaudir + 'lib\Windows\32bit\LibMpg123-32.dll';
    {$endif}
 {$ENDIF}
  {$if defined(cpu64) and defined(linux) }
    PA_FileName := vaudir + 'lib/Linux/64bit/LibPortaudio-64.so';
    MP_FileName := vaudir + 'lib/Linux/64bit/LibMpg123-64.so';
  {$ENDIF}
 {$if defined(cpu86) and defined(linux)}
    PA_FileName := vaudir + 'lib/Linux/32bit/LibPortaudio-32.so';
    MP_FileName := vaudir + 'lib/Linux/32bit/LibMpg123-32.so';
 {$ENDIF}
 {$if defined(cpuarm) and defined(linux)}
    PA_FileName := vaudir + 'lib/Linux/arm_raspberrypi/libportaudio-arm.so';
    MP_FileName := vaudir + 'lib/Linux/arm_raspberrypi/LibMpg123-arm.so';
 {$ENDIF}
 {$IFDEF freebsd}
    {$if defined(cpu64)}
    PA_FileName := vaudir + 'lib/FreeBSD/64bit/libportaudio-64.so';
    MP_FileName := vaudir + 'lib/FreeBSD/64bit/libmpg123-64.so';
    {$else}
    PA_FileName := vaudir + 'lib/FreeBSD/32bit/libportaudio-32.so';
    MP_FileName := vaudir + 'lib/FreeBSD/32bit/libmpg123-32.so';
    {$endif}
 {$ENDIF}
  
    // Load the libraries, here only PortAudio and Mpg123
  result := uos_LoadLib(Pchar(PA_FileName), nil, Pchar(MP_FileName), nil, nil,  nil) ;
  
  
// {  // using memorystream
for x := 0 to 5 do
begin
if fileexists(vsodir + FILENAME[sndMove]) then
begin
writeln(vsodir + FILENAME[sndMove]);
ms[x] := TMemoryStream.Create; 
ms[x].LoadFromFile(pchar(vsodir +  FILENAME[sndMove]));  
ms[x].Position:= 0;
end;
end;

  for x := 0 to 5 do   
 begin
 uos_CreatePlayer(x);
 uos_AddFromMemoryStream(x,ms[x],1,-1,0,256); 
 {$if defined(cpuarm)} // needs lower latency
 uos_AddIntoDevOut(x, -1, 0.08, -1, -1, 0, 256, -1);
 {$else}
 uos_AddIntoDevOut(x, -1, 0.03, -1, -1, 0, 256, -1);
 {$endif}
 end;

{$IFDEF DEBUG}
   WriteLn('Result of uos_LoadLib(): ' + inttostr(result));
{$ENDIF}
 end;
   
finalization
  uos_Free;
  
end.
