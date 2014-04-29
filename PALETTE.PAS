{
-ÄÄÄ Aragorn ÄÄ-- / þCONTROL UNiTþ

Palette handling routines (v1.8)
}
unit palette;
interface
const fadeup  = true;
      fadedn  = false;
      dacramp = true;
      buframp = false;

type
paltype      = array[0..767] of byte;
paladdtype   = array[0..767] of word;
palfixedtype = array[0..767] of word;

procedure retrace;
procedure setborder(bordercolor : byte);
procedure setpal(startcol:byte;colors,palofs:word);
procedure getpal(startcol:byte;colors,palofs:word);
procedure setfixpal(startcol:byte;colors,palofs:word);
procedure fillfixpal(r,g,b : byte;startcol,colors,palofs:word);
procedure blackpal(startcol:byte;colors:word);
procedure palnormtofix(palofs,palfixofs : word);
procedure fadetocolsetup(steps,r,g,b : byte;palofs,palfixofs,addofs : word);
procedure fadefromcolsetup(steps,r,g,b : byte;palofs,palfixofs,addofs : word);
procedure fadepaltopalsetup(steps : byte;sourcepalofs,destpalofs,palfixofs,addofs : word);
procedure fadestep(palfixofs,addofs : word);
procedure fadestepinv(palfixofs,addofs : word);
procedure vgadac(r,g,b:byte);
procedure vgacol(col,r,g,b:byte);
procedure ramp(scol,r1,g1,b1,ecol,r2,g2,b2:byte;rampwhere:boolean;palofs:word);
procedure rampsin(scol,r1,g1,b1,ecol,r2,g2,b2:byte;rampwhere:boolean;palofs:word);
{
paltick        : current time tick (with paltick = 0 we have the source palette)
maxtick        : the maximum time tick, at which we have the destination palette
startcol       : starting color (multiply it by 3 before !!!!)
colors         : number of colors to upd8 (multiply it by 3 before !!!!)
psofs          : source pal offset (normal, not fixed point (paltype))
pfofs          : fixed point pal offset (the palette currently being upd8ed)
paofs          : palette adder offset
updown         : we are fading from source to dest or from dest to source
}
procedure calcparpal(paltick,maxtick:word;startcol,colors,psofs,pfofs,paofs:word;updown : boolean);
procedure palfixtonorm(palfixofs,palofs : word);

implementation

procedure retrace; assembler;
asm
                mov     dx, 03DAh
@@WEND:         in      al, dx
                and     al, 08h
                jnz     @@WEND
@@WSTAR:        in      al, dx
                and     al, 08h
                jz      @@WSTAR
end;

procedure setborder(bordercolor : byte); assembler;
asm
	mov	dx,3dah
	in	al,dx
	mov	dx,3c0h
	mov	al,11h+32
	out	dx,al
	mov	al,bordercolor
	out	dx,al
end;

procedure setpal(startcol:byte;colors,palofs:word); assembler;
asm
        mov     si,palofs
        mov     dx,03c8h
        mov     al,startcol
        out     dx,al
        inc     dx
        mov     cx,colors
@cloop: outsb
        outsb
        outsb
        loop    @cloop
end;

procedure getpal(startcol:byte;colors,palofs:word); assembler;
asm
        mov     ax,ds
        mov     es,ax
        mov     di,palofs
        mov     dx,03c7h
        mov     al,startcol
        out     dx,al
        add     dx,2
        mov     cx,colors
@cloop: insb
        insb
        insb
        loop    @cloop
end;


procedure setfixpal(startcol:byte;colors,palofs:word); assembler;
asm
        mov     si,palofs
        inc     si
        mov     dx,03c8h
        mov     al,startcol
        out     dx,al
        inc     dx
        mov     cx,colors
@cloop: outsb
        inc     si
        outsb
        inc     si
        outsb
        inc     si
        loop    @cloop
end;

procedure fillfixpal(r,g,b : byte;startcol,colors,palofs:word); assembler;
asm
        mov     di,startcol
        add     di,di
        add     di,palofs
        mov     ax,ds
        mov     es,ax
        mov     ah,r
        mov     bl,g
        mov     bh,b
        mov     cx,colors
@cloop: mov     al,0
        stosb
        mov     al,ah
        stosb
        mov     al,0
        stosb
        mov     al,bl
        stosb
        mov     al,0
        stosb
        mov     al,bh
        stosb
        loop    @cloop
end;

procedure blackpal(startcol:byte;colors:word); assembler;
asm
        mov     dx,03c8h
        mov     al,startcol
        out     dx,al
        inc     dx
        mov     cx,colors
        mov     al,0
@cloop: out     dx,al
        out     dx,al
        out     dx,al
        loop    @cloop
end;

procedure palnormtofix(palofs,palfixofs : word);
var i,j,c : word;
begin
c := 0;
i := palofs;
j := palfixofs;
repeat
mem[dseg:j] := 0;
inc(j);
mem[dseg:j] := mem[dseg:i];
inc(i);
inc(j);
inc(c);
until c = 768;
end;

procedure fadetocolsetup(steps,r,g,b : byte;palofs,palfixofs,addofs : word);
var i,j,c : word;
begin
c := 0;
i := palofs;
j := addofs;
repeat
memw[dseg:j] := ((r-mem[dseg:i]) shl 8) div steps;
inc(i);inc(j,2);
memw[dseg:j] := ((g-mem[dseg:i]) shl 8) div steps;
inc(i);inc(j,2);
memw[dseg:j] := ((b-mem[dseg:i]) shl 8) div steps;
inc(i);inc(j,2);
inc(c);
until c = 256;
palnormtofix(palofs,palfixofs);
end;

procedure fadefromcolsetup(steps,r,g,b : byte;palofs,palfixofs,addofs : word);
var i,j,c : word;
begin
c := 0;
i := palofs;
j := addofs;
repeat
memw[dseg:j] := ((mem[dseg:i]-r) shl 8) div steps;
inc(i);inc(j,2);
memw[dseg:j] := ((mem[dseg:i]-g) shl 8) div steps;
inc(i);inc(j,2);
memw[dseg:j] := ((mem[dseg:i]-b) shl 8) div steps;
inc(i);inc(j,2);
inc(c);
until c = 256;
fillfixpal(r,g,b,0,256,palfixofs);
end;

procedure fadepaltopalsetup(steps : byte;sourcepalofs,destpalofs,palfixofs,addofs : word);
var i,j,k,c : word;
begin
c := 0;
i := sourcepalofs;
k := destpalofs;
j := addofs;
repeat
memw[dseg:j] := ((mem[dseg:k]-mem[dseg:i]) shl 8) div steps;
inc(i);inc(k);inc(j,2);
memw[dseg:j] := ((mem[dseg:k]-mem[dseg:i]) shl 8) div steps;
inc(i);inc(k);inc(j,2);
memw[dseg:j] := ((mem[dseg:k]-mem[dseg:i]) shl 8) div steps;
inc(i);inc(k);inc(j,2);
inc(c);
until c = 256;
palnormtofix(sourcepalofs,palfixofs);
end;

procedure fadestep(palfixofs,addofs : word);
var i,j,c : word;
begin
c := 0;
i := addofs;
j := palfixofs;
repeat
inc(memw[dseg:j],memw[dseg:i]);
inc(i,2);
inc(j,2);
inc(c);
until c = 768;
end;

procedure fadestepinv(palfixofs,addofs : word);
var i,j,c : word;
begin
c := 0;
i := addofs;
j := palfixofs;
repeat
dec(memw[dseg:j],memw[dseg:i]);
inc(i,2);
inc(j,2);
inc(c);
until c = 768;
end;

procedure vgadac(r,g,b:byte);
begin
port[$3C9] := r; port[$3C9] := g; port[$3C9] := b;
end;

procedure vgacol(col,r,g,b:byte);
begin
port[$3c8] := col;
port[$3C9] := r; port[$3C9] := g; port[$3C9] := b;
end;

procedure vgadacpal(r,g,b:byte;rampwhere:boolean;palofs:word;i:word);
begin
if rampwhere then
   vgadac(r,g,b)
   else
   asm
   push ds
   pop  es
   mov  di,i
   add  di,di
   add  di,i
   add  di,palofs
   mov  al,r
   stosb
   mov  al,g
   stosb
   mov  al,b
   stosb
   end;
end;

procedure ramp(scol,r1,g1,b1,ecol,r2,g2,b2:byte;rampwhere:boolean;palofs:word);
var i:word;
    r,g,b:real;
begin
  i:=scol;
  r:=(r2-r1)/(ecol-scol);
  g:=(g2-g1)/(ecol-scol);
  b:=(b2-b1)/(ecol-scol);
  repeat
    vgadacpal(r1+round(r*(i-scol)),g1+round(g*(i-scol)),b1+round(b*(i-scol)),rampwhere,palofs,i);
    inc(i);
  until i=ecol+1;
end;

procedure rampsin(scol,r1,g1,b1,ecol,r2,g2,b2:byte;rampwhere:boolean;palofs:word);
var i:word;
    r,g,b:real;
begin
  i:=scol;
  r:=(pi/2)/(ecol-scol);
  g:=(pi/2)/(ecol-scol);
  b:=(pi/2)/(ecol-scol);
  repeat
    vgadac(r1+round(sin(r*(i-scol))*(r2-r1)),g1+round(sin(g*(i-scol))*(g2-g1)),b1+round(sin(b*(i-scol))*(b2-b1)));
    inc(i);
  until i=ecol+1;
end;

procedure calcparpal(paltick,maxtick:word;startcol,colors,psofs,pfofs,paofs:word;updown : boolean); assembler;
asm
    mov    bl,updown
    mov    ax,maxtick
    cmp    ax,paltick
    jnb    @skip
    mov    paltick,ax
@skip:
    or     bl,bl
    jnz    @skip2
    sub    ax,paltick
    mov    paltick,ax
@skip2:
    mov    si,startcol
    add    si,psofs
    mov    di,startcol
    add    di,di
    mov    cx,colors
@peloop:
    mov    bx,paofs
    mov    ax,bx[di]
    imul   paltick
    mov    bx,ax
    lodsb
    mov    ah,0
    shl    ax,8
    add    ax,bx
    mov    bx,pfofs
    mov    ds:bx[di],ax
    inc    di
    inc    di
    loop   @peloop
end;

procedure palfixtonorm(palfixofs,palofs : word); assembler;
asm
   mov  ax,ds
   mov  es,ax
   mov  si,palfixofs
   mov  di,palofs
   mov  cx,768
@lup:
   lodsw
   mov  al,ah
   stosb
   loop @lup
end;


begin
end.
