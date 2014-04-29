{
-ÄÄÄ Aragorn ÄÄ-- / þCONTROL UNiTþ

Tunnel thing
}
unit tunnel;
interface
uses palette;

procedure dotunmap(b1,b2 : word);
procedure dotuntex(tex : word);

procedure movetunnel(texx,texy,srcmap1,srcmap2,srctex,dst:word);
procedure movetunnel2(texx,texy,srcmap1,srcmap2,srctex,dst:word);
procedure movetunnel3(texx,texy,srcmap1,srcmap2,srctex,dst:word);
procedure movetunnel4(texx,texy,srcmap1,srcmap2,srctex,dst:word);

procedure upd8water;

implementation
const
    xcent    = 160;
    ycent    = 100;
    radius   = 30;   {the real tunnel radius}
    eyedist  = 256;

var
    stab1     : array[0..255] of byte;
    ptab      : array[0..255] of byte;
    ang1,ang2 : byte;
    i         : word;

{$L tunmove.obj}
procedure movetunnel(texx,texy,srcmap1,srcmap2,srctex,dst:word); external;   {normal}
procedure movetunnel2(texx,texy,srcmap1,srcmap2,srctex,dst:word); external;  {smokey}
procedure movetunnel3(texx,texy,srcmap1,srcmap2,srctex,dst:word); external;  {water }
procedure movetunnel4(texx,texy,srcmap1,srcmap2,srctex,dst:word); external;  {water displaced}

procedure dotuntex(tex : word);
var i,j : word;
    rnd:byte;
begin
{blackpal(0,256);
port[$3c8] := 1;
ramp(0,6,0,0,31,43,0,61);
ramp(0,43,0,61,31,6,0,0);}

for i := 0 to 255 do
  begin
  rnd := random(8);
  for j := 0 to 255 do
    begin
    mem[tex:i shl 8+j] :=
    round((cos(j*2*pi/256)*31)+31)+rnd;
    end;
  end;
asm
    push ds
    mov  ds,tex
    push ds
    pop  es
    xor  di,di
    db 66h; mov  cx,0; dw 4;
@blup:
    xor  ax,ax
    mov  bl,[di+257]
    add  ax,bx
    mov  bl,[di-257]
    add  ax,bx
    mov  bl,[di+  1]
    add  ax,bx
    mov  bl,[di-  1]
    add  ax,bx
    shr  ax,2
    stosb
    db 66h; dec cx
    jnz  @blup
    pop  ds
end;
end;

procedure upd8water;
var k : word;
begin
for k := 0 to 255 do
begin
 ptab[k] := stab1[ang1 and 255]+stab1[ang2 and 255];
 inc(ang1,3);
 inc(ang2,4);
end;
inc(ang1,2);
inc(ang2,1);
end;

procedure dotunmap(b1,b2 : word);
var _di,dist : word;
    i,j      : integer;
    d,d1     : double;
begin
_di := 0;
for i := 0 to 199 do
  for j := 0 to 319 do
   begin
   d := i-ycent; d := d*d;
   d1 := j-xcent; d1 := d1*d1;
   d := sqrt(d+d1);
   dist := round(d);
   if dist = 0 then dist := 1;
   if (j-xcent) <> 0 then
    begin
    d1:= arctan((i-ycent)/(j-xcent))*(256/(2*pi));
    if j >= xcent then d1 := d1+128;
    d := 256*(eyedist*radius div dist)+round(d1);
    end
    else
    begin
    d1:= arctan(i-ycent)*(256/(2*pi));
    if j >= xcent then d1 := d1+128;
    d := 256*(eyedist*radius div dist)+round(d1);
    end;
   if _di < 32000 then
    memw[b1:_di shl 1] := round(d)
    else
    memw[b2:(_di-32000) shl 1] := round(d);
   inc(_di);
   end;
end;

begin
for i := 0 to 255 do stab1[i] := round((sin(i*2*pi/255)*8)+8);
for i := 0 to 255 do ptab[i] := stab1[i];
ang1 := 0;ang2 := 0;
end.
