{
-ÄÄÄ Aragorn ÄÄ-- / þCONTROL UNiTþ

3D stuff of BeyOnd the Sea
}

const maxfaces = 63; {plus one}
const maxverts = 97; {plus one}

const {3D stupidengine}
      camdist : word = 20000;
      pad        = 32768;
      min : byte = 0;
      max : byte = 1;
      pad2       = 256;
      clipl      = 0;
      clipr      = 319;
      clipt      = 0;
      clipb      = 199;


const {ZOOM}
      maxy {:integer} = 274;
      maxx {:integer} = 398;

type
coordt3D  = record x,y,z : integer; end;
facet     = record a,b,c,n : word; end; {vertices a,b,c offsets + normal}
pointlist = array[0..maxverts] of coordt3D;
facelist  = array[0..maxfaces] of facet;

var
  verts           : ^pointlist;
  tverts          : ^pointlist;
  faces           : ^facelist;
  angxy,
  angxz,
  angyz           : longint;
  st              : array[0..1024-1] of longint; {sin/cos table, angle = 0..1023}
  ct              : array[0..1024-1] of longint;
  minmax          : array[0..199,0..1] of word;

procedure calcobj;
var ca,cb,cc,sa,sb,sc,sacc,cacc,sasc,casc,e11,e21,e31,e12,e22,e32,e13,e23,e33 : longint;
begin

ca         := ct[angyz];
cb         := ct[angxz];
cc         := ct[angxy];
sa         := st[angyz];
sb         := st[angxz];
sc         := st[angxy];

sacc       := (sa*cc) div pad;
cacc       := (ca*cc) div pad;
sasc       := (sa*sc) div pad;
casc       := (ca*sc) div pad;

e11 := (cb*cc) div pad;
e21 := casc-(sb*sacc) div pad;
e31 := (sb*cacc) div pad+sasc;

e12 := (-cb*sc) div pad;
e22 := (sb*sasc) div pad+cacc;
e32 := sacc-(sb*casc) div pad;

e13 := -sb;
e23 := (-sa*cb) div pad;
e33 := (ca*cb) div pad;

for i := 0 to maxverts do
begin
  tverts^[i].x := (verts^[i].x*e11+verts^[i].y*e21+verts^[i].z*e31) div pad;
  tverts^[i].y := (verts^[i].x*e12+verts^[i].y*e22+verts^[i].z*e32) div pad;
  tverts^[i].z := (verts^[i].x*e13+verts^[i].y*e23+verts^[i].z*e33) div pad;
end;
end;

procedure horline(xb,xe,y:integer; c:byte;vbuf : word); assembler;
asm
  mov bx,xb
  mov cx,xe
  cmp bx,cx
  jb @skip
  xchg bx,cx
 @skip:
  inc cx
  sub cx,bx
  mov es,vbuf
  mov ax,y
  shl ax,6
  mov di,ax
  shl ax,2
  add di,ax
  add di,bx
  mov al,c
  shr cx,1
  jnc @skip2
  stosb
 @skip2:
  mov ah,al
  rep stosw
 @out:
end;

function MinI(A,B:Integer):Integer;
inline(
$58/                       {pop   ax       }
$5B/                       {pop   bx       }
$3B/$C3/                   {cmp   ax,bx    }
$7C/$01/                   {jl    +1       }
$93);                      {xchg  ax,bx    }

{$I fillers.inc}

procedure drawobj(vbuf : word);
{light vector}
const lx = 0;
      ly = 0;
      lz = 32767;
var xp1,yp1,xp2,yp2,xp3,yp3 : longint;
    col : word;

begin
for i := 0 to maxfaces do
begin

 xp1:= (((longint(tverts^[faces^[i].a].x) shl 8) div (tverts^[faces^[i].a].z+camdist)) + 160);
 yp1:= (((longint(tverts^[faces^[i].a].y) shl 8) div (tverts^[faces^[i].a].z+camdist)) + 100);
 xp2:= (((longint(tverts^[faces^[i].b].x) shl 8) div (tverts^[faces^[i].b].z+camdist)) + 160);
 yp2:= (((longint(tverts^[faces^[i].b].y) shl 8) div (tverts^[faces^[i].b].z+camdist)) + 100);
 xp3:= (((longint(tverts^[faces^[i].c].x) shl 8) div (tverts^[faces^[i].c].z+camdist)) + 160);
 yp3:= (((longint(tverts^[faces^[i].c].y) shl 8) div (tverts^[faces^[i].c].z+camdist)) + 100);

{check the 2D normal}
if ((xp1-xp2)*(yp1-yp3) - (yp1-yp2)*(xp1-xp3)) < 0 then
  begin
  col := abs(tverts^[faces^[i].n].z) div 512;
  if
    not(
    (xp1 > clipr) or (xp2 > clipr) or (xp3 > clipr) or
    (xp1 < clipl) or (xp2 < clipl) or (xp3 < clipl) or
    (yp1 > clipb) or (yp2 > clipb) or (yp3 > clipb) or
    (yp1 < clipt) or (yp2 < clipt) or (yp3 < clipt)) then
    flatfill(xp1,yp1,xp2,yp2,xp3,yp3,col,vbuf)
    else if
      not(
      ((xp1 > clipr) and (xp2 > clipr) and (xp3 > clipr)) or
      ((xp1 < clipl) and (xp2 < clipl) and (xp3 < clipl)) or
      ((yp1 > clipb) and (yp2 > clipb) and (yp3 > clipb)) or
      ((yp1 < clipt) and (yp2 < clipt) and (yp3 < clipt))) then
      flatfillc(xp1,yp1,xp2,yp2,xp3,yp3,col,vbuf);
  end;
end;
end;

{$L bluras.obj}
function fireline(src,srcoff,dst,dstoff,numba : word;carr : longint):longint; external;

procedure firescr(src,dst : word);
var
 i : word;
 carry : longint;
begin
 carry := 0;
 for i := 1 to 199 do
   carry:=fireline(src,i*320+4,dst,i*320+4, 39, carry);
end;

var  facs : array[0..199] of longint; {Helds source DIs (for zoommin'}
var  incry: word;
procedure zoom(ins,outs : word); forward;
procedure setupzoom(zf : single);
var incrx : word;
    zspos       : longint;
    tmp         : pointer;
    zoomofs     : word;
begin
incrx   := round(254/zf);
incry   := round(254/zf);
zspos   := ((((maxy-trunc(maxy/zf)) div 2)*320+((maxx-trunc(maxx/zf))div 2)) shl 8);

zoomofs := ofs(zoom);
asm
                {let's do a bit of code-patching....}
                jmp     @skip {not really needed....}
                @skip:
                mov     di,zoomofs
                add     di,19
                db $66; mov ax,word ptr zspos;
                db $66; mov word ptr cs:[di],ax;
                add     di,37
                mov     ax,incrx
                mov     cs:[di],ax
                {facs table precalc}
                push    bp
                xor     bx,bx
                xor     dx,dx
                push    ds
                pop     es
                mov     di,offset facs
                db 66h; mov ax,4000h; dw 0001h {320 shl 8 = 14000h}
                db 66h; stosw
                mov     cx,199
@facsloop:      mov     ax,bx
                shr     ax,8
                mov     bp,ax
                cmp     ax,dx
                jne     @facs1
                db 66h; xor     ax,ax
                jmp     @facs2
@facs1:         db 66h; mov ax,4000h; dw 0001h
@facs2:         db 66h; stosw
                mov     dx,bp
                add     bx,incry
                loop    @facsloop
                pop     bp
end;
end;

var pcx1 : word;
    pesi : longint;

procedure zoom(ins,outs : word); assembler;
asm
                push    bp
                db 8Eh,66h,06h {mov     fs,ins}
                mov     es,outs
{                db 66h; mov si,lozspos; dw hizspos;}
                db 66h; mov si,$3412; dw $7856;
                xor     di,di
                mov     cx,200
@zomy:          mov     pcx1,cx
                db 66h; mov     word ptr pesi,si
                mov     cx,320
@zomx:          db 66h; mov     bp,si
                db 66h; shr     bp,8
                db 64h,67h,8Ah,45h,00h {mov     al,fs:[ebp]}
                stosb
{                db 66h; add     si,incrx; dw 0;}
                db 66h; add     si,$3412; dw $0;
                loop    @zomx
                db 66h; mov     si,word ptr pesi
                mov     cx,pcx1
                mov     bp,200
                sub     bp,cx
                shl     bp,2
                db 66h; add     si,word ptr ds:facs[bp]
                loop    @zomy
                pop     bp
end;

procedure diamond; external; {$L dia.obj}