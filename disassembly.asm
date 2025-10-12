 ; -----------------------------------------------------------------------------------------------
 ; ddpdojblk (DoDonPachi Dai-Ou-Jou Black Label (Japan, 2002.10.07.Black Ver, newer)) Disassembly
 ; ------------------------------------------------------------------------------------------------

;  -- Colour Palettes --
;
; Bullet colour palette for blue bullets and pink bullets
; Applies to gameplay, not boot up screen
;
;            ____________________________________________________________________________________________ Blue & pink bullet palette
;           |      ______________________________________________________________________________________ Blue bullet palette
;           |     |      ________________________________________________________________________________ Blue bullet palette
;           |     |     |      __________________________________________________________________________ Blue bullet palette
;           |     |     |     |      ____________________________________________________________________ Blue bullet palette
;           |     |     |     |     |      ______________________________________________________________ Blue bullet palette
;           |     |     |     |     |     |      ________________________________________________________ Blue bullet palette
;           |     |     |     |     |     |     |      __________________________________________________ Blue bullet palette
;           |     |     |     |     |     |     |     |      ____________________________________________ Blue bullet palette
;           |     |     |     |     |     |     |     |     |      ______________________________________ Blue bullet palette
;           |     |     |     |     |     |     |     |     |     |      ________________________________ Blue bullet palette
;           |     |     |     |     |     |     |     |     |     |     |      __________________________ Pink bullet palette
;           |     |     |     |     |     |     |     |     |     |     |     |      ____________________ Pink bullet palette
;           |     |     |     |     |     |     |     |     |     |     |     |     |      ______________ Pink bullet palette
;           |     |     |     |     |     |     |     |     |     |     |     |     |     |      ________ Pink bullet palette
;           |     |     |     |     |     |     |     |     |     |     |     |     |     |     |      __ Pink bullet palette
;           |     |     |     |     |     |     |     |     |     |     |     |     |     |     |     |
2243F8:   FFFF  EBFF  CFFF  C7BE  B35E  9AFE  827F  81FB  8156  80F3  8890  FF3B  FA97  F952  F4AE  DCA0






; -- Memory Values --
; 2 byte values per address
hyper_slowdown_timer           = $80392e               ; Game slowdown timer when activating hyper
bullet_slowdown_value          = $803932               ; Game slowdown timer during certain bullet patterns
p1_position                    = $8103e8               ; $8103e8 = Y position, $8103ea = X position, often referenced together as a 4 byte value
p1_i_frames_timer              = $810424               ; Invincibility frames timer
p1_ship_type                   = $81043e               ; 0x0000 for Type A, 0x0002 for Type B
current_stage_id               = $813094               ; Increments by 2 per stage, loop 1 and loop 2 stage ID's are identical
loop_flag                      = $813098               ; 0x0000 for loop 1, 0x0001 for loop 2
rank                           = $81309e..$8130bc      ; Dynamic difficulty
p1_lives                       = $8130be
p1_collected_bees_no_miss      = $817f80               ; Number of bees collected in stage without dying
p1_bee_perfect_counter         = $817f82               ; Increments by 4 for every bee perfect stage
p1_current_score               = $81b440
p1_next_score_extend_threshold = $81B4ac               ; Reward extend when matching p1_current_score
score_extend_threshold_index   = $81b4b4               ; Used as an index for a lookup table to calculate next score extend threshold 
combo_gauge_capacity           = $81b5b2               ; 0x0038 for loop 1, 0x005a for loop 2
p1_combo_gauge                 = $81b5c0
p1_combo_gauge_copy            = $81b5ca
p1_hits_counter                = $81b5da               ; Number of hits when during combo
p1_hits_counter_copy           = $81b5dc
p1_combo_gauge_increment_value = $81b5e0
p1_hits_counter_bosses         = $81b610               ; Number of hits when lasering bosses
p1_hyper_mode_flag             = $81b63e               ; 0x0000 = hyper mode inactive, 0x0001 = hyper mode active
p1_hyper_meter_gain_interval   = $81b636               ; Interval frame counter before increasing hyper meter when lasering large enemy / boss
p1_hyper_duration_meter        = $81b642
hyper_rank                     = $81b646
p1_hyper_meter                 = $81b64a
p1_hyper_level                 = $81b654
p1_hyper_mode_flag_copy        = $81b658
p1_hypers_in_stock             = $81b65c
p1_hyper_meter_reserves_count  = $81B6e0               ; Tracks how many hyper meters filled during hyper mode

; -- Trigger Bullet slowdown --
; Trigger slowdown during certain bullet patterns
; Current stage ID is used as the index for our bullet slowdown values table
; A0 stores the base address of our slowdown values table ($23C416)
23C36E: 3439 0081 3094           move.w     (current_stage_id).l, D2		
23C374: 3430 2000 				 move.w 	(A0,D2.w), D2			                        ; Get our max slowdown capacity value for current bullet pattern from table
23C378: B479 0080 3932 			 cmp.w      (bullet_slowdown_value).l, D2	  
23C37E: 6300 0008 				 bls     	$23c388						                    ; Branch if slowdown capacity value <= bullet slowdown value
23C382: 5479 0080 3932 			 addq.w  	#2, (bullet_slowdown_value).l			
23C388: 7002 					 moveq   	#$2, D0
23C38A: 13C0 0080 3940 			 move.b  	D0, $803940.l  
23C390: 4A39 0080 3940 			 tst.b   	$803940.l       
23C396: 66f8					 bne    	$23c390                     
23C398: 4E75 					 rts                   

; Trigger slowdown when activating hyper
2498C4: 33FC 0014 0080 392E      move.w     #$14, (hyper_slowdown_timer).l			  

; Calculate hyper medal relative position when spawning or when obtained by player?
252904: 2239 0081 03E8           move.l     (p1_position).l, D1		
25290A: 303C 000F                move.w     #$f, D0						                    ; D0 will be used as a loop counter
25290E: 41F9 0081 B660           lea        $81b660.l, A0

; The following two instructions will loop until the loop counter in D0 runs out
; This loop fills $81b660..$81b69f with the position data we retrieved from (p1_position)
; This will be called when hyper medal first spawns and when player grabs it
252914: 20C1                     move.l     D1, (A0)+
252916: 51C8 FFFC                dbra       D0, $252914
25291A: 4E75                     rts

2530BE: 4A79 0081 B65C           tst.w      (p1_hypers_in_stock).l			 
2530C4: 6604                     bne        $2530ca	                                        ; If we have at least 1 hyper in stock, skip straight to incrementing hyper stock
2530C6: 6100 F83C                bsr        $252904	                                        ; Branch to hyper medal position calculation function
2530CA: 5279 0081 B65C           addq.w     #1, (p1_hypers_in_stock).l    
2530D0: 33FC 095F 0081 B642      move.w     #$95f, (p1_hyper_duration_meter).l              ; Fill hyper duration meter
2530D8: 6100 03C0                bsr        $25349a
2530DC: 4EF9 0028 6ED6           jmp        $286ed6.l
2530E2: 4E71                     nop
2530E4: 4E75                     rts

; -- Apply Stage 4 Extend --
; Increment player lives when grabbing stage 4 extend
25310E: 0C79 0014 0081 30BE      cmpi.w     #$14, (p1_lives).l
253116: 670C					 beq        $253124                                         ; Skip lives increment if we have 20 lives
253118: 5279 0081 30BE           add.w      #$1, (p1_lives).l
25311E: 4EB9 0028 78CC			 jsr		$2878CC
253124: 4E75					 rts

; -- Give Hyper Invincibility Frames --
; Give player invincibility frames on hyper activation
; We get more I-frames during a boss fight
25325E: 103C 0050                move.b     #$50, D0                                        ; Give player 0x50 (80) I-frames, store in D0
253262: 0839 0002 0081 30F8      btst       #$8130f8.l                                      ; Check if we're in a boss fight
25326A: 6704                     beq        $253270	                                        ; If not, skip next instruction
25326C: 103C 0078                move.b     #$78, D0                                        ; If in a boss fight, give player 0x78 (120) I-frames, store in D0
253270: 13C0 0081 0424           move.b     D0, (p1_i_frames_timer)                         ; Set I-frames
253276: 4E75                     rts

; If an item is about to appear on screen (hyper medal, power-up, bomb?)
27E9DE: 703C                     moveq      #$3c, D0
27E9E0: C041                     and.w      D1, D0
27E9E2: 41FA 0014                lea        ($14,PC) $27e9f8, A0
27E9E6: 4E71                     nop
27E9E8: D0C0                     adda.w     D0, A0
27E9EA: 2050                     movea.l    (A0), A0
27E9EC: 4E90                     jsr        (A0)                                            ; Branch to $27EF50

27EF50: 0801 000D                btst       #$d, D1
27EF54: 6600 0022                bne        $27ef78
27EF58: 08D6 0005                bset       #$5, (A6)
27EF5C: 6100 0118                bsr        $27f076
27EF60: 4A6E 000E                tst        (#$e,A6)
27EF64: 6A06                     bpl        $27ef6c
27EF66: 3D7C 1400 0004           move.w     #$1400, ($4,A6)

27EF78: 4A79 0081 DF22           tst.w      $81df22.l 
27EF7E: 6600 0370                bne        $27f2f0                                         ; If $81df22 != zero, branch
27EF82: 4A79 0081 B63E           tst.w      (p1_hyper_mode_flag).l
27EF88: 6712                     beq        $27ef9c                                         ; Branch if not in hyper mode
27EF8A: 2F07                     move.l     D7, -(SP)
27EF8C: 701C                     moveq      #$1c, D0
27EF8E: 7405                     moveq      #$5, D2
27EF90: 4EB9 0027 F8EE           jsr        $27f8ee
27EF96: 2E1F                     move.l     (SP)+, D7
27EF98: 6000 0356                bra.w      $27f2f0
27EF9C: 3039 0081 B65C           move.w     (p1_hypers_in_stock).l, D0   
27EFA2: 0C40 0005                cmpi.w     #$5, D0                       
27EFA6: 67E2                     beq        $27ef8a                                         ; Branch if we have 5 hypers in stock
27EFA8: 383C 0005                move.w     #$5, D4
27EFAC: 0C40 0004                cmpi.w     #$4, D0	
27EFB0: 660C                     bne        $27efbe                                         ; Branch if we don't have 4 hypers in stock
27EFB2: 4A79 0080 390C           tst.w      $80390c.l
27EFB8: 6604                     bne        $27efbe
27EFBA: 383C 0005                move.w     #$5, D4

27EFBE: 243C 001B 8B28           move.l     #$1b8b28, D2
27EFC4: 2A3C F900 FA00           move.l     #-$6ff0600, D5
27EFCA: 0801 000C                btst       #$c, D1
27EFCE: 6700 001C                beq        $27efec                                         ; Branch if hyper medal is still on screen
27EFD2: 4EB9 0025 30BE           jsr        $2530be                                         ; Branch if we have grabbed the hyper medal
27EFD8: 6500 05A8                bcs        $27f582
27EFDC: 4EB9 0028 C65E           jsr        $28c65e
27EFE2: 41FA 041C                lea        ($41,PC), A0
27EFE6: 4E71                     nop
27EFE8: 6000 0562                bra        $27f54c

; -- Update Hyper Medals Position --
; Move medal downwards
27F092: 4A79 0081 30D2			 tst.w      $8130d2.l
27F098: 6600 005C				 bne		$27f0f6
27F09C: 122E 0019				 move.b     ($19,A6), D1
27F0A0: 6718					 beq		$27f0ba
27F0A2: 046E 0040 0002           subi.w     #$40, ($2,A6)				                    ; Subtract 0x40 from hyper medal's Y position (move hyper medal downwards)
27F0A8: 4A01					 tst.b      D1
27F0AA: 6B20					 bmi		$27f0cc
27F0AC: 0C6E 0800 0002			 cmpi.w		#$800, ($2,A6)
27F0B2: 6418					 bcc		$27f0cc
27F0B4: 422E 0019				 clr.b		($19,A6)
27F0B8: 6012					 bra		$27f0cc

; Move hyper medal upwards
27F0BA: 066E 0018 0002           addi.w     #$18, ($2,A6)				                    ; Add 0x18 to hyper medal's Y position (move hyper medal upwards)
27F0C0: 302E 0002				 move.w     ($2,A6), D0
27F0C4: 0640 8800				 addi.w     #-$7800, D0
27F0C8: 6500 0226				 bcs		$27f2f0
27F0CC: 532E 001F				 subq.b     ($1f,A6)
27F0D0: 6616					 bne		$27F0E8
27F0D2: 7000					 moveq		#0, D0
27F0D4: 102E 001E				 move.b 	($1e,A6), D0
27F0D8: 41FA 0020	 			 lea 		($20,PC) ($27f0fa), A0
27F0DC: 4E71					 nop
27F0DE: D0C0					 adda.w		D0, A0

; When grabbing a bee
27FBA2: 4A79 0081 B63E           tst.w      (p1_hyper_mode_flag).l                          ; Check if we're in hyper mode when grabbing a bee
27FBA8: 6600 0044				 bne        $27fbee                                         ; If we are in hyper, skip past calculation function (don't reward hyper meter for bees)

; Increment player lives by 1 when reaching a score extend
28434A: 0C53 0014                cmpi.w     #$14,(A3)                                       ; Check if we have 20 lives
28434E: 671E                     beq.b      $28436e                                         ; If we have 20 lives, skip ahead
284350: 5253                     addq.w     #1, (A3)                                        ; Lives += 1

; Decrement combo gauge when not attacking enemy
284614: 3C39 0081 B5C0           move.w     (p1_combo_gauge).l, D6
28461A: 6740                     beq        $28465c
28461C: 4A79 0081 B63E           tst.w      (p1_hyper_mode_flag).l	
284622: 6712                     beq        $284636                                         ; Skip ahead if not in hyper mode
284624: 5339 0081 B64E           subq.b     #1, $81b64e.l
28462A: 6422                     bcc        $28464e
28462C: 13F9 0081 B64F 0081 B64E move.b     $81b64f.l, $81b64e.l
284636: 5379 0081 B5C0           subq.w     #1, (p1_combo_gauge).l
28463C: 6610                     bne        $28464e                                         ; If combo gauge != zero, branch
28463E: 7000                     moveq      #$0, D0
284640: 23C0 0081 B5B8           move.l     D0, $81b5b8.l
284646: 23C0 0081 B5CE           move.l     D0, $81b5ce.l
28464C: 600E                     bra        $28465c

285A12: 4A79 0081 B63E           tst.w      (p1_hyper_mode_flag).l
285A18: 6600 007C                bne        $285a96                                         ; If in hyper mode, branch
285A1C: 4A79 0081 B658           tst.w      (p1_hyper_mode_flag_copy)
285A22: 67E6                     beq        $285a0a								            ; If not in hyper mode, branch
285A24: 7011                     moveq      #$11, D0
285A26: C039 0081 03E6           and.b      ($8103e6).l, D0                                 ; $8103e6 is player actions bitflag?
285A2C: 6600 0104                bne        $285b32
285A30: 33FC 0001 0081 B63E      move.w     #$1, (p1_hyper_mode_flag).l                     ; Set hyper mode flag
285A38: 4EB9 0028 7324           jsr        $287324
285A3E: 4EB9 0028 6ED6           jsr        $286ed6
285A44: 4A79 0081 B5C0           tst.w      (p1_combo_gauge).l
285A4A: 670A                     beq        $285a56                                         ; Skip next instruction if combo gauge is empty
285A4C: 33F9 0081 B5B2 0081 B5C0 move.w     (combo_gauge_capacity).l, (p1_combo_gauge).l    ; Else, fill combo gauge when activating hyper during combo

; -- Increase hyper rank --
285A56: 3039 0081 B65C           move.w     (p1_hypers_in_stock).l, D0	
285A5C: 33C0 0081 B654           move.w     D0, (p1_hyper_level).l
285A62: D179 0081 B646           add.w      D0, (hyper_rank).l
285A68: 0C79 0023 0081 B646      cmpi.w     #$23, (hyper_rank).l
285A70: 6308                     bls        $285a7a						                    ; Skip next instruction if hyper rank <= 0x23
285A72: 33FC 0023 0081 B646      move.w     #$23, (hyper_rank).l				            ; Prevent hyper rank from going over 0x23

; Determine what the chain timer is when shooting an enemy
; Chain timer is based on the maximum capacity of the combo gauge
; When the capacity is higher, the meter takes longer to drain once it fills up
; Loop 1 : A0 = 287DF0, D2 = 0000 (Combo gauge capacity = 0x38)
; Loop 2 : A0 = 287DF0, D2 = 0002 (Combo gauge capacity = 0x5A)
28615E: 3439 0081 3098           move.w     (loop_flag).l, D2
286164: D442                     add.w      D2, D2                                          ; D2 = D2 * 2 (used as table index)
286166: 41F9 0028 7DF0           lea        $287df0.l, A0                                   ; Load chain timer table base address into A0
28616C: 33F0 2000 0081 B5B2      move.w     (A0,D2.w), (combo_gauge_capacity).l	            ; Set our combo gauge cap based on what loop we're on
286174: 0801 0004                btst       #$4, D1
286178: 6700 00A2                beq        $28621c
28617C: 6100 0148                bsr        $2862c6
286180: 4A79 0081 B63E           tst.w      (p1_hyper_mode_flag).l
286186: 6700 0094                beq        $28621c	                                        ; If not in hyper mode, branch to $28621c
28618A: 3439 0081 B654           move.w     (p1_hyper_level).l, D2	
286190: 5342                     subq.w     #1, D2	
286192: 4AB9 0081 B5B8           tst.l      $81b5b8.l
286198: 6722                     beq        $2861bc
28619A: 2039 0081 B5B8           move.l     $81b5b8.l, D0
2861A0: 23C0 0081 B5CE           move.l     D0, $81b5ce.l
2861A6: 23C0 0081 B5D2           move.l     D0, $81b5d2.l
2861AC: 33FC 0001 0081 B5DA      move.w     #$1, (p1_hits_counter).l 

; Retrieve combo gauge increment value from table
; The value depends on ship type 
; If type A: increment value is 0x14
; If type B: increment value is 0x12 
2862C6: 2600                     move.l     D0, D3
2862C8: 3439 0081 043E           move.w     (p1_ship_type).l, D2
2862CE: 41F9 0028 7DF4           lea        $287df4.l, A0                                   ; Load base address of table into A0
2862D4: 33F0 2000 0081 B5E0      move.w     (A0,D2.w), (p1_combo_gauge_increment_value).l

2863CC: 2003                     move.l     D3, D0
2863CE: 41F9 0081 B5D2           lea        $81b5d2.l, A0
2863D4: 6100 0250                bsr        $286626
2863D8: 2039 0081 B5CE           move.l     $81b5ce.l, D0
2863DE: 41F9 0081 B5D6           lea        $81b5d6.l, A0
2863E4: 6100 0240                bsr        $286626
2863E8: 6100 0250                bsr        $28663a
2863EC: 2039 0081 B5CE           move.l     $81b5ce.l, D0
2863F2: 41F9 0081 B4C4           lea        $81b4c4.l, A0
2863F8: 6100 022C                bsr        $286626
2863FC: 2003                     move.l     D3, D0
2863FE: 0C79 0010 0081 B5DA      cmpi.w     #$10, (p1_hits_counter).l 
286406: 642E                     bcc        $286436	                                        ; If hits >= 0x10, branch
286408: 0C79 0001 0081 B5DA      cmpi.w     #$1, (p1_hits_counter).l 
286410: 6308                     bls        $28641a	                                        ; If hits <=0x1, skip next instruction
286412: 33FC 0078 0081 B5C4      move.w     #$78, $81b5c4.l
28641A: 33F9 0081 B5C0 0081 B5C6 move.w     (p1_combo_gauge).l, $81b5c6.l
286424: 4AB9 0081 B5D6           tst.l      $81b5d6.l
28642A: 6646                     bne        $286472
28642C: 33FC 00B4 0081 B5C2      move.w     #$b4, $81b5c2.l
286434: 603C                     bra        $286472
286436: 660C                     bne        $286444
286438: 4279 0081 B5CC           clr.w      $81b5cc.l
28643E: 4279 0081 B5C4           clr.w      $81b5c4.l
286444: 33FC 00F0 0081 B5C8      move.w     #$f0, $81b5c8.l
28644C: 33F9 0081 B5C0 0081 B5CA move.w     (p1_combo_gauge).l, $81b5ca.l
286456: 33FC 00F0 0081 B5C2      move.w     #$f0, $81b5c2.l
28645E: 33F9 0081 B5DA 0081 B5DC move.w     (p1_hits_counter).l, (p1_hits_counter_copy).l	

; -- Increment combo gauge and hyper meter when shooting and killing enemies --
; This function will handle the combo gauge first, then the hyper guage
28663A: 3039 0081 B5E0           move.w     (p1_combo_gauge_increment_value).l, D0				 
286640: 0801 0002                btst       #$2, D1
286644: 6608                     bne        $28664e
286646: 4A79 0081 3098           tst.w      (loop_flag).l
28664C: 6616                     bne        $286664
28664E: D179 0081 B5C0           add.w      D0, (p1_combo_gauge).l				  
286654: 3039 0081 B5B2           move.w     (combo_gauge_capacity).l, D0	 				; D0 = 0x38 if loop 1, D0 = 0x5A if loop 2
28665A: B079 0081 B5C0           cmp.w      (p1_combo_gauge).l, D0				  
286660: 6302                     bls        $286664						      				; Skip next instruction if combo gauge capacity <= current combo gauge value
286662: 4E75                     rts
286664: 33F9 0081 B5B2 0081 B5C0 move.w     (combo_gauge_capacity).l, (p1_combo_gauge).l    ; Prevent combo gauge from going over max capacity
28666E: 4A41                     tst.w      D1
286670: 6B00 FFF0                bmi        $286662
286674: 3039 0081 3094           move.w     (current_stage_id).l, D0		
28667A: 41FA 0846                lea        ($846,PC) ; ($286ec2), A0
28667E: 4E71                     nop
286680: D0C0                     adda.w     D0, A0
286682: 3010                     move.w     (A0), D0
286684: 3439 0081 B65C           move.w     (p1_hypers_in_stock).l, D2 
28668A: 4A79 0081 B63E           tst.w      (p1_hyper_mode_flag).l 
286690: 6714                     beq        $2866a6	                                        ; If not in hyper mode, skip ahead
286692: 3039 0081 3094           move.w     (current_stage_id).l, D0	
286698: 41FA 0832                lea        ($832,PC) ; ($286ecc), A0	                    ; A0 = base address of table
28669C: 4E71                     nop
28669E: D0C0                     adda.w     D0, A0	                                        ; A0 = base address + stage ID offset
2866A0: 3010                     move.w     (A0), D0    
2866A2: 6000 000E                bra        $2866b2	  
2866A6: D442                     add.w      D2, D2
2866A8: 41FA 0028                lea        ($28,PC) ; ($2866d2), A0
2866AC: 4E71                     nop
2866AE: D070 2000                add.w      (A0,D2.w), D0
2866B2: 0C79 0005 0081 B65C      cmpi.w     #$5, (p1_hypers_in_stock).l	 
2866BA: 6708                     beq        $2866c4	                                        ; If 5 hypers in stock, skip ahead
2866BC: 0801 0002                btst       #$2, D1
2866C0: 6602                     bne        $2866c4	                                        ; Skip next instruction if bit 2 of D1 is set
2866C2: D040                     add.w      D0, D0                                          ; D0 = 8 (4 + 4) if not in hyper mode. D0 = 2 (1 + 1) if in hyper mode
2866CA: 4EF9 0028 7682           jmp        $287682.l
2866D0: 4E71                     nop
2866D2: 0000 FFFF                ori.b      #$ff, D0
2866D6: 0000 0001                ori.b      #$1, D0
2866DA: 0002 0003                ori.b      #$3, D2
2866DE: 3039 0081 B5E0           move.w     (p1_combo_gauge_increment_value).l, D0
2866E4: 0801 0002                btst       #$2, D1
2866E8: 6608                     bne        $2866f2
2866EA: 4A79 0081 3098           tst.w      (loop_flag).l
2866F0: 6616                     bne        $286708
2866F2: D179 0081 B5EA           add.w      D0, $81b5ea.l
2866F8: 3039 0081 B5B2           move.w     (combo_gauge_capacity).l, D0
2866FE: B079 0081 B5EA           cmp.w      $81b5ea.l, D0
286704: 6302                     bls        $286708
286706: 4E75                     rts
286708: 33F9 0081 B5B2 0081 B5EA move.w     (combo_gauge_capacity).l, $81b5ea.l
286712: 4A41                     tst.w      D1
286714: 6B00 FFF0                bmi        $286706
286718: 3039 0081 3094           move.w     (current_stage_id).l, D0
28671E: 41FA 07A2                lea        ($7a2,PC) ; ($286ec2), A0
286722: 4E71                     nop
286724: D0C0                     adda.w     D0, A0
286726: 3010                     move.w     (A0), D0
286728: 3439 0081 B65E           move.w     $81b65e.l, D2
28672E: 4A79 0081 B640           tst.w      $81b640.l
286734: 6714                     beq        $28674a
286736: 3039 0081 3094           move.w     (current_stage_id).l, D0
28673C: 41FA 078E                lea        ($78e,PC) ; ($286ecc), A0
286740: 4E71                     nop
286742: D0C0                     adda.w     D0, A0
286744: 3010                     move.w     (A0), D0
286746: 6000 000C                bra        $286754
28674A: D442                     add.w      D2, D2
28674C: 41FA FF84                lea        (-$7c,PC) ; ($2866d2), A0
286750: D070 2000                add.w      (A0,D2.w), D0
286754: 0C79 0005 0081 B65E      cmpi.w     #$5, $81b65e.l
28675C: 6708                     beq        $286766
28675E: 0801 0002                btst       #$2, D1
286762: 6602                     bne        $286766
286764: D040                     add.w      D0, D0
286766: D179 0081 B64C           add.w      D0, $81b64c.l
28676C: 4EF9 0028 7722           jmp        $287722.l
286772: 4E71                     nop

; -- Increase Hyper Meter When lasering large Enemy --
; Hyper meter increments by 0x18 (per frame?) whie lasering large enemy or hitting them with aura
; The code to gain extra hyper meter while in hyper mode, and the code to get less hyper meter when having 5 hypers in stock never seem to get called
; Hyper meter will only increment when the subtraction at 286774 underflows
286774: 5379 0081 B636           subq.w     #$1, (p1_hyper_meter_gain_interval).l 
28677A: 6436                     bcc        $2867b2                                         ; If hyper meter gain interval >= 0, branch to rts
28677C: 7400                     moveq      #$0, D2
28677E: 0642 0018                addi.w     #$18, D2
286782: 0C79 0005 0081 B65C      cmpi.w     #$5, (p1_hypers_in_stock).l	                    ; Check if 5 hypers in stock. Seems useless since it branches either way
28678A: 6712                     beq        $28679e						                    ; If 5 hypers in stock, skip next four instructions
28678C: 6010                     bra        $28679e						                    ; Skip past next four instructions anyway
28678E: 0642 FFFC                addi.w     #-$4, D2					                    ; D2 -= 4
286792: 4A79 0081 B63E           tst.w      (p1_hyper_mode_flag).l
286798: 6704                     beq        $28679e						                    ; If not in hyper mode, skip next instruction
28679A: 0642 0004                addi.w     #$4, D2						                    ; D2 += 4
28679E: D579 0081 B64A           add.w      D2, (p1_hyper_meter).l
2867A4: 4EB9 0028 7682           jsr        $287682.l
2867AA: 7408					 moveq		#$8, D2
2867AC: 33C2 0081 B636			 move.w		D2, (p1_hyper_meter_gain_interval) 
2867B2: 4E75					 rts

; -- Increase Hyper Meter When Lasering Bosses --
; Increase hyper meter while attacking boss with laser or aura
; This includes the gears during the 2nd phase of stage 4 boss
; Hyper meter will only increment when the subtraction at 2867B4 underflows
2867B4: 5379 0081 B636			 subq.w		#$1, (p1_hyper_meter_gain_interval).l 
2867BA: 64F6					 bcc		$2867b2	                                        ; If hyper meter gain interval >= 0, branch to rts
2867BC: 7404					 moveq		#$4, D2	                                        ; D2 = 4
2867BE: 4A79 0081 B63E			 tst.w      (p1_hyper_mode_flag).l 
2867C4: 6702					 beq		$2867c8	                                        ; If not in hyper mode, skip next instruction
2867C6: 7430					 moveq		#$30, D2                                        ; If in hyper mode, D2 = 0x30
2867C8: D579 0081 B64A			 add.w 		D2, (p1_hyper_meter)
2867CE: 4EB9 0028 7682			 jsr		$287682 
2867D4: 7408					 moveq		#$8, D2
2867D6: 33C2 0081 B636			 move.w		D2, (p1_hyper_meter_gain_interval)
2867DC: 4E75					 rts

; While lasering large enemy, keep combo gauge held at certain value
; When not in hyper, don't let combo gauge fall below 0xA
; When in hyper, don't let combo gauge fall below 0x19
2869D8: 4A79 0081 B63E			 tst.w		(p1_hyper_mode_flag).l
2869DE: 6614					 bne		$2869f4						                    ; Branch if in hyper mode
2869E0: 0C79 000A 0081 B5C0      cmpi.w     #$a, (p1_combo_gauge).l  
2869E8: 641C                     bcc        $286a06                                         ; Skip ahead if combo gauge >= 0xA
2869EA: 33FC 000A 0081 B5C0      move.w     #$a, (p1_combo_gauge).l                         ; Combo gauge = 0xA, keep it at this value while lasering large enemy when not in hyper mode
2869F2: 6012                     bra        $286a06                                     
2869F4: 0C79 0019 0081 B5C0      cmpi.w     #$19, (p1_combo_gauge).l                             
2869FC: 6408                     bcc        $286a06                                         ; Skip next instruction if combo gauge >= 0x19
2869FE: 33FC 0019 0081 B5C0      move.w     #$19, (p1_combo_gauge).l                        ; Combo gauge = 0x19, keep it at this value while lasering large enemy during hyper mode
286A06: 0C79 0010 0081 B5DA      cmpi.w     #$10, (p1_hits_counter).l                             
286A0E: 642E                     bcc        $286a3e  					                    ; Branch if hits counter >= 0x10
286A10: 0C79 0001 0081 B5DA      cmpi.w     #$1, (p1_hits_counter).l         
286A18: 6308                     bls        $286a22                                         ; Skip next instruction if hits counter <= 1
286A1A: 33FC 0078 0081 B5C4      move.w     #$78, $81b5c4.l                                 ; Set hits counter display flag to 0x78
286A22: 33F9 0081 B5C0 0081 B5C6 move.w     (p1_combo_gauge).l, $81b5c6.l                        
286A2C: 4AB9 0081 B5D6           tst.l      $81b5d6.l                                   
286A32: 6608                     bne        $286a3c                                     
286A34: 33FC 00B4 0081 B5C2      move.w     #$b4, $81b5c2.l                             
286A3C: 4E75                     rts                                                 
286A3E: 4A79 0081 B5CA           tst.w      (p1_combo_gauge_copy).l                                   
286A44: 660C                     bne        $286a52                                     
286A46: 4279 0081 B5CC           clr.w      $81b5cc.l                                   
286A4C: 4279 0081 B5C4           clr.w      $81b5c4.l                                   
286A52: 33FC 00F0 0081 B5C8      move.w     #$f0, $81b5c8.l                             

; Increase hyper meter on death
; If increase leads to hyper meter being filled, subtract 1 to prevent hyper medal from dropping
287B9A: 0679 0258 0081 B64A      addi.w     #$258, (p1_hyper_meter).l
287BA2: 0C79 095F 0081 B64A      cmp.w      #$95f, (p1_hyper_meter).l			  
287BAA: 6508                     bcs        $287bb4	                                        ; If hyper meter is not full, skip next instruction
287BAC: 33FC 095E 0081 B64A      move.w     #$95e, (p1_hyper_meter).l			            ; If hyper meter full after death deduct 1 from it

287BB4: 4E75                     rts
