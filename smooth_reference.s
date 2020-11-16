; Reference Implementation
; Configuration: Add 3, Mul 4, Div 12, Branch Delay Enabled

.data
N_COEFFS:  .word 3

; Basic Correctness
;coeff:     .double 0.5, 1.0, 0.5
;N_SAMPLES: .word 5
;sample:    .double 1.0, 10.0, -5.0, 3.0, -1.0
;result:    .double 0.0, 0.0, 0.0, 0.0, 0.0

; 3ff0
; 4010
; 3fe8
; 0000
; bff0

; Negative Coefficients
;coeff:     .double -0.5, 1.0, 0.5
;N_SAMPLES: .word 5
;sample:    .double 1.0, 10.0, -5.0, 3.0, -1.0
;result:    .double 0.0, 0.0, 0.0, 0.0, 0.0

; 3ff0
; 400c
; c001
; 4004
; bff0

; Few samples
;coeff:     .double 0.5, 1.0, 0.5
;N_SAMPLES: .word 1
;sample:    .double 1.0
;result:    .double 0.0

; 10 Samples (164 cycles)
;coeff:     .double 0.5, 1.0, 0.5
;N_SAMPLES: .word 10
;sample:    .double 0.0, 1.0, 0.0, 1.0, 2.0, 0.0, 1.0, 2.0, 3.0, 0.0
;result:    .double 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0

; 30 Samples (464 cycles)
;coeff:     .double 0.5, 1.0, 0.5
;N_SAMPLES: .word 30
;sample:    .double 0.0, 1.0, 0.0, 1.0, 2.0, 0.0, 1.0, 2.0, 3.0, 0.0
;           .double 1.0, 2.0, 3.0, 4.0, 0.0, 1.0, 2.0, 3.0, 4.0, 5.0
;           .double 0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 0.0, 1.0, 2.0
;result:    .double 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0
;           .double 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0
;           .double 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0

; 50 Samples (764 cycles)
;coeff:     .double 0.5, 1.0, 0.5
;N_SAMPLES: .word 50
;sample:    .double 0.0, 1.0, 0.0, 1.0, 2.0, 0.0, 1.0, 2.0, 3.0, 0.0
;           .double 1.0, 2.0, 3.0, 4.0, 0.0, 1.0, 2.0, 3.0, 4.0, 5.0
;           .double 0.0, 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 0.0, 1.0, 2.0
;           .double 3.0, 4.0, 5.0, 6.0, 7.0, 0.0, 1.0, 2.0, 3.0, 4.0
;           .double 5.0, 6.0, 7.0, 8.0, 0.0, 1.0, 2.0, 3.0, 4.0, 5.0
;result:    .double 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0
;           .double 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0
;           .double 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0
;           .double 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0
;           .double 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0

.text
		ld    $a3, N_SAMPLES($0)
		daddi $a0, $0, sample
		slti  $t1, $a3, 3
		daddi $a1, $0, coeff
		bne   $t1, $0, end
		daddi $a2, $0, result

; Compute norm in f2
		daddi $t3, $0, -1          ; set everything
		dsrl  $t3, $t3, 1          ; but top bit
		ld    $t4, ($a1)
		ld    $t5, 8($a1)
		and   $t4, $t4, $t3
		mtc1  $t4, f0
		and   $t5, $t5, $t3
		mtc1  $t5, f2
		ld    $t4, 16($a1)
		add.d f2, f0, f2
		and   $t4, $t4, $t3
		mtc1  $t4, f0
		add.d f2, f2, f0

		l.d   f4, ($a1)
		l.d   f6, 8($a1)
		l.d   f8, 16($a1)
		
		dsll  $a3, $a3, 3
		daddu $t2, $a0, $a3         ; sample_end
		daddi $t2, $t2, -16         ; sample_end -= 2
		l.d   f10, ($a0)            ; *result = *sample
sample_loop:
		l.d   f12, ($a0)
		l.d   f14, 8($a0)
		mul.d f20, f12, f4          ; sample[0] * coeff[0]
		mul.d f22, f14, f6          ; sample[1] * coeff[1]
		l.d   f16, 16($a0)
		mul.d f24, f16, f8          ; sample[2] * coeff[2]
		add.d f18, f20, f22
		daddi $a0, $a0, 8           ; sample++
		daddi $a2, $a2, 8           ; result++
		add.d f18, f18, f24
		s.d   f10, -8($a2)
		bne   $a0, $t2, sample_loop ; if (sample != sample_end)
		div.d f10, f18, f2
;sample_end:
		ld    $t4, 8($a0)           ; *result = *sample
		sd    $t4, 8($a2)
		s.d   f10, ($a2)

end:
        halt
