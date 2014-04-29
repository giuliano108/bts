{
-ÄÄÄ Aragorn ÄÄ-- / þCONTROL UNiTþ

bit packed picture encoder/decoder
}
uses crt,readrgf,palette;
type
    tarr  = array[0..65520] of byte;
    ptarr = ^tarr;
var
    f       : file;
    m13     : array[0..63999] of byte absolute $a000:0000;
    eimg    : ptarr;
    encodedsize : word;

procedure bppencode(source,dest:ptarr;w,h:word);
var mask,
    cbit : byte;
    i,j,
    _si,
    _di  : word;
begin
_si  := 0;
_di  := 0;
cbit := 0;
for i := 1 to h do
begin
  for j := 1 to w do
  begin
  mask := 0;
  if boolean(source^[_si]) then mask := 1;
  mask := mask shl cbit;
  dest^[_di] := dest^[_di] or mask;
  inc(cbit);
  if cbit = 8 then begin inc(_di); cbit:= 0; end;
  inc(_si);
  end;
inc(_si,320-w)
end;
encodedsize := _di;
end;

procedure bppdecode(source,dest:ptarr;w,h:word);
var cbit : byte;
    i,j,
    _si,
    _di  : word;
begin
_si  := 0;
_di  := 0;
cbit := 0;
for i := 1 to h do
begin
  for j := 1 to w do
  begin
  dest^[_di] := ((source^[_si] shr cbit) and 1);
  inc(cbit);
  if cbit = 8 then begin inc(_si); cbit:= 0; end;
  inc(_di);
  end;
inc(_di,320-w);
end;
end;
procedure bmpdrop; external; {$L droppic.obj}

var i : word;
begin
asm  mov   ax,13h; int   10h; end;
new(eimg);
fillchar(eimg^,64000,0);
read_rgf('bmpdrop.rgf',0,0);
port[$3c8] := 1;
vgadac(63,0,0);
bppencode(@m13,eimg,19,19);
{bppdecode(eimg,@m13,19,19);}
readkey;
bppdecode(@bmpdrop,@m13,19,19);
readkey;
asm  mov   ax, 3h; int   10h; end;
writeln('Encoded size : ',encodedsize);
{
assign(f,'bmpdrop.bpp');
rewrite(f,1);
blockwrite(f,eimg^,encodedsize);
close(f);
dispose(eimg);
}
end.