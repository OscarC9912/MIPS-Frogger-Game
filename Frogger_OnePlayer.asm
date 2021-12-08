
# =============================== Project Information  ===============================

 # ---------------------- CSC258H5S Fall 2021 Assembly Final Project ----------------------
 
 # University of Toronto, St. George

 # --- Student Info ----
 # Student: Name: Zhonghan CHEN
 # Student Number: 1005770541

 
 # --- Bitmap Display Configuration ---:
 # - Unit width in pixels: 8
 # - Unit height in pixels: 8
 # - Display width in pixels: 256
 # - Display height in pixels: 256
 # - Base Address for Display: 0x10008000 ($gp)
 # --- Bitmap Display Configuration Ends ---:
 
 
 # Which milestone is reached in this submission?
 # ------     Milestone 5 has been reached.
 
 # Which approved additional features have been implemented?
 
 # EASY FEATURE:
 # ---- 1. Display the number of lives remaining
 # ---- 2. Have objects in different rows move at different speeds
 # ---- 3. Add a third row in each of the water and road sections
 # ---- 4. Display a death/respawn animation each time the player loses a frog.
 
 
 # HARD FEATURE:
 # ---- 5. Have some of the floating objects sink and reappear (like arcade version)
 # ---- 6. Add extra random hazards (alligators in the goal areas, spiders on the logs, etc)
 # ---- 7. Two-player mode (two sets of inputs controlling two frogs at the same time)
 
# =============================== Project Information Ends ===============================


.data
	displayAddress: .word 0x10008000
	
	RED: .word 0xff0000 
	GREEN: .word 0x00ff00
	LAKE_BLUE: .word 0x33FFFF
	BLACK: .word 0x000000
	GREY: .word 0x7a7a7a
	YELLOW: .word 0xffff00
	WOOD: .word 0x663300
	WHITE: .word 0xE0E0E0
	PINK: .word 0xFFCCFF
	WATER_BLUE: .word 0x0000CC
	FROG_BLOOD: .word 0xFF3333
	CAR_COLOR: .word 0x6600CC
	Alligator_Color: .word 0x006633
	Spider_Color: .word 0xFFCCE5
	
	LivesRemain: .word 3		# A global info stores the life remaining (mutable)
	
	# X and Y are the top-left coordinate of the 
	frogX:             .word 24
	frogY:		   .word 28
	
	frogX2: .word 64
	frogY2: .word 28
	
	
	
	
	
	carShift: .word 2840
	termination: .word 128
	frog: .word 3608
	
	
	logShape: .word 1028, 1032, 1036, 1040, 1044, 1048,    # LOG1 - 1
		   1156, 1160, 1164, 1168, 1172, 1176,    # LOG1 - 2
		   1284, 1288, 1292, 1296, 1300, 1304,    # LOG1 - 3 
		   1412, 1416, 1420, 1424, 1428, 1432,    # LOG1 - 4
		   
		   1080, 1084, 1088, 1092, 1096, 1100, 1104    # LOG2 - 1
		   1208, 1212, 1216, 1220, 1224, 1228, 1232    # LOG2 - 2
		   1336, 1340, 1344, 1348, 1352, 1356, 1360    # LOG2 - 3
		   1464, 1468, 1472, 1476, 1480, 1484, 1488    # LOG2 - 4
		   
		   1552, 1556, 1560, 1564, 1568, 1572,    # LOG3 - 1
		   1680, 1684, 1688, 1692, 1696, 1700,    # LOG3 - 2
		   1808, 1812, 1816, 1820, 1824, 1828,    # LOG3 - 3
		   1936, 1940, 1944, 1948, 1952, 1956,    # LOG3 - 4
		   
		   
		   1508, 1512, 1516, 1520,
		   
		   
		   1724, 1728, 1732, 1736, 1740  # LOG4 - 2
		   1852, 1856, 1860, 1864, 1868  # LOG4 - 3
		   1980, 1984, 1988, 1992, 1996  # LOG4 - 4
		   
		   1544, 1548,  # Complemets  for LOG3
		   1672, 1676,
		   1800, 1804,
		   1928, 1932,
		  
		   
	log: .space 412
	
	CarShapeRow0: .word 2664, 2668, 2672, 2588, 2592, 2596
	car0: .space 24 
	
	
	CarShapeRow1: .word 3076, 3080, 3084, 3088,     # the first log in ROW1
			3124, 3128, 3132, 3136	# the second log in ROW1    
	car1: .space 32
	
	CarShapeRow2: .word 3464, 3468, 3472
	car2: .space 12
	
	AlligatorShape: .word 528, 536, 660, 672, 784, 792, 796, 800, 924, 932, 936
	Alligator: .space 44
	
	SpiderShape: .word 2856, 2860, 2864, 2732, 2988, 2900, 3024, 3032
	Spider: .space 12
	
	

.text
	lw $t0, displayAddress
	
main: 	 
	jal DRAW_BACKGROUND
	jal DRAW_FROG 
	
	jal CarDrawingRow0
	jal CarDrawingRow1
	jal CarDrawingRow2 
	
	jal LogDrawing
	
	jal DrawSpider
	
	jal refresh
	j frogMovement

refresh:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	
	jal DrawAlligator
	jal DrawSpider
	
	jal LogShift
	
	jal CarShiftRow0
	jal CarShiftRow1
	jal CarShiftRow2
	
	jal DRAW_START_AREA
	jal DRAW_SAFE_ZONE
	jal DRAW_GOAL_AREA
	jal DRAW_INFO_AREA
	
	# === Here we start the part for collision ===
	jal reachGoalArea
	jal carCollision
	jal WaterDropIn
	jal spiderCollision
	
	jal DRAW_FROG
	
	jal displayLifeRemain
	
	jal displayDeathScreen
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4

        jr $ra
        

# =========================================== Draw the Alligator ===========================================        
DrawAlligator: 
        AlligatorDraw:
		lw $t0, displayAddress
		
		lw $t1, Alligator_Color
		la $t2, AlligatorShape
		
		add $t3, $zero, $zero 		# Counter
		add $t4, $zero, $zero		# Position
	
	AlligatorDrawLoop:
		beq $t3, 11, AlligatorDrawEnd
		
		lw $t5, AlligatorShape($t4)
		
		add $t5, $t5, $t0
		
		sw $t1, 0($t5)
		
		addi $t3, $t3, 1
		addi $t4, $t4, 4
		
		j AlligatorDrawLoop
		
	AlligatorDrawEnd:
		# ==== About the update of the paint =====
		li $v0, 32
		li $a0, 800
        	syscall
        	# === Update ends here ====
		jr $ra
# =========================================== Draw the Alligator =========================================== 

    
        
 # =========================================== Draw the Spider ===========================================        
DrawSpider: 
        SpiderDraw:
		
		lw $t1, Spider_Color
		la $t2, SpiderShape
		
		add $t3, $zero, $zero 		# Counter
		add $t4, $zero, $zero		# Position
	
	SpiderDrawLoop:
		lw $t0, displayAddress
		
		beq $t3, 8, SpiderDrawEnd
		
		lw $t5, SpiderShape($t4)
		
		add $t5, $t5, $t0
		
		sw $t1, 0($t5)
		
		addi $t3, $t3, 1
		addi $t4, $t4, 4
		
		j SpiderDrawLoop
		
	SpiderDrawEnd:
		# ==== About the update of the paint =====
		li $v0, 32
		li $a0, 800
        	syscall
        	# === Update ends here ====
		jr $ra
# =========================================== Draw the Spider Ends ===========================================             
                
                    
                                          
        
# =========================================== Reach the goal ===========================================
reachGoalArea:

	lw $t3, PINK
	lw $t0, displayAddress
	
        # == Calculate address for the frog ==
	la $t8, frogX      	# fetch the address of X coordinate of frog
	la $t9, frogY		# fetch the address of Y coordinate of frog

	lw $t6, 0($t8)		# get the X value of the frog
	lw $t7, 0($t9)		# get the Y value of the frog
	
	addi $t5, $zero, 128    # set the unit to multiply
	mult $t7, $t5           # the operation is 128 * Y
	mflo $t5		# like to store the value of 128*Y
	add $t0, $t0, $t5       # the updated address (Y updated)
	add $t0, $t0, $t6
	# == Calculation for address finished ==
	
	lw $t2, 0($t0)
	
	beq $t2, $t3, drawScoredFrog

	jr $ra

drawScoredFrog:
	j SuccessGameDisplay
	
SuccessGameDisplay:
	lw $t2, RED
        sw $t2, 0($t0)
       	j EXITGAME
	 
 # =========================================== Reach the goal ends ===========================================       
        
        
# =========================================== Lives Remianing Here ===========================================
displayLifeRemain:
	lw $t1, LivesRemain
	
	beq $t1, 3, DrawThreeLive
	beq $t1, 2, DrawTwoLive
	beq $t1, 1, DrawOneLive

DrawThreeLive:
	lw $t2, RED
	lw $0, displayAddress
	addi $t0, $t0, 0
	sw $t2, 0($t0)
	
	addi $t0, $t0, -0
	
	sw $t0, displayAddress
	
DrawTwoLive:
	lw $t2, RED
	lw $0, displayAddress
	addi $t0, $t0, 8
	sw $t2, 0($t0)
	
	addi $t0, $t0, -8
	sw $t0, displayAddress
	
DrawOneLive:
	lw $t2, RED
	lw $0, displayAddress
	addi $t0, $t0, 16
	sw $t2, 0($t0)
	
	addi $t0, $t0, -16
	sw $t0, displayAddress
# =========================================== Lives Remianing Ends Here ===========================================
	

        

# =========================================== Car Collision Starts =========================================== 

# The Action when collide with the Car in Red.        
carCollision:
	# << REGISTER USED >>: t0, t1, t8, t9, t6, t7, t5, t1, t2
	
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	# == Loading ===
	lw $t0, displayAddress		# Guarantee the correctness of the base.
	lw $t1, CAR_COLOR 			# Store the determination condition for Car-Collision
	
	# == Calculate address for the frog ==
	la $t8, frogX      	# fetch the address of X coordinate of frog
	la $t9, frogY		# fetch the address of Y coordinate of frog

	lw $t6, 0($t8)		# get the X value of the frog
	lw $t7, 0($t9)		# get the Y value of the frog
	
	addi $t5, $zero, 128    # set the unit to multiply
	mult $t7, $t5           # the operation is 128 * Y
	mflo $t5		# like to store the value of 128*Y
	add $t0, $t0, $t5       # the updated address (Y updated)
	add $t0, $t0, $t6
	# == Calculation for address finished ==
	
	lw $t2, 0($t0)		# Load what color is at this location now
	
	beq $t2, $t1, carCollisionReaction
	
	# jal DRAW_FROG
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
	
	
# Describe how the frog would react when collide with the car
carCollisionReaction:
	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	# ======= change the life first =====
	lw $t3, LivesRemain
	addi $t3, $t3, -1
	sw $t3, LivesRemain
	# ======= change the life finished =====
	
	# ======= Add some animation here =========
	sub $t0, $t0, $t5       # the updated address (Y updated)
	sub $t0, $t0, $t6
	sw $t0, displayAddress
	
	lw $t0, displayAddress
	lw $t1, FROG_BLOOD
	# -------- calculate frog's current position ------------
	lw $t6, frogX
	lw $t7, frogY
	
	addi $t5, $zero, 128    # set the unit to multiply
	mult $t7, $t5           # the operation is 128 * Y
	mflo $t5		# like to store the value of 128*Y
	add $t0, $t0, $t5       # the updated address (Y updated)
	add $t0, $t0, $t6
	# -------- calculate frog's current position ------------
	
	addi $t0, $t0, -128
	sw $t1, 0($t0)
	
	addi $t0, $t0, -4
	sw $t1, 0($t0)
	
	addi $t0, $t0, 8
	sw $t1, 0($t0)
	
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	
	addi $t0, $t0, 128
	sw $t1, 0($t0)
	
	addi $t0, $t0, -4
	sw $t1, 0($t0)
	
	addi $t0, $t0, -4
	sw $t1, 0($t0)
	
	addi $t0, $t0, -4
	sw $t1, 0($t0)
	
	addi $t0, $t0, -128
	sw $t1, 0($t0)
	
	addi $t0, $t0, -128
	sw $t1, 0($t0)
	
	# ==== About the update of the paint =====
	li $v0, 32
	li $a0, 800
        syscall
        # === Update ends here ====
	
	# ======= Add some animation here =========
	

	addi $t3, $zero, 24	# X-coordinate of the frog   and re-initialize the $t3
	addi $t4, $zero, 28	# Y-coordinate of the frog

	sw $t3, frogX
	sw $t4, frogY
	jal DRAW_FROG
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4

	jr $ra
	
# =========================================== Car Collision Ends =========================================== 



# =========================================== Drop In Water Starts =========================================== 

# The Action when collide with the Car in Red.        
WaterDropIn:
	# << REGISTER USED >>: t0, t1, t8, t9, t6, t7, t5 
	
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	# == Loading ===
	lw $t0, displayAddress			# Guarantee the correctness of the base.
	lw $t1, LAKE_BLUE 			# Store the determination condition for Car-Collision
	
	# == Calculate address for the frog ==
	la $t8, frogX      	# fetch the address of X coordinate of frog
	la $t9, frogY		# fetch the address of Y coordinate of frog

	lw $t6, 0($t8)		# get the X value of the frog
	lw $t7, 0($t9)		# get the Y value of the frog
	
	addi $t5, $zero, 128    # set the unit to multiply
	mult $t7, $t5           # the operation is 128 * Y
	mflo $t5		# like to store the value of 128*Y
	add $t0, $t0, $t5       # the updated address (Y updated)
	add $t0, $t0, $t6
	# == Calculation for address finished ==
	
	lw $t2, 0($t0)		# Load what color is at this location now

	beq $t2, $t1, WaterDropInReaction
	
	jal DRAW_FROG
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
	
	
# Describe how the frog would react when collide with the car
WaterDropInReaction:
	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	# ======= change the life first =====
	lw $t3, LivesRemain
	addi $t3, $t3, -1
	sw $t3, LivesRemain
	# ======= change the life finished =====
	
	
	# ======= Add some animation here =========
	sub $t0, $t0, $t5       # the updated address (Y updated)
	sub $t0, $t0, $t6
	sw $t0, displayAddress
	
	lw $t0, displayAddress
	lw $t1, WATER_BLUE
	
	# -------- calculate frog's current position ------------
	lw $t6, frogX
	lw $t7, frogY
	
	addi $t5, $zero, 128    # set the unit to multiply
	mult $t7, $t5           # the operation is 128 * Y
	mflo $t5		# like to store the value of 128*Y
	add $t0, $t0, $t5       # the updated address (Y updated)
	add $t0, $t0, $t6
	# -------- calculate frog's current position ------------
	
	addi $t0, $t0, -128
	sw $t1, 0($t0)
	
	addi $t0, $t0, 132
	sw $t1, 0($t0)
	
	addi $t0, $t0, -8
	sw $t1, 0($t0)
	
	addi $t0, $t0, 132
	sw $t1, 0($t0)
	
	# ==== About the update of the paint =====
	li $v0, 32
	li $a0, 800
        syscall
        # === Update ends here ====

	# ======= Add some animation here =========
	

	addi $t3, $zero, 24	# X-coordinate of the frog
	addi $t4, $zero, 28	# Y-coordinate of the frog

	sw $t3, frogX
	sw $t4, frogY
	jal DRAW_FROG
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4

	jr $ra
	
# =========================================== Drop In Water Ends ===========================================

# =========================================== Car Collision Starts =========================================== 

# The Action when collide with the Car in Red.        
spiderCollision:
	
	addi $sp, $sp, -4
	sw $ra, 0($sp)

	# == Loading ===
	lw $t0, displayAddress		# Guarantee the correctness of the base.
	lw $t1, Spider_Color			# Store the determination condition for Car-Collision
	
	# == Calculate address for the frog ==
	la $t8, frogX      	# fetch the address of X coordinate of frog
	la $t9, frogY		# fetch the address of Y coordinate of frog

	lw $t6, 0($t8)		# get the X value of the frog
	lw $t7, 0($t9)		# get the Y value of the frog
	
	addi $t5, $zero, 128    # set the unit to multiply
	mult $t7, $t5           # the operation is 128 * Y
	mflo $t5		# like to store the value of 128*Y
	add $t0, $t0, $t5       # the updated address (Y updated)
	add $t0, $t0, $t6
	# == Calculation for address finished ==
	
	lw $t2, 0($t0)		# Load what color is at this location now
	
	beq $t2, $t1, spiderCollisionReaction
	
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
	
	
# Describe how the frog would react when collide with the car
spiderCollisionReaction:
	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	# ======= change the life first =====
	lw $t3, LivesRemain
	addi $t3, $t3, -1
	sw $t3, LivesRemain
	# ======= change the life finished =====

	# ==== About the update of the paint =====
	li $v0, 32
	li $a0, 800
        syscall
        # === Update ends here ====
	
	# ======= Add some animation here =========
	

	addi $t3, $zero, 24	# X-coordinate of the frog   and re-initialize the $t3
	addi $t4, $zero, 28	# Y-coordinate of the frog

	sw $t3, frogX
	sw $t4, frogY
	jal DRAW_FROG
	
	jal DrawSpider
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4

	jr $ra
	
# =============================================================================================================

frogMovement:
	
	lw $t5, 0xffff0000
 	beq $t5, 1, KeyboardStroke	#Check for keyboard Input
	j refresh
	
KeyboardStroke: 
	lw $t4, 0xffff0004
	beq $t4, 0x61, key_A
 	beq $t4, 0x77, key_W
 	beq $t4, 0x73, key_S
 	beq $t4, 0x64, key_D

DRAW_BACKGROUND:

	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	jal DRAW_INFO_AREA
	jal DRAW_GOAL_AREA
	jal DRAW_WATER_AREA
	jal DRAW_SAFE_ZONE
	jal DRAW_ROAD_AREA
	jal DRAW_START_AREA
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	
# =====================================================================================	
DRAW_INFO_AREA: 	
	# --- WHITE AREA ---		
	LOAD_BACKGROUD_WHITE:
	
		lw $t0, displayAddress

		addi $t7, $zero, 512     	                # the termination status checker
		add $t8, $zero, $zero				# counter used to check with termination status
		add $t9, $t0, $zero				# the address, which is the same as t0

	DRAW_BACKGROUD_WHITE:
	
		lw $t1, WHITE

		beq $t8, $t7, EXIT0		# termination status checker
		sw $t1, 0($t9)
		addi $t8, $t8, 4
		addi $t9, $t9, 4
		j DRAW_BACKGROUD_WHITE
		
	EXIT0:
		jr $ra	
# =====================================================================================	
	
DRAW_GOAL_AREA: 	
	# --- GREEN AREA ---		
	LOAD_BACKGROUD_PINK:
	
		lw $t0, displayAddress

		addi $t7, $zero, 512     	                # the termination status checker
		add $t8, $zero, $zero				# counter used to check with termination status
		addi $t9, $t0, 512 				# the address, which is the same as t0

	DRAW_BACKGROUD_PINK:
	
		lw $t1, PINK

		beq $t8, $t7, EXIT1		# termination status checker
		sw $t1, 0($t9)
		addi $t8, $t8, 4
		addi $t9, $t9, 4
		j DRAW_BACKGROUD_PINK
	EXIT1:
		jr $ra

        
DRAW_WATER_AREA:
	# --- BLUE AREA ---
	LOAD_BACKGROUD_BLUE: 
		
		lw $t0, displayAddress
		addi $t7, $zero, 1024   			# the termination status
        	add $t8, $zero, $zero				# this is a counter
        	addi $t9, $t0, 1024				# the address, which is the same as t0

	DRAW_BACKGROUD_BLUE: 
		
		lw $t1, LAKE_BLUE

		beq $t8, $t7, EXIT2
		
        	sw $t1, 0($t9)
        	addi $t8, $t8, 4
        	addi $t9, $t9, 4
        	j DRAW_BACKGROUD_BLUE

        EXIT2:
        	jr $ra
        	
        	
DRAW_SAFE_ZONE:
	# --- YELLOW AREA ---
	LOAD_BACKGROUD_YELLOW: 
	
		lw $t0, displayAddress

       		addi $t7, $zero, 512   			        # the termination status
       		add $t8, $zero, $zero				# this is a counter
       		addi $t9, $t0, 2048				# the address, which is the same as t0

	DRAW_BACKGROUD_YELLOW: 
        	lw $t1,YELLOW				        # Yellow Color
        
		beq $t8, $t7, EXIT3
        	sw $t1, 0($t9)
        	addi $t8, $t8, 4
        	addi $t9, $t9, 4
        	j DRAW_BACKGROUD_YELLOW
        
        EXIT3: 
        	jr $ra
        	
        	
DRAW_ROAD_AREA:
	# --- GREY AREA ---
	LOAD_BACKGROUD_GREY: 
		lw $t0, displayAddress

       		addi $t7, $zero, 1024   			        # the termination status
       		add $t8, $zero, $zero				# this is a counter
       		addi $t9, $t0, 2560	
       				# the address, which is the same as t0
 				
	DRAW_BACKGROUD_GREY: 
		
		lw $t1,GREY

		beq $t8, $t7, EXIT4
        	sw $t1, 0($t9)
        	addi $t8, $t8, 4
        	addi $t9, $t9, 4
        	j DRAW_BACKGROUD_GREY
        	
       EXIT4:
       		jr $ra
			
DRAW_START_AREA:
	# --- GREEN AREA ---
	LOAD_BACKGROUD_START: 
		lw $t0, displayAddress
		
       		addi $t7, $zero, 1024   			        # the termination status
       		add $t8, $zero, $zero				# this is a counter
       		addi $t9, $t0, 3584				# the address, which is the same as t0


	DRAW_BACKGROUD_START: 
		lw $t1,GREEN 				
		
		beq $t8, $t7, EXIT5
        	sw $t1, 0($t9)
        	addi $t8, $t8, 4
        	addi $t9, $t9, 4
        	j DRAW_BACKGROUD_START
        
        EXIT5: 
        	jr $ra



# ====================================================================================================================================
     	     	     	
displayDeathScreen:
	lw $t1, LivesRemain
	beq $t1, 0, DRAW_DEATH_SCREEN
	jr $ra	   	     	
     	     	   
# == the entire screen would be black    	     	        	
DRAW_DEATH_SCREEN:

	# --- BLACK AREA ---
	LOAD_DEATH_START: 
		lw $t0, displayAddress
		
       		addi $t7, $zero, 4096   			        # the termination status
       		add $t8, $zero, $zero				# this is a counter
       		addi $t9, $t0, 0				# the address, which is the same as t0

	DRAW_DEATH_START: 
		lw $t1, BLACK 				
		
		beq $t8, $t7, EXIT6
        	sw $t1, 0($t9)
        	addi $t8, $t8, 4
        	addi $t9, $t9, 4
        	j DRAW_DEATH_START
        	
        EXIT6: 
        	j EXITGAME
	
EXITGAME:
	li $v0, 10              # terminate program run and
   	syscall                      # Exit 
               	


# ====================================================================================================================================
# Here we start to draw the Frog
# the frog consists of 12 pixels

DRAW_FROG:

	la $t8, frogX      	# fetch the address of X coordinate of frog
	la $t9, frogY		# fetch the address of Y coordinate of frog

	lw $t6, 0($t8)		# get the X value of the frog
	lw $t7, 0($t9)		# get the Y value of the frog
	# lw $t1, BLACK
	
	# Declare again the address of $t0
	lw $t0, displayAddress
	
	addi $t5, $zero, 128    # set the unit to multiply
	mult $t7, $t5           # the operation is 128 * Y
	mflo $t5		# like to store the value of 128*Y
	add $t0, $t0, $t5       # the updated address (Y updated)
	add $t0, $t0, $t6
	
	lw $t1, BLACK

	sw $t1, 0($t0)  	# DRAW left-leg of the frog
	
	sub $t0, $t0, $t6
	sub $t0, $t0, $t5
	sw  $t0, displayAddress
	
	jr $ra
# ====================================================================



# =================================================================================================
# =================================================================================================
LogDrawing:	
	LogDraw:
		lw $t0, displayAddress
		
		lw $t1, WOOD
		la $t2, logShape
		
		add $t3, $zero, $zero 		# Counter
		add $t4, $zero, $zero		# Position
	
	logDrawLoop:
		beq $t3, 103, logDrawEnd
		
		lw $t5, logShape($t4)
		
		add $t5, $t5, $t0
		
		sw $t1, 0($t5)
		
		addi $t3, $t3, 1
		addi $t4, $t4, 4
		
		j logDrawLoop
		
	logDrawEnd:
		jr $ra
							

LogShift:	

	LogShiftLoad:
		add $t1, $zero, $zero   # Position in the array
		add $t3, $zero, $zero	# Counter
		lw $t5, WOOD
		
	LogShiftLoop:
	
		addi $sp, $sp, -4 
		sw $ra, 0($sp)
		
		lw $t2, termination
		
		beq $t3, 103, EndShift
		
		lw $t4, logShape($t1)

		rem $t2, $t4, $t2
		addi $t4, $t4, -4

		beq $t2, $zero, WrapHandler
		
		
	new_label:
		sw $t4, logShape ($t1)
		
		addi $t2, $zero, 128
		
		sw $t2, termination
		
		addi $t1, $t1, 4
		addi $t3, $t3, 1
		
		lw $ra, 0 ($sp)
		addi $sp, $sp, 4
		
		j LogShiftLoop
		
		
	WrapHandler:
		addi $t4, $t4, 128

		j new_label
		
		
	EndShift:
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		# ==== About the update of the paint =====
		li $v0, 32
		li $a0, 1
        	syscall
        	# === Update ends here ====
        	
		jal DRAW_WATER_AREA
		
		jal LogDrawing
		
		lw $ra, 0($sp)
		addi $sp, $sp, 4
	
		jr $ra 
		
		
# =================================================================================================
# =================================================================================================		

	
		
# =================================================================================================
# =================================================================================================

CarDrawingRow0:	
	carDraw0:
		lw $t0, displayAddress
		
		lw $t1, CAR_COLOR
		la $t2, CarShapeRow0
		
		add $t3, $zero, $zero 		# Counter
		add $t4, $zero, $zero		# Position
	
	carDrawLoop0:
		beq $t3, 6, carDrawEnd0
		
		lw $t5, CarShapeRow0($t4)
		
		add $t5, $t5, $t0
		
		sw $t1, 0($t5)
		
		addi $t3, $t3, 1
		addi $t4, $t4, 4
		
		j carDrawLoop0
		
	carDrawEnd0:
		jr $ra
		
			
		
CarShiftRow0:	
	carShiftLoadRow0:
		add $t1, $zero, $zero   # Position in the array
		add $t3, $zero, $zero	# Counter
		lw $t5, CAR_COLOR
		
	carShiftLoopRow0:
	
		addi $sp, $sp, -4 
		sw $ra, 0($sp)
		
		lw $t2, termination
		
		beq $t3, 6, EndShiftRow0
		
		lw $t4, CarShapeRow0($t1)

		rem $t2, $t4, $t2
		addi $t4, $t4, -4

		beq $t2, $zero, WrapHandlerRow0
		
		
	new_label0:
		sw $t4, CarShapeRow0($t1)
		
		addi $t2, $zero, 128
		
		sw $t2, termination
		
		addi $t1, $t1, 4
		addi $t3, $t3, 1
		
		lw $ra, 0 ($sp)
		addi $sp, $sp, 4
		
		j carShiftLoopRow0
		
		
	WrapHandlerRow0:
		addi $t4, $t4, 128

		j new_label0
		
		
	EndShiftRow0:
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		# ==== About the update of the paint =====
		li $v0, 32
		li $a0, 100
        	syscall
        	# === Update ends here ====
        	
		jal DRAW_ROAD_AREA
		
		jal CarDrawingRow0
		
		lw $ra, 0($sp)
		addi $sp, $sp, 4
	
		jr $ra 
	
# =================================================================================================

CarDrawingRow1:	
	carDraw1:
		lw $t0, displayAddress
		
		lw $t1, CAR_COLOR
		la $t2, CarShapeRow1
		
		add $t3, $zero, $zero 		# Counter
		add $t4, $zero, $zero		# Position
	
	carDrawLoop1:
		beq $t3, 8, carDrawEnd1
		
		lw $t5, CarShapeRow1($t4)
		
		add $t5, $t5, $t0
		
		sw $t1, 0($t5)
		
		addi $t3, $t3, 1
		addi $t4, $t4, 4
		
		j carDrawLoop1
		
	carDrawEnd1:
		jr $ra
		
			
		
CarShiftRow1:	
	carShiftLoadRow1:
		add $t1, $zero, $zero   # Position in the array
		add $t3, $zero, $zero	# Counter
		lw $t5, CAR_COLOR
		
	carShiftLoopRow1:
	
		addi $sp, $sp, -4 
		sw $ra, 0($sp)
		
		lw $t2, termination
		
		beq $t3, 8, EndShiftRow1
		
		lw $t4, CarShapeRow1($t1)

		rem $t2, $t4, $t2
		addi $t4, $t4, -4

		beq $t2, $zero, WrapHandlerRow1
		
		
	new_label11:
		sw $t4, CarShapeRow1($t1)
		
		addi $t2, $zero, 128
		
		sw $t2, termination
		
		addi $t1, $t1, 4
		addi $t3, $t3, 1
		
		lw $ra, 0 ($sp)
		addi $sp, $sp, 4
		
		j carShiftLoopRow1
		
		
	WrapHandlerRow1:
		addi $t4, $t4, 128

		j new_label11
		
		
	EndShiftRow1:
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		# ==== About the update of the paint =====
		#li $v0, 32
		#li $a0, 100
        	#syscall
        	# === Update ends here ====
		
		jal CarDrawingRow1
		
		lw $ra, 0($sp)
		addi $sp, $sp, 4
	
		jr $ra 
		
		
# =================================================================================================
		
CarDrawingRow2:	
	carDraw2:
		lw $t0, displayAddress
		
		lw $t1, CAR_COLOR
		la $t2, CarShapeRow1
		
		add $t3, $zero, $zero 		# Counter
		add $t4, $zero, $zero		# Position
	
	carDrawLoop2:
		beq $t3, 3, carDrawEnd2
		
		lw $t5, CarShapeRow2($t4)
		
		add $t5, $t5, $t0
		
		sw $t1, 0($t5)
		
		addi $t3, $t3, 1
		addi $t4, $t4, 4
		
		j carDrawLoop2
		
	carDrawEnd2:
		jr $ra
		
			
		
CarShiftRow2:	
	carShiftLoadRow2:
		add $t1, $zero, $zero   # Position in the array
		add $t3, $zero, $zero	# Counter
		lw $t5, CAR_COLOR
		
	carShiftLoopRow2:
	
		addi $sp, $sp, -4 
		sw $ra, 0($sp)
		
		lw $t2, termination
		
		beq $t3, 3, EndShiftRow2
		
		lw $t4, CarShapeRow2($t1)

		rem $t2, $t4, $t2
		addi $t4, $t4, -4

		beq $t2, $zero, WrapHandlerRow2
		
		
	new_label2:
		sw $t4, CarShapeRow2($t1)
		
		addi $t2, $zero, 128
		
		sw $t2, termination
		
		addi $t1, $t1, 4
		addi $t3, $t3, 1
		
		lw $ra, 0 ($sp)
		addi $sp, $sp, 4
		
		j carShiftLoopRow2
		
		
	WrapHandlerRow2:
		addi $t4, $t4, 128

		j new_label2
		
		
	EndShiftRow2:
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		# ==== About the update of the paint =====
		li $v0, 32
		li $a0, 90
        	syscall
        	# === Update ends here ====
		
		jal CarDrawingRow2
		
		lw $ra, 0($sp)
		addi $sp, $sp, 4
	
		jr $ra 
			
		


# =================================================================================================
# =================================================================================================



	   
 	
key_A:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	 
	lw $t1, frogX
	addi $t1, $t1, -4
	sw $t1, frogX
	
	jal DRAW_FROG
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	
	j refresh
	
key_W:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	 
	lw $t1, frogX
	addi $t1, $t1, -256
	sw $t1, frogX
	
	jal DRAW_FROG
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	j refresh


key_S:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	 
	lw $t1, frogX
	addi $t1, $t1, 128
	sw $t1, frogX
	
	jal DRAW_FROG
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	j refresh

	
	
key_D:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	lw $t1, frogX
	addi $t1, $t1, 4
	sw $t1, frogX
	
	jal DRAW_FROG
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	j refresh
	
check:

	li $v0, 1
	move $a0, $zero
	syscall




# =================================================================================================

# =================================================================================================

# =




