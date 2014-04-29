; Timer routines
;
; -ÄÄÄ Aragorn ÄÄ-- / þCONTROL UNiTþ

timerfreq  = 70
timeradj   = 0          ; make the timer a bit faster, 4 compensation
;timerdiv   = (1193181 / timerfreq) + timeradj
timerdiv   = 17045

        o equ offset
        b equ byte ptr
        w equ word ptr
        d equ dword ptr

.386
jumps

Data Segment Word Use16
Data EndS

Code Segment DWord Use16

Assume CS: Code, DS: Data

public ticks,tminit,tmdeinit,tmgettime

        ticks           dd ?
        oldirq0         dd ?

timeirq :
        push    ax
        mov     al,20h          ; re-enable lower-priority ints
	out	20h,al
        inc     d cs:[ticks]
        pop     ax
        iret

tmInit  proc pascal far
        mov     d cs:[ticks],0
        mov     ax,3508h
        int     21h
        mov     w cs:[oldirq0+0],bx
        mov     w cs:[oldirq0+2],es
        push    ds
        push    cs
        pop     ds
        mov     dx,o timeirq
        mov     ax,2508h
        int     21h
        pop     ds
        mov     dx,timerdiv
        cli
        mov     al,036h         ; Let's program the timer to call IRQ0
        out     43h,al
	mov	al,dl
	out	40h,al
	mov	al,dh
	out	40h,al
	sti
        ret
tmInit  endp

tmdeinit proc pascal far
        push    ds
        mov     dx,w cs:[oldirq0+2]
        mov     ds,dx
        mov     dx,w cs:[oldirq0+0]
        mov     ax,2508h
        int     21h
        pop     ds
        xor     dx,dx           ; shut-down irq0
        cli
        mov     al,036h         ; Let's program the timer to call IRQ0
        out     43h,al
	mov	al,dl
	out	40h,al
	mov	al,dh
	out	40h,al
        sti
        ret
tmdeinit endp

tmgettime proc
        mov     dx,w cs:[ticks+2]
        mov     ax,w cs:[ticks+0]
        retf
tmgettime endp

code ends

end
