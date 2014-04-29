{
-ÄÄÄ Aragorn ÄÄ-- / þCONTROL UNiTþ

  blur routines
}
unit blur;
interface

procedure stdblur(ins:word);
procedure drop(src,dst,ddi : word); {19x19}

implementation

procedure stdblur(ins:word); assembler;
asm
                mov     es,ins
                mov     di,321
                mov     cx,320*198
@blurl:         mov     bx,0
                mov     ax,0
                mov     bl,es:[di]
                add     ax,bx
                mov     bl,es:[di+1]
                add     ax,bx
                mov     bl,es:[di-1]
                add     ax,bx
                mov     bl,es:[di+320]
                add     ax,bx
                shr     ax,2
{                jz      @blurz}
{                dec     al}
@blurz:         stosb
                loop    @blurl
end;

procedure drop(src,dst,ddi : word); assembler; {19x19}
asm
        mov     es,dst
        mov     di,ddi
        push    ds
        mov     dx,19
        mov     si,src
        mov     ds,si
        xor     si,si
@ly:    mov     cx,19
@xl:    lodsb
        or      al,al
        jz      @skip
        mov     bx,0
        mov     ax,0
        mov     bl,es:[di-320]
        add     ax,bx
        mov     bl,es:[di-1]
        add     ax,bx
        mov     bl,es:[di+1]
        add     ax,bx
        mov     bl,es:[di+320]
        add     ax,bx
        shr     ax,2
        mov     es:[di],al
@skip:  inc     di
        dec     cx
        jnz     @xl
        add     di,320-19
        dec     dx
        jnz     @ly
        pop     ds
end;

begin
end.
