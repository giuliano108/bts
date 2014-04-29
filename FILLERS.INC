
{flat triangle filler}
procedure flatfill(xa,ya,xb,yb,xc,yc:integer;color : byte;vbuf : word);
var
x1,y1,x2,y2,x3,y3,slope,
x,temp                      : longint;
i                           : word;
begin
min := 0;
max := 1;

{ vertex 1 must be the one with the lowest y }
y1 := mini(mini(ya,yb),yc);
if y1 = ya then
  begin
  x1 := xa;
  x2 := xb;
  y2 := yb;
  x3 := xc;
  y3 := yc;
  end else
  if y1 = yb then
    begin
    x1 := xb;
    x2 := xa;
    y2 := ya;
    x3 := xc;
    y3 := yc;
    end else
    begin
    x1 := xc;
    x2 := xa;
    y2 := ya;
    x3 := xb;
    y3 := yb;
    end;

if (y2 > y3) then
   begin
   {swap x}
   temp := x3;
   x3   := x2;
   x2   := temp;
   {swap y}
   temp := y3;
   y3   := y2;
   y2   := temp;
   end;

    if y1 <> y2 then
    begin
    slope := ((x2-x1)*pad2) div (y2-y1);
    x := x1 * pad2;
    for i := y1 to y2 do
      begin
      minmax[i,min] := x div pad2;
      inc(x,slope);
      end;
    end else minmax[y1,min] := x1;

    if y1 <> y3 then
    begin
    slope := ((x3-x1)*pad2) div (y3-y1);
    x := x1 * pad2; {thiz mul can be left out!!!!!}
    for i := y1 to y3 do
      begin
      minmax[i,max] := x div pad2;
      inc(x,slope);
      end;
    end else minmax[y1,max] := x1;

    if y2 <> y3 then
    begin
    slope := ((x3-x2)*pad2) div (y3-y2);
    x := x2 * pad2;
    for i := y2 to y3 do
      begin
      minmax[i,min] := x div pad2;
      inc(x,slope);
      end;
    end else minmax[y2,min] := x2;

{check if min/max are correct, else flip}
if minmax[y2,min] > minmax[y2,max] then
begin
min := 1;
max := 0;
end;
for i := y1 to y3 do
begin
horline(minmax[i,min],minmax[i,max],i,color,vbuf);
end;
end;

type tvrtx = record x,y : integer end;
var cpoly,
    spoly  : array[0..20] of tvrtx;
    csi,cdi : word;

function intersecav(v1,v2:tvrtx;cedge:integer) : boolean;
begin
intersecav := false;
if ((v1.x < cedge) and (v2.x > cedge)) or
   ((v1.x > cedge) and (v2.x < cedge)) then intersecav := true;
end;

function intersecah(v1,v2:tvrtx;cedge:integer) : boolean;
begin
intersecah := false;
if ((v1.y < cedge) and (v2.y > cedge)) or
   ((v1.y > cedge) and (v2.y < cedge)) then intersecah := true;
end;
{
procedure intersezionev(v1,v2:tvrtx;cedge : integer);
begin
    cpoly[cdi].y := v1.y+longint(v2.y-v1.y)*longint(cedge-v1.x) div (v2.x-v1.x);
    cpoly[cdi].x := cedge;
    inc(cdi);
end;
}
{
procedure intersezionev(v1,v2:tvrtx;cedge : integer);
var p : longint;
begin
    p := (longint(v2.y-v1.y)*longint(cedge-v1.x) shl 5) div (v2.x-v1.x)+(v1.y shl 5);
    asm
      db 66h; sar word ptr p,5
    end;
    cpoly[cdi].y := p;
    cpoly[cdi].x := cedge;
    inc(cdi);
end;
}

procedure intersezionev(v1,v2:tvrtx;cedge : integer);
begin
    cpoly[cdi].y := v1.y+round(longint(v2.y-v1.y)*longint(cedge-v1.x) / (v2.x-v1.x));
    cpoly[cdi].x := cedge;
    inc(cdi);
end;

{
procedure intersezioneh(v1,v2:tvrtx;cedge : integer);
begin
    spoly[cdi].x := v1.x+longint(v2.x-v1.x)*longint(cedge-v1.y) div (v2.y-v1.y);
    spoly[cdi].y := cedge;
    inc(cdi);
end;
}

procedure intersezioneh(v1,v2:tvrtx;cedge : integer);
begin
    spoly[cdi].x := v1.x+round(longint(v2.x-v1.x)*longint(cedge-v1.y) / (v2.y-v1.y));
    spoly[cdi].y := cedge;
    inc(cdi);
end;

procedure flatfillc(xa,ya,xb,yb,xc,yc:word;c:byte;vbuf:word);
var f,p,s : tvrtx;
    l     : byte;
begin
spoly[0].x := xa;
spoly[0].y := ya;
spoly[1].x := xb;
spoly[1].y := yb;
spoly[2].x := xc;
spoly[2].y := yc;
csi := 0;
cdi := 0;
repeat
p := spoly[csi];
if csi = 0 then f := p
  else
    if intersecav(s,p,clipr) then intersezionev(s,p,clipr);
s := p;
if s.x <= clipr then begin cpoly[cdi] := s; inc(cdi); end;
inc(csi);
until csi = 3;
if intersecav(s,f,clipr) then intersezionev(s,f,clipr);

l := cdi;
if l <= 2 then exit;
csi := 0;
cdi := 0;
repeat
p := cpoly[csi];
if csi = 0 then f := p
  else
    if intersecah(s,p,clipt) then intersezioneh(s,p,clipt);
s := p;
if s.y >= clipt then begin spoly[cdi] := s; inc(cdi); end;
inc(csi);
until csi = l;
if intersecah(s,f,clipt) then intersezioneh(s,f,clipt);

l := cdi;
if l <= 2 then exit;
csi := 0;
cdi := 0;
repeat
p := spoly[csi];
if csi = 0 then f := p
  else
    if intersecav(s,p,clipl) then intersezionev(s,p,clipl);
s := p;
if s.x >= clipl then begin cpoly[cdi] := s; inc(cdi); end;
inc(csi);
until csi = l;
if intersecav(s,f,clipl) then intersezionev(s,f,clipl);

l := cdi;
if l <= 2 then exit;
csi := 0;
cdi := 0;
repeat
p := cpoly[csi];
if csi = 0 then f := p
  else
    if intersecah(s,p,clipb) then intersezioneh(s,p,clipb);
s := p;
if s.y <= clipb then begin spoly[cdi] := s; inc(cdi); end;
inc(csi);
until csi = l;
if intersecah(s,f,clipb) then intersezioneh(s,f,clipb);

if cdi <= 2 then exit;
csi := 1;
repeat
flatfill(spoly[csi].x,spoly[csi].y,spoly[csi+1].x,spoly[csi+1].y,spoly[0].x,spoly[0].y,c,vbuf);
inc(csi);
until csi = cdi-1;

end;
