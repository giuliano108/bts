{
-ÄÄÄ Aragorn ÄÄ-- / þCONTROL UNiTþ

Non Periodic B-Splines (used for movement)
}

unit splines;
interface

procedure bspline(var x,y : real; u : real);

implementation
const cpoints = 6;
type xyz = record  x,y : real; end;
     xyza= array[0..cpoints] of xyz;
const
      p : xyza = (
      (x: 35 ;y: 100),
      (x: 60 ;y: 160),
      (x: 300;y: 150),
      (x: 170;y: 20 ),
      (x: 300;y: 100),
      (x: 10 ;y: 10 ),
      (x: 35 ;y: 100));

var knotk,knotn : integer;

function knot(i : integer):integer;
begin
  if i < knotk then knot := 0 else
  if i > knotn then knot := knotn-knotk + 2 else
    knot := i - knotk + 1;
end;

function nblend(i,k:integer;u:real):real;
var
  t : integer; v : real;
begin
  if k = 1 then
  begin
    v := 0;
    if (knot(i) <= u) and (u < knot(i+1)) then v := 1
  end else
  begin
    v := 0;
    t := knot(i+k-1) - knot(i);
    if t <> 0 then v:= (u-knot(i))*nblend(i,k-1,u)/t;
    t := knot(i+k) - knot(i+1);
    if t <> 0 then
    v := v + (knot(i+k)-u)*nblend(i+1,k-1,u)/t;
  end;
  nblend := v;
end;

procedure bspline(var x,y : real; u : real);
var i : integer;b:real;
begin
knotk := 3; knotn := cpoints;
x := 0; y := 0;
for i := 0 to cpoints do
begin
  b := nblend(i,3,u);
  x := x + p[i].x*b;
  y := y + p[i].y*b;
end;
end;


begin
end.