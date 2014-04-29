; -ÄÄÄ Aragorn ÄÄ-- / þCONTROL UNiTþ
;
; tunnel texturers -- various deformations

        o equ offset
        b equ byte ptr
        w equ word ptr
        d equ dword ptr

.386
jumps

Data Segment Word Use16
  extrn ptab:byte:256
Data EndS

Code Segment DWord Use16

Assume CS: Code, DS: Data

; ---- standard texturer.... you already 've seen it before....
public movetunnel
movetunnel proc pascal far
arg texx:word,texy:word,srcmap1:word,srcmap2:word,srctex:word,dst:word

        mov     es,dst
        mov     fs,srcmap1
        mov     bx,texy
        shl     bx,8
        add     bx,texx
        xor     edi,edi
        push    ds
        mov     ds,srctex

        mov     cx,32000
tlup:
        mov     si,fs:[edi*2]
        mov     al,ds:[bx+si]
        stosb
        dec     cx
        jnz     tlup

        xor     edi,edi
        mov     fs,srcmap2
        mov     cx,32000
tlup1:
        mov     si,fs:[edi*2]
        mov     al,ds:[bx+si]
        mov     es:[di+32000],al
        inc     di
        dec     cx
        jnz     tlup1

        pop     ds
        ret
endp

; ---- Smokey tunnel
public movetunnel2
movetunnel2 proc pascal far
arg texx:word,texy:word,srcmap1:word,srcmap2:word,srctex:word,dst:word

        mov     es,dst
        mov     fs,srcmap1
        mov     bx,texy
        shl     bx,8
        add     bx,texx
        xor     edi,edi
        mov     gs,srctex
        mov     dx,0

        push    bp

        mov     cx,32000
t2lup:
        mov     si,fs:[edi*2]
        mov     bp,di
        and     bp,255
        mov     dl,ds:ptab[bp]
        add     si,dx
        mov     al,gs:[bx+si]
        mov     es:[di],al
        inc     di
        dec     cx
        jnz     t2lup

        pop     bp
        xor     edi,edi
        mov     fs,srcmap2
        push    bp
        mov     cx,32000
t2lup1:
        mov     si,fs:[edi*2]
        mov     bp,di
        and     bp,255
        mov     dl,ds:ptab[bp]
        add     si,dx
        mov     al,gs:[bx+si]
        mov     es:[di+32000],al
        inc     di
        dec     cx
        jnz     t2lup1


        pop     bp

        ret
endp

; ---- water fx
public movetunnel3
movetunnel3 proc pascal far
arg texx:word,texy:word,srcmap1:word,srcmap2:word,srctex:word,dst:word

        mov     es,dst
        mov     fs,srcmap1
        mov     bx,texy
        shl     bx,8
        add     bx,texx
        xor     edi,edi
        mov     gs,srctex
        mov     dx,0

        push    bp

        mov     cx,32000
t3lup:
        mov     si,fs:[edi*2]
        mov     bp,si
        shr     bp,8
        mov     dl,ds:ptab[bp]
        add     si,dx
        mov     al,gs:[bx+si]
        mov     es:[di],al
        inc     di
        dec     cx
        jnz     t3lup

        pop     bp
        xor     edi,edi
        mov     fs,srcmap2
        push    bp
        mov     cx,32000
t3lup1:
        mov     si,fs:[edi*2]
        mov     bp,si
        shr     bp,8
        mov     dl,ds:ptab[bp]
        add     si,dx
        mov     al,gs:[bx+si]
        mov     es:[di+32000],al
        inc     di
        dec     cx
        jnz     t3lup1


        pop     bp

        ret
endp

; ---- water fx displaced
public movetunnel4
movetunnel4 proc pascal far
arg texx:word,texy:word,srcmap1:word,srcmap2:word,srctex:word,dst:word

        mov     es,dst
        mov     fs,srcmap2
        mov     bx,texy
        shl     bx,8
        add     bx,texx
        xor     edi,edi
        mov     gs,srctex
        mov     dx,0
        mov     cs:buf2,fs
        mov     fs,srcmap1
        mov     cs:buf1,fs

        push    bp

        mov     cx,32000
t4lup:
        mov     si,fs:[edi*2]
        mov     fs,cs:buf2
        mov     bp,fs:[edi*2]
        mov     fs,cs:buf1
        shr     bp,8
        mov     dl,ds:ptab[bp]
        add     si,dx
        mov     al,gs:[bx+si]
        mov     es:[di],al
        inc     di
        dec     cx
        jnz     t4lup

        xor     edi,edi
        mov     fs,cs:buf2

        mov     cx,32000
t4lup1:
        mov     si,fs:[edi*2]
        mov     fs,cs:buf1
        mov     bp,fs:[edi*2]
        mov     fs,cs:buf2
        shr     bp,8
        mov     dl,ds:ptab[bp]
        add     si,dx
        mov     al,gs:[bx+si]
        mov     es:[di+32000],al
        inc     di
        dec     cx
        jnz     t4lup1

        pop     bp

        ret

buf1 dw ?
buf2 dw ?
endp

code ends
end

