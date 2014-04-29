; bump mapping spot routine
; by...
; -ÄÄÄ Aragorn ÄÄ-- / þCONTROL UNiTþ

        o equ offset
        b equ byte ptr
        w equ word ptr
        d equ dword ptr

.386
jumps

Data Segment Word Use16
extrn _di:word
extrn pdi:word
extrn _si:word
extrn psi:word
extrn pcx:word
extrn buf1:word
extrn buf2:word
extrn buf3:word
Data EndS

Code Segment DWord Use16

Assume CS: Code, DS: Data

public movespot

movespot proc pascal far
arg centx:word,centy:word
local starty:word,startx:word,endx:word,endy:word,smx:word,smy:word
local limitx:word
           mov    smx,0
           mov    smy,0
           mov    ax,centx
           mov    bx,centy
           mov    cx,ax
           sub    cx,63
           mov    startx,cx
           mov    cx,bx
           sub    cx,63
           mov    starty,cx
           add    ax,64
           mov    endx,ax
           add    bx,64
           mov    endy,bx
           cmp    startx,1
           jge    uxclip
           mov    startx,1
           mov    smx,63
           mov    ax,centx
           sub    smx,ax
uxclip:    cmp    starty,1
           jge    uyclip
           mov    starty,1
           mov    smy,63
           mov    ax,centy
           sub    smy,ax
uyclip:    cmp    endx,318
           jle    lxclip
           mov    endx,318
lxclip:    cmp    endy,198
           jle    lyclip
           mov    endy,198
lyclip:    mov    bx,startx
           mov    dx,starty
           xchg   dh,dl
           mov    di,dx
           shr    di,2
           add    di,dx
           add    di,bx
           mov    si,smy
           shl    si,7
           add    si,smx
           push   ds
           mov    cx,endx
           sub    cx,startx
           mov    limitx,cx
           mov    es,buf1
           mov    fs,buf3
           mov    gs,buf2
           mov    cx,endy
           sub    cx,starty
bsy:       mov    pcx,cx
           mov    pdi,di
           mov    psi,si
           mov    cx,limitx
bsx:       mov    al,fs:[si]
           inc    si
           mov    ah,al
           mov    bh,gs:[di+1]
           sub    bh,gs:[di-1]
           sub    ah,bh
           mov    bh,gs:[di+320]
           sub    bh,gs:[di-320]
           sub    al,bh
           imul   ah
           sar    ax,6
           stosb
           loop   bsx
           mov    si,psi
           add    si,128
           mov    di,pdi
           add    di,320
           mov    cx,pcx
           loop   bsy
           pop    ds
           ret
movespot endp

code ends

end
