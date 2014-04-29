{
-ÄÄÄ Aragorn ÄÄ-- / þCONTROL UNiTþ

misc. sprite I/O routines
}
unit sprites;
interface
uses globals;
procedure addsprite(sprite,dest:word;x,y,w,h:word);
implementation
procedure addsprite(sprite,dest:word;x,y,w,h:word); assembler;
asm
        mov     es,dest
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
        mov     si,sprite
        mov     bp,w
        mov     ds,si
        xor     si,si
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
begin
end.