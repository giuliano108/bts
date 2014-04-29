{
-ÄÄÄ Aragorn ÄÄ-- / þCONTROL UNiTþ

2D bump mapping routines

buf1 : videobuffer
buf2 : bump map
buf3 : spot
}
unit bump;
interface
uses globals,palette;

procedure makespot;
procedure dobmap;
procedure movespot(centx,centy:word);

implementation
procedure makespot;
var i,j : word;
    dist : longint;
begin
for i := 64 to 127 do
  for j := 64 to 127 do
    begin
    dist := round(sqrt((i-64)*(i-64)+(j-64)*(j-64))/1.11);
    if dist > 63 then dist := 63;
    mem[buf3:i*128+j] := 63-dist;
    mem[buf3:(127-i)*128+(127-j)] := 63-dist;
    mem[buf3:(127-i)*128+j] := 63-dist;
    mem[buf3:i*128+(127-j)] := 63-dist;
    end;
end;

procedure dobmap;
var i,j : word;
begin
port[$3c8] := 0;
ramp(0,0,0,0,1,0,0,0,dacramp,0);
ramp(2,0,0,0,30,45,0,55,dacramp,0);
rampsin(31,48,0,55,63,63,63,63,dacramp,0);
ramp(64,63,63,63,103,63,63,63,dacramp,0);      {colors 0..103 (31norm+33sin+40sat)}
port[$3c8] := 108;
ramp(104,0,0,0,134,63,32,0,dacramp,0);
rampsin(135,63,32,0,167,63,63,63,dacramp,0);
ramp(168,63,63,63,207,63,63,63,dacramp,0);
for i:=0 to 319 do for j:=0 to 199 do mem[buf2:j*320+i] := round(sin(i*j/6.32)*8);
end;

{$L bumpspot}
procedure movespot(centx,centy:word);external;

begin
end.