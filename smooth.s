.data
N_COEFFS:	.word 3	;fixed
coeff:		.double 0.5, 1.0, 0.5
N_SAMPLES:	.word 5
sample:		.double 1.0, 2.0, 1.0, 2.0, 1.0 ;# same with result
result:		.double 0.0, 0.0, 0.0, 0.0, 0.0
norm:		.double 0.0
CR: 	.word32 0x10000
DR:    	.word32 0x10008

.text

    daddi    $a1,$0,norm       ;a1 holds the address of norm 
    daddi    $a2,$0,coeff      ;a2 holds the address of coeff

;first loop iteration
    l.d      f2,($a2)        ;f2 =  coeff[0]
    l.d      f1,($a1)        ;f1 =  norm
    ;loop
    c.le.d    f2,f0 			  ;if coeff[i]<=0 FP FLAG=1;
    bc1f      pos             ;
    sub.d     f3,f1,f2       ;t0 = norm - coeff[1]
    j         cont
pos:
    add.d     f3,f1,f2       ;t= norm + coeff[1]
cont:
    s.d       f3,0($a1)

;second value
    ;loop
    l.d      f2,8($a2)     ;f2 =  coeff[1], we put it here for branch stall hazards as this will be loaded eitherway
    l.d      f1,($a1)        ;f1 =  norm
    c.le.d    f2,f0 			  ;if coeff[i]<=0 FP FLAG=1;
    bc1f      pos1             ;
    sub.d     f3,f1,f2       ;t0 = norm - coeff[1]
    j         cont1
pos1:
    add.d     f3,f1,f2       ;t= norm + coeff[1]
cont1:
    s.d       f3,0($a1)

;third value of coeff
    l.d      f2,16($a2)     ;f2 =  coeff[1]
    l.d      f1,($a1)        ;f1 =  norm
    ;loop
    c.le.d    f2,f0 			  ;if coeff[i]<=0 FP FLAG=1;
    bc1f      pos2             ;
    sub.d     f3,f1,f2       ;t0 = norm - coeff[1]
    j         cont2
pos2:
    add.d     f3,f1,f2       ;t= norm + coeff[1]
cont2:
    s.d       f3,0($a1)


		
lwu r11, CR(r0)
lwu r12, DR(r0)
daddi r10,r0,3
s.d f3,(r12)
sd r10,(r11)
halt


;pos:
;
;jal     subprog		    
;# End of main
;jr      $ra
;subprog:
;ld          $a0,		    
;# End of subprogram
; jr         $ra