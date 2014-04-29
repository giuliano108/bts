{ -ÄÄÄ Aragorn the Wanderer ÄÄ-- / þCONTROL UNiTþ
sbatte un bitmap sullo schermo in modo X 360x240x256
versione ottimizzata: unrolled plane loop ecc. ecc.
}
procedure charput(offs,x,y:word;w,h:byte); {versione 3: unrolled plane loop}
var plane,yl,xl,pl,pt,more : byte;
    planeloop : array[0..3] of byte;
    _di,_si,pdi,psi,pdi2,psi2 : word;
begin
plane := x and 3;
more  := w and 3;
pl    := w shr 2;
planeloop[0] := pl;
planeloop[1] := pl; planeloop[2] := pl; planeloop[3] := pl;
for pl := 1 to more do inc(planeloop[pl]); {---->   :-((((( }
pt    := 1;
plane := pt shl plane;
_di := (y*90)+(x shr 2);
{_di := yx90[y]+(x shr 2);}
_si := offs;
{first plane}
pdi2 := _di;
psi2 := _si;
asm
                mov  dx,seq_addr
                mov  al,2
                mov  ah,plane
                out  dx,ax
end;
for xl := 1 to planeloop[1] do
    begin
    pdi := _di;
    psi := _si;
    for yl := 1 to h do
        begin
        mem[$A000:_di] := font^[_si];
        inc(_si,w);
        inc(_di,90); {manda a capo....}
        end;
    _si := psi+4;
    _di := pdi+1;
    end;
    plane := plane shl 1; {prossimo piano}
    _di := pdi2;  {pop di}
    pt := plane shr 4;
    inc(_di,pt);         {sel il piano era 10000b incra DI}
    inc(plane,pt);
    plane := plane and 15;{and 1111b}
    _si := psi2+1;
{second plane}
pdi2 := _di;
psi2 := _si;
asm
                mov  dx,seq_addr
                mov  al,2
                mov  ah,plane
                out  dx,ax
end;
for xl := 1 to planeloop[2] do
    begin
    pdi := _di;
    psi := _si;
    for yl := 1 to h do
        begin
        mem[$A000:_di] := font^[_si];
        inc(_si,w);
        inc(_di,90); {manda a capo....}
        end;
    _si := psi+4;
    _di := pdi+1;
    end;
    plane := plane shl 1; {prossimo piano}
    _di := pdi2;  {pop di}
    pt := plane shr 4;
    inc(_di,pt);         {sel il piano era 10000b incra DI}
    inc(plane,pt);
    plane := plane and 15;{and 1111b}
    _si := psi2+1;
{third plane}
pdi2 := _di;
psi2 := _si;
asm
                mov  dx,seq_addr
                mov  al,2
                mov  ah,plane
                out  dx,ax
end;
for xl := 1 to planeloop[3] do
    begin
    pdi := _di;
    psi := _si;
    for yl := 1 to h do
        begin
        mem[$A000:_di] := font^[_si];
        inc(_si,w);
        inc(_di,90); {manda a capo....}
        end;
    _si := psi+4;
    _di := pdi+1;
    end;
    plane := plane shl 1; {prossimo piano}
    _di := pdi2;  {pop di}
    pt := plane shr 4;
    inc(_di,pt);         {sel il piano era 10000b incra DI}
    inc(plane,pt);
    plane := plane and 15;{and 1111b}
    _si := psi2+1;
{fourth plane}
asm
                mov  dx,seq_addr
                mov  al,2
                mov  ah,plane
                out  dx,ax
end;
for xl := 1 to planeloop[0] do
    begin
    pdi := _di;
    psi := _si;
    for yl := 1 to h do
        begin
        mem[$A000:_di] := font^[_si];
        inc(_si,w);
        inc(_di,90); {manda a capo....}
        end;
    _si := psi+4;
    _di := pdi+1;
    end;
end;
