{
font stuff
-ÄÄÄ Aragorn ÄÄ-- / þCONTROL UNiTþ
}

{$L botshdr.obj} procedure finfo; external;
{$L botsdata.obj}procedure fdata; external;

procedure putspr(x1,y1,w,h,dest:word;source:pointer);
var i,j,_di,_si,dia : word;
begin
_di := y1*320+x1;
_si := ofs(source^);
dia := 320-w;
for i := 1 to h do
 begin
 for j := 1 to w do
  begin
  if mem[seg(source^):_si] <> 1 then mem[dest:_di] := mem[seg(source^):_si];
  inc(_si);
  inc(_di);
  end;
 inc(_di,dia);
 end;
end;
