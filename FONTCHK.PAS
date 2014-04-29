uses crt,palette;
const      SEQ_ADDR       = $3c4;
     fontsize = 17568; {lunghezza del file che contiene i font}
     infosize = 608;

type
     pfontbuf = ^tfontbuf;
     tfontbuf = array[0..fontsize-1] of byte;
var
     info                              : array[0..infosize-1] of byte;
     font                              : pfontbuf;
     i,_di                             : word;

procedure go360x240; external; {$L modex.obj}
{$I CHARPUT.INC}
procedure _write(x,y:word;stw : string);
var stwidx, spacer, stwl, letter: word;
begin
stwl := length(stw);
spacer := 0;
for stwidx := 1 to stwl do begin
letter:=(byte(stw[stwidx]))*8;
charput(info[3+letter]+(info[4+letter] shl 8),spacer+x,y+info[2+letter],info[0+letter],info[1+letter]);
inc(spacer,info[0+letter]+1);
end;
end;

procedure setupbuffers; {carica le info ed i font}
var fi,ff : file;
begin
getmem(font,sizeof(tfontbuf));
assign(fi,'botshdr.fnt');assign(ff,'botsdata.fnt');
reset(fi,1);reset(ff,1);
blockread(fi,info,infosize);
blockread(ff,font^,fontsize);
close(fi);close(ff);
end;

procedure putpixel(x,y:word;col:byte);
var _di : word;
    plane : byte;
begin
_di := y*90+(x shr 2);
plane := 1 shl (x and 3);
asm
    mov     ah,plane
    mov     dx,SEQ_ADDR
    mov     al,2
    out     dx,ax
END;
mem[$A000:_di] := col;
end;

function getpixel(x,y:word):byte;
var _di : word;
    plane : byte;
begin
_di := y*90+(x shr 2);
plane := 1 shl (x and 3);
asm
    mov     ah,plane
    mov     dx,3ceh
    mov     al,4
    out     dx,ax
end;
getpixel := mem[$A000:_di];
end;


begin
asm  mov   ax,13h; int   10h; end;
go360x240; {palette is cleared}
port[$3c8] := 1;
for i := 30 downto 0 do vgadac(i*2,i*2,i*2);
setupbuffers;
_write(0,0,#15#34#41#41#30#43#40);
_write(15,30,#54#0#45#22#60#2#20#54);
_write(19,60,#50#40#46#75#36#39#40#48#75#48#33#40#75#43#46#37#30#59);
_write(308,90,#0#1);
_write(7,120,#0#1#2#3#4#5#6#7#8#9#10#11#12#13#14#15#16#17);
_write(171,150,#52#54#55);
_write(171,180,#53#54#55);

{for i := 0 to 255 do
for _di := 1 to 10 do
putpixel(i,_di+200,i);

putpixel(19,68,16);
putpixel(360-19,68,16);
putpixel(349,90,16);}
getmem(font,sizeof(tfontbuf));
readkey;
asm mov ax,3h; int 10h; end;
end.
