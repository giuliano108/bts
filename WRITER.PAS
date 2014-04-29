{
-ÄÄÄ Aragorn ÄÄ-- / þCONTROL UNiTþ

credits/greetings writer
}

unit writer;
interface
uses globals,palette;

const
           nup      = 8;  {number of pages}
           eop      = 32; {end of page marker}
           yspacing = 30;
           fontsize = 9036;
           infosize = 256;

type
     pfontbuf = ^tfontbuf;
     tfontbuf = array[0..fontsize-1] of byte;
     pfinfo   = ^tfinfo;
     tfinfo   = array[0..infosize-1] of byte;
     pstring  = pfontbuf; {Just to have an array of bytes}

var
     info                              : pfinfo;
     font                              : pfontbuf;
const
     pagecnt                           : word = 0;      {page counter}
     pageadv                           : boolean = true;{advance page flag}

procedure fonthdr;
procedure fontdatabp;

procedure dopage;
procedure calcpals(iframe:longint);

implementation
procedure fonthdr; external; {$L fonthdr.obj}
procedure fontdatabp; external; {$L fdbp.obj}
procedure endtext; external; {$L endtext.obj}

procedure charput(offs,x,y:word;w,h:word); assembler;
asm
        mov     es,buf2
        mov     bx,x
        mov     dx,y
        xchg    dh,dl
        mov     di,dx
        shr     di,2
        add     di,dx
        add     di,bx
        mov     bx,320
        sub     bx,w
        push    ds
        push    bp
        mov     dx,h
        lds     si,font
        add     si,offs
        mov     bp,w
@ly:    mov     cx,bp
@xl:    lodsb
        add     es:[di],al
        inc     di
        loop    @xl
        add     di,bx
        dec     dx
        jnz     @ly
        pop     bp
        pop     ds
end;


procedure _write(x,y:word;stw : pstring);
var stwidx, spacer, stwl, letter: word;
begin
stwl := stw^[0];
spacer := 0;
for stwidx := 1 to stwl do begin
letter:=stw^[stwidx] shl 3;
charput(info^[3+letter]+(info^[4+letter] shl 8),spacer+x,y+info^[2+letter],info^[0+letter],info^[1+letter]);
inc(spacer,info^[0+letter]+1);
end;
end;

var ps : pstring;
    sx : ^word;

var oldps : pointer;
procedure dopage;
var cy : word;
begin
if pagecnt > nup then exit;
if not pageadv then
  ps := oldps
  else
  begin
  oldps := ps;
  inc(pagecnt);
  end;
pageadv := false;
cy := 10;
repeat
  sx   := pointer(ps);
  ps   := @ps^[2];
  _write(sx^,cy,ps);
  ps := @ps^[ps^[0]+1];
  inc(cy,yspacing);
until ps^[3] = eop;
ps := @ps^[4];
end;

procedure calcpals(iframe:longint);
begin
    if iframe in [0..127] then calcparpal(iframe,127,0,128*3,ofs(pal1),ofs(palf),ofs(pala),fadeup);
    if (iframe >= (128+150)) and (iframe <= (128+150+127))
                          then calcparpal(iframe-(128+150),127,0,128*3,ofs(pal1),ofs(palf),ofs(pala),fadedn);
end;

begin
  ps   := @endtext;
end.