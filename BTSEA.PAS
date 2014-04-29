{
-ÄÄÄ Aragorn ÄÄ-- / þCONTROL UNiTþ

 BeyOnd the Sea 64kb intro

 main module
}
{$N+ $G+}
{{$S- $I-} {gotta leave checkings on.... :(  }
{{$define meminfo}
{{$define swdump}
{{$define partskip}
uses globals,bump,bpp,sprites,palette,splines,blur,tunnel,writer,crta,
     midas, mplayer, s3m, mm, mconfig, timer;

var
{---------------------------------------}
  Xhandle    : word;
const
  Xtun1      = 0;
  Xtun2      = 0+65536;
  Xtunt      = 0+65536+65536;
{---------------------------------------}
const
  cframe     : longint = 0;
  ticks      : longint = 0;
const
  songlen    = 160;
var
  syncvalue  : word;
  module     : PmpModule;
  MP         : PModulePlayer;
  zakinfo    : PmpInformation;
const
{-event-timings-------------------------}
  ts_introfadeend       = $0135;         {intro : starting fade in end}
  ts_xfadeinend         = $0313;         {intro : xfade in end}
  ts_xfadeoutend        = $0424;         {intro : xfade out end}
  ts_endpart1           = $061F;         {intro : intropart end}
  ts_endpart2           = $073F;         {drops : drops part end}
  fd3dp                 = 1600;          {3d    : 3dpart duration (in time frames)}
  lastfade              = $2418;
  endoftheintro         = $2518;
{-Tunnel-synch'ing----------------------}
  tun_normal            = 0;
  tun_water             = $1029;
  tun_disp              = $113B;
  tun_smokey            = $130D;
  tun_end               = $141E; {start of the last fade b4 credits part}
  tun_end2              = $1500;
  tun_keys : array[0..4] of longint = (tun_normal,tun_water,tun_disp,tun_smokey,tun_end);
  tun_ckey : word       = 0;
  tun_ctun : word       = 0;
  tun_goseq    : boolean= true;
  tun_switched : boolean= false;
  tun_inter    : longint= -32;
var
  tun_iframe   : longint;
{---------------------------------------}
var
 xs,ys,xs1,ys1          : real;
 ttx,tty                : word;
{-event flags---------------------------}
const
 ev_fade1               : boolean = true;
 ev_fade2               : boolean = false;
 ev_fade3               : boolean = false;
{---------------------------------------}
var
 inter                  : longint;
 inter2                 : longint;
 iframe                 : longint;

{$I 3dthing.inc}
{$I exemes.inc}

function tmgettime:longint;
begin
 tmgettime:=ticks;
end;

function getsyncword : word;
var         syncword : word;
begin
  MP^.GetInformation(@zakinfo);
  syncword := zakinfo^.pos shl 8+zakinfo^.row;
  if boolean(zakinfo^.loopcnt) then inc(syncword,songlen shl 8);
  getsyncword := syncword;
end;

{$ifdef swdump}
{$I swdmper.inc}
{$endif}

{$F+}
var oldexitproc : pointer;
procedure error;
begin
exitproc := oldexitproc;
asm  mov   ax, 3h; int   10h; end;
end;

procedure time_handler;
begin
inc(ticks);
end;
{$F-}

const escflag : boolean = false;
function escpressed:boolean;
var ch : char;
begin
  escpressed := false;
  if keypressed then ch := char(readkey);
  {$ifdef swdump}
  if upcase(ch) = 'D' then swdumper;
  {$endif}
  if ch = #27 then
    begin
    escpressed := true;
    {$ifndef partskip}
    escflag    := true;
    {$endif}
    end;
end;

{tunnel axxelerator - really lame}
function tunx(frame : longint):longint;
begin
  if frame < 200 then tunx := 0
      else if frame < 250 then tunx := trunc(-cos((frame-200)*((pi/2)/50))*25+25)
        else tunx := trunc((frame-250)*(0.8))+25;
end;

procedure tunnel_pals(iframe : longint); {bleah....}
begin
if iframe <= 32 then
  calcparpal(iframe   ,32,0,65*3,ofs(pal2),ofs(palf),ofs(pala1),fadedn)
  else
  calcparpal(iframe-32,32,0,65*3,ofs(pal2),ofs(palf),ofs(pala1),fadeup)
end;

procedure tunnel_handler(iframe : longint);
begin
if (getsyncword > tun_keys[tun_ckey]) and (not tun_goseq) then {Start the sequence, if it's not already running}
  begin
  tun_goseq := true;
  tun_inter := iframe;
  end;
if tun_goseq then
  begin
  tun_iframe := iframe-tun_inter;
  tunnel_pals(tun_iframe);
  if (tun_iframe >= 32) and (not tun_switched) and boolean(tun_ckey) then
    begin {switch tunnels}
    inc(tun_ctun);
    tun_switched := true;
    {swdumper;}
    end;
  if (tun_iframe >= 65) then
    begin {end sequence}
    tun_goseq := false;
    tun_switched := false;
    inc(tun_ckey);
    end;
  end;
case tun_ctun of
   0   : movetunnel (-tunx(iframe) and 255,tty,tun1,tun2,tunt,$A000);
   1   : movetunnel3(-tunx(iframe) and 255,tty,tun1,tun2,tunt,$A000);
   2   : movetunnel4(-tunx(iframe) and 255,tty,tun1,tun2,tunt,$A000);
   3,4 : movetunnel2(-tunx(iframe) and 255,tty,tun1,tun2,tunt,$A000);
end;
end;

begin
{$ifdef meminfo}
writeln('Available memory : ',memavail);
writeln('Largest   block  : ',maxavail);
writeln(ofs(bmpdrop));
readkey;
{$endif}
oldexitproc := exitproc;
exitproc    := @error;
if not Xinit then if Xmaxavail < (64*4) then
  begin
  writeln('Not enough XMS mem free (or no XMS at all)');
  halt(1);
  end;
Xhandle := Xallocate(64*4);
asm  mov   ax,13h; int   10h; end;
tmrGetScrSync(@syncvalue);
asm  mov   ax, 3h; int   10h; end;
    midasSetDefaults;
    midasConfig;
    midasInit;
asm  mov   ax,13h; int   10h; end;
blackpal(0,256);
setborder(255);
{----------------------------------------------------------------------}
getmem(pbuf1,65535);
buf1 := seg(pbuf1^);
getmem(pbuf2,65535);
buf2 := seg(pbuf2^);
getmem(pbuf3,65535);
buf3 := seg(pbuf3^);
getmem(pbuf4,65535);
buf4 := seg(pbuf4^);
{---Tunnel-init--------------------------------------------------------}
tun1 := buf1;
tun2 := buf2;
tunt := buf3;

dotunmap(tun1,tun2);
dotuntex(tunt);
Xlowtohigh(ptr(tun1,0),Xhandle,Xtun1,65536);
Xlowtohigh(ptr(tun2,0),Xhandle,Xtun2,65536);
Xlowtohigh(ptr(tunt,0),Xhandle,Xtunt,65536);

bufreset(buf1);
bufreset(buf2);
bufreset(buf3);
bufreset(buf4);
getmem(tverts,sizeof(coordt3d)*(maxverts+1));
{----------------------------------------------------------------------}

for i := 0 to 1023 do
begin
st[i] := round(sin(i*2*pi/1023)*pad);
ct[i] := round(cos(i*2*pi/1023)*pad);
end;

setupzoom(1.05);

{-- Start playing music -----------------------------------------------}
    module := midasPrepareMM(@music, @mps3m);
    midasPlayModule(module, 0);
    MP := midasMP;
    tmrSyncScr(syncvalue, @time_handler, NIL, NIL);
{-- BUMP --------------------------------------------------------------}
bppdecode(@openpic,pbuf4,247*142,108);
dobmap;
makespot;
getpal(0,256,ofs(pal));
getpal(0,256,ofs(pal1));
move(pal[0],pal[108*3],104*3);
move(pal[0],pal2[0],768);
fadefromcolsetup(150,0,0,0,ofs(pal),ofs(palf),ofs(pala));
fadepaltopalsetup(150,ofs(pal),ofs(pal1),ofs(palf1),ofs(pala1));

port[$3c8] := 0;  {3D part palette}
ramp(0,0,0,0,30,63,32,0,dacramp,0);
rampsin(31,63,32,0,63,63,63,63,dacramp,0);
getpal(0,256,ofs(pal3));
fadefromcolsetup(64,63,63,63,ofs(pal3),ofs(palf),ofs(pala2));

blackpal(0,256);
retrace;

getpal(0,256,ofs(pal));
inter2 := 0;
ticks := 0;
repeat
    bufresetv(buf1);
    bspline(xs,ys,(cframe mod 700)/140);
    movespot(round(xs),round(ys));
    addsprite(buf4,buf1,25,15,247,142);
    if ev_fade1 then
      begin
      calcparpal(cframe,149,0,256*3,ofs(pal),ofs(palf),ofs(pala),fadeup);
      if getsyncword >= ts_introfadeend then
        begin
        {swdumper;}
        ev_fade1     := false;
        ev_fade2     := true;
        inter        := cframe;
        end;
      end;
    if ev_fade2 then
      begin
      inter2 := (cframe-inter) shr 1;
      calcparpal(inter2,149,0,256*3,ofs(pal2),ofs(palf),ofs(pala1),fadeup);
      if getsyncword >= ts_xfadeinend then
        begin
        {swdumper;}
        ev_fade2     := false;
        ev_fade3     := true;
        inter        := cframe;
        end;
      end;
    if ev_fade3 then
      begin
      calcparpal((cframe-inter) shr 1,149,0,256*3,ofs(pal2),ofs(palf),ofs(pala1),fadedn);
      if getsyncword >= ts_xfadeoutend then
        {begin
        {swdumper;}
        ev_fade3     := false;
        {end;}
      end;
    repeat until cframe <> tmgettime;
    cframe := tmgettime;
    setfixpal(0,256,ofs(palf));
    flip(buf1,$a000);
until (getsyncword >= ts_endpart1) or escpressed;
{swdumper;}

if not escflag then
begin

palfixtonorm(ofs(palf),ofs(pal));
fadetocolsetup(64,63,63,63,ofs(pal),ofs(palf),ofs(pala));

inter := tmgettime;
repeat
retrace;
calcparpal((tmgettime-inter) shl 3,63,0,256*3,ofs(pal),ofs(palf),ofs(pala),fadeup);
setfixpal(0,256,ofs(palf));
until (tmgettime-inter) shl 3 >= 67;
bufresetv($A000);
fillchar(pal[0],768,63);
bppdecode(@openpic,pbuf4,247*142,63);
bufresetv(buf1);
addsprite(buf4,buf1,25,15,247,142);    {buf1: bts logo}
bppdecode(ptr(seg(bmpdrop),ofs(bmpdrop)+1),pbuf4,19*19,63);    {buf4: drop bmp}
asm
        mov cx,5
@lup:   push cx
        push buf1
        call stdblur
        pop  cx
        loop @lup
end;
flip(buf1,$A000);

inter := tmgettime;
repeat
   for i := 0 to 20 do  {buf2: drops coords}
     begin
     memw[buf2:i shl 2]     := random(279) + 19;
     memw[buf2:(i shl 2)+2] := random(159) + 19;
     end;
   for i := 0 to 10 do
     begin
     cframe := tmgettime;
     for j := 0 to 20 do drop(buf4,buf1,memw[buf2:(j shl 2)+2]*320+memw[buf2:j shl 2]);
     calcparpal(cframe-inter,63,0,256*3,ofs(pal),ofs(palf),ofs(pala2),fadeup);
     retrace;
     setfixpal(0,256,ofs(palf));
     flip(buf1,$a000);
     end;
until (getsyncword >= ts_endpart2) or escpressed;
{swdumper;}
end;
{-- 3D part -----------------------------------------------------------}
if not escflag then
begin

verts := @diamond;
faces := ptr(seg(diamond),ofs(diamond)+(sizeof(coordt3d)*(maxverts+1)));

angxy := 0;
angxz := 0;
angyz := 0;

port[$3c8] := 0;
ramp(0,0,0,0,30,63,32,0,dacramp,0); {3D pal}
rampsin(31,63,32,0,63,63,63,63,dacramp,0);
getpal(0,256,ofs(pal));

ramp(1,6,0,0,32,43,0,61,buframp,ofs(pal1)); {Tunnel pal}
ramp(33,43,0,61,65,6,0,0,buframp,ofs(pal1));

fillfixpal(43,0,61,0,256,ofs(palf));
palfixtonorm(ofs(palf),ofs(pal2));
fadepaltopalsetup(32,ofs(pal),ofs(pal2),ofs(palf),ofs(pala));
fadepaltopalsetup(32,ofs(pal2),ofs(pal1),ofs(palf1),ofs(pala1));
fadetocolsetup(120,0,0,0,ofs(pal1),ofs(palf1),ofs(pala2));

inter := tmgettime;
repeat
  calcobj;
  firescr(buf1,buf1);
  zoom(buf1,buf2);
  drawobj(buf2);
  repeat until cframe <> tmgettime;
  cframe := tmgettime;
  iframe := cframe-inter;
  if (iframe > (fd3dp-32)) then
    begin
    calcparpal(iframe-(fd3dp-32),32,0,64*3,ofs(pal),ofs(palf),ofs(pala),fadeup);
    setfixpal(0,64,ofs(palf));
    end;
  flip(buf2,$A000);
  flip(buf2,buf1);

  if iframe <= fd3dp then
    begin
    angxy := trunc(iframe*(1024*4/fd3dp)) and 1023;
    angxz := trunc(iframe*(512*5/fd3dp)) and 1023;
    angyz := trunc(iframe*(1024*6/fd3dp)) and 1023;
    camdist := 30000-trunc((iframe*29000)/fd3dp);
    end;
until (iframe > fd3dp) or escpressed;
{----------------------------------------------------------------------}
end;

if not escflag then
begin
{-- Tunnel part -------------------------------------------------------}
Xhightolow(Xhandle,Xtun1,ptr(tun1,0),65536);
Xhightolow(Xhandle,Xtun2,ptr(tun2,0),65536);
Xhightolow(Xhandle,Xtunt,ptr(tunt,0),65536);

fillfixpal(43,0,61,0,256,ofs(palf));
cframe := tmgettime;
inter := cframe;
inter2 := 0;
repeat
  upd8water;
  repeat until cframe <> tmgettime;
  cframe := tmgettime;
  iframe := cframe-inter;
  setfixpal(0,65,ofs(palf));
  tty    := iframe and 255;
  tunnel_handler(iframe);
  if (getsyncword >= tun_end) then
    begin
    if not boolean(inter2) then inter2 := iframe;
    calcparpal(iframe-inter2,120,0,65*3,ofs(pal1),ofs(palf),ofs(pala2),fadeup);
    end;
until (getsyncword >= tun_end2)  or  escpressed;
{----------------------------------------------------------------------}
end;
if not escflag then
begin
bufresetv($A000);
{-Credits-part---------------------------------------------------------}
bufresetv(buf1);
setupzoom(1.01);
port[$3c8] := 0;
ramp(0,0,0,0,40,45,0,55,dacramp,0);
rampsin(41,45,0,55,63,63,63,63,dacramp,0);
ramp(64,42,26,0,127,63,32,0,dacramp,0);
  getpal(0,256,ofs(pal1));
  getpal(0,256,ofs(pal2));
  move(pal1[0],pal1[64*3],64*3);
  setpal(0,256,ofs(pal1));
  fadepaltopalsetup(128,ofs(pal1),ofs(pal2),ofs(palf),ofs(pala));
  info := @fonthdr;
  getmem(font,fontsize);
  bppdecode(@fontdatabp,pointer(font),fontsize,64);
  fadetocolsetup(115,0,0,0,ofs(pal1),ofs(palf),ofs(pala1));
  font^[9033] := 0; {ops, shitty thing :( }
  font^[9034] := 0;
camdist := 3900;
tun_goseq := false;
tun_inter := 0;
cframe  := tmgettime;
inter   := cframe;
inter2  := 120;
iframe  := 0;
repeat

  calcobj;
  firescr(buf1,buf1);
  zoom(buf1,buf2);
  drawobj(buf2);
  flip(buf2,buf1);


  if iframe >= 120 then
  begin
    dopage;
    calcpals(iframe-inter2);
  end else calcparpal(iframe,115,0,768,ofs(pal1),ofs(palf),ofs(pala1),fadedn);

  iframe := cframe - inter;
  repeat until cframe <> tmgettime;
  cframe := tmgettime;

if getsyncword >= lastfade then
  begin
  if not tun_goseq then begin tun_inter := iframe; tun_goseq := true; end;
  calcparpal(iframe-tun_inter,115,0,768,ofs(pal1),ofs(palf),ofs(pala1),fadeup);
  end;

  setfixpal(0,128,ofs(palf));
  flip(buf2,$A000);

  if ((iframe-inter2) > (128+150+127)) and (iframe >= 120) then
  begin
    pageadv := true;
    inter2  := iframe;
  end;
  if ((pagecnt = nup) and pageadv) then pagecnt := nup+1;

  angxy := (iframe) and 1023;
  angxz := (iframe shl 1) and 1023;
  angyz := (iframe*3) and 1023;
until (getsyncword >= endoftheintro) or keypressed; if keypressed then readkey;
{swdumper;}
end;
{-- Stop music --------------------------------------------------------}
    midasStopModule(module);
    midasFreeMM(module);
    midasclose;
Xfree(Xhandle);
freemem(tverts,sizeof(coordt3d)*(maxverts+1));
freemem(pbuf1,65535);
freemem(pbuf2,65535);
freemem(pbuf3,65535);
freemem(pbuf4,65535);
asm  mov   ax, 3h; int   10h; end;
end.
