    LIST        P=16F628A, R=HEX
    __FUSES     _XT_OSC & _WDT_OFF & _CP_OFF & _PWRTE_ON
    include     "p16f628a.inc"

lock    EQU     0x0020          ; define lock
pass    EQU     0x0021          ; define password
ctrl    EQU     0x0022          ; define delay variable

        clrf    PORTA           ; clear Port A
        clrf    PORTB           ; clear Port B
        
        bsf     STATUS, RP0     ; select Bank1 for TRISA and TRISB
        
        movlw   B'11110'
        movwf   TRISA           ; set A1-A2-A3-A4 as input, A0 as output
        
        movlw   B'11110000'
        movwf   TRISB           ; set B[0,1,2,3] as output
        
        bcf     STATUS, RP0     ; select Bank0 for PORTA and PORTB
        
        bcf     PORTA, 0        ; turn A0 LED off
        
        movlw   B'0000'
        movwf   PORTB           ; turn B LEDs off

        movlw   B'0100'
        movwf   pass            ; set password
        
        bcf     lock, 0         ; locked (bit0 is clear) - unlocked (bit0 is set)
        
        movlw   D'255'          
        movwf   ctrl            ; set delay variable value    
        
loop                            ; main loop
        btfss   PORTA, 1        ; if RA1 pressed
        goto    cycup           ; goto cycle up loop

        btfss   PORTA, 2        ; if RA2 pressed
        goto    cycdown         ; goto cycle down loop
        
        btfss   PORTA, 3        ; if RA3 pressed
        goto    select          ; goto select loop
        
        btfss   PORTA, 4        ; if RA4 pressed
        goto    assign          ; goto assign loop

delay                           ; start delay
        decfsz  ctrl, F         ; decrease delay variable and check if its 0
        goto    delay           ; if not goto delay
        goto    loop            ; if its 0, go back to main loop
        
cycup                           ; cycle up loop
        btfss   PORTA, 1        ; if RA1 still pressed
        goto    cycup           ; keep monitoring
        incf    PORTB, F        ; if released, increase display
        goto    loop            ; go back to main loop
    
cycdown                         ; cycle down loop
        btfss   PORTA, 2        ; if RA2 still pressed
        goto    cycdown         ; keep monitoring
        decf    PORTB, for      ; if released, decrease display
        goto    loop            ; go back to main loop
        
select                          ; assign loop
        btfss   PORTA, 3        ; if RA3 still pressed
        goto    select          ; keep monitoring
        movf    pass, W         ; if released
        xorwf   PORTB, W
        btfss   STATUS, Z       ; if password == display
        goto    loop            ; go back to main loop
        btfss   lock, 0         ; if released, check if unlocked
        goto    lockOff         ; goto unlocked loop
        goto    lockOn          ; goto locked loop

assign                          ; assign loop
        btfss   PORTA, 4        ; if RA4 still pressed
        goto    assign          ; keep monitoring
        btfss   lock, 0         ; if released, check if unlocked
        goto    loop            ; go back to main loop
        movf    PORTB, W        ; move PORTB to working registry
        movwf   pass            ; set password = display
        goto    loop            ; go back to main loop

lockOff                         ; unlocking loop
        bsf     lock, 0         ; unlocked --> bit0 is set
        bsf     PORTA, 0        ; turn A0 LED on
        goto    loop            ; go back to main loop
        
lockOn                          ; locking loop
        bcf     lock, 0         ; locked --> bit0 is clear
        bcf     PORTA, 0        ; turn A0 LED off
        goto    loop            ; go back to main loop
        
END