@ read integers from a file and insert them into a max-heap to get sorted
@ and print the sorted integers to the screen (stdout).

.align 4
.text
main:
	@ open an input file to read integers
	ldr r0, =InFileName
	mov r1, #0
	swi 0x66		@ open file
	ldr r1, =InFileHandle
	str r0, [r1, #0]

	@ Read the first integer from the file
	ldr r1, =InFileHandle
	ldr r0, [r1]
	swi 0x6c	@ read an integer put in r0

	@ To-Do 1: Here you should creat a base node (ROOT NODE) containing the just-read integer for your MaxHeap
	@ and save the base node address to the label MyHeap (which is declared in .data) for later references	
	mov R2, R0			@ store int read into r2
	mov R0, #12			@ allocate 12 bytes
	swi 0x12 			@ allocating space and set r0 to base addr
	ldr r12, =MyHeap
	@ str r0, [r12, #0] @ Store root node address into heap 
	str r2, [r12, #0]	@ saving integer into node
	mov r3, #0
	str r3, [r12, #4]	@ set left child null
	str r3, [r12, #8]	@ set right child null
	
	@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

    Loop:
	@ read integer from file
	ldr r1, =InFileHandle
	ldr r0, [r1]
	swi 0x6c	@ read an integer put in r0
	BCS CloseF	@ branch when the end of the file is reached

	@ TO-DO 2: You should comment out the above code for printing
	@ Instead, you creat a new node and save the integer into the first 4 bytes of the node
	@ Put the base node address in r0, and the address of the to-be-inserted node in r1
	@ call the subroutine Insert to insert the newly created node into the MaxHeap
	
	mov R2, R0			@ store int read into r2
	mov R0, #12			@ allocate 12 bytes
	swi 0x12 			@ allocating space and set r0 to base addr
	mov R1, R0			@ move address in R0 into R1
	ldr r0, =MyHeap     @ Load root node address from heap into R0
	mov r3, #0
	str r2, [r1, #0]	@ saving integer into node
	str r3, [r1, #4]	@ set left child null
	str r3, [r1, #8]	@ set right child null

	

    BL Insert		@ call insert function
	
	B Loop			@ go back to read next integer

     CloseF:
	@close infile
	ldr r0, =InFileHandle
	ldr r0, [r0]
	swi 0x68

	ldr r0, =MyHeap		@ r0 is a pointer to the pointer to the heap
	BL PrintHeapSorted  
	
exit:	SWI 0x11		@ Stop program execution 

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

@ TO-DO 3: write the Insert function below
@ The function takes two arguments: a pointer to the heap (in r0) and a pointer to a new node to be inserted to the heap (in r1) 
@ The function returns (in r0) a pointer to the root node (potentially can be the new node) of the heap
Insert:
	ldr r2, [r0, #0]	@ get integer of base
	ldr r3, [r1, #0]	@ get integer of insert
	ldr r4, [r0, #4]	@ get left child of parent
	ldr r5, [r0, #8]	@ get right child of parent
	cmp r3, r2			@ compare node integers
	ble lessThan
	b greaterThan

@ called when insert`s integer is less than the base node
lessThan:
	cmp r4, #0			@ check if base left child is null
	streq r1, [r0, #4]
	ldreq r0, =MyHeap
	moveq pc, r14
	
	cmp r5, #0			@ check if base right child is null
	streq r1, [r0, #8]
	ldreq r0, =MyHeap
	moveq pc, r14
	
	ldr r6, [r4, #0]	@ if both children not NULL, load left child integer
	ldr r7, [r5, #0]	@ load right child integer
	cmp r2, r6			@ compare insert and left integers
	movlt r0, r4
	blt Insert			@ recursive call with left child as base
	cmp r2, r7
	movlt r0, r5		@ compare insert and right integers
	blt Insert			@ recursive call with right child as base
	
	str r1, [r0, #4]	@ if neither child integers are bigger than insert, replace left child with insert
	str r4, [r1, #8]	@ the old left child is now the insert's right child
	mov pc, r14
	
@ called when insert`s integer is larger than the root
greaterThan:
	ldr r12, =MyHeap 	@ Loading MyHeap address into temp variable to be able to store r1 into the address
	str r1, [r12, #0]		@ Storing r1 into r11(MyHeap address)
	str r0, [r1, #4] 	@ Storing r0 in  r1`s left child
	mov pc, r14 		@ moving line 59 into the next line to execute
	
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

@ TO_DO 4: write deleteMax function below
@ call-by-reference: the function takes a pointer-to-pointer as argument (in r0)
@ when the heap contains only one node (i.e., the root node), 
@ deleteMax should return root.data (to r0) and nullify the pointer to the root node

deleteMax:

	@@@@@ First checking is root HAS children
	mov r2, #0				@ register to hold the constant value 0
	ldr r12, =MyHeap
    ldr r10, [ r0, #0 ]     @ get integer from maximum
	mov r9, #0				@ initializing parent to null
	mov r8, #2				@ initializing traverse to 2
	ldr r3, [r0, #4]     @ load in left child
    ldr r4, [r0, #8]     @ load in right child
	mov r5, #0
	add r5, r3, r4 		@ checking if root has no children
	cmp r5, #0 		@ checking if addition of both left child and right child == 0 <-- meaning root has no children
	streq r2, [r12, #0]	@ If tree only has root, initialize pointer to root to 0
	@ ldreq r0, [r0, #0]		@ If tree only has root, moving root value to r0
	moveq r0, r10
	moveq pc, r14			@ If tree only has root, return root
	b while					@ Else, start while loop
	
while:

	@@@@@ if root has children, reaches this point
    ldr r3, [r0, #4]     @ load in left child
    ldr r4, [r0, #8]     @ load in right child
    add r5, r4, r3        @ adding values of LC and RC, if both are null result is 0
    cmp r5, #0             @ NULL CASE testing if root has no children
	beq noChild
	b hasChild
	
noChild:

	@@@@@ reached node that has no children, aka leaf BASE CASE
	cmp r8, #0				@ check if we traversed left
	streq r2, [r9, #4]		@ if parent left child equals leaf node, delete the parent's pointer to the leaf
	cmp r8, #1				@ check if we traversed right
	streq r2, [r9, #8]		@ if parent right child equals current leaf, delete the parent`s pointer to the leaf
	mov r0, r10			@ move maximum value to r0
    mov pc, r14 			@ return root
	
hasChild:

	@@@@@@@ only has left child
    cmp r5, r3 				@ checks if it only has a left node
    ldreq r6, [r3, #0]		@ load left childs value into r6
    streq r6, [r0, #0] 		@ store left childs value into root value
	moveq r9, r0			@ store root into parent
	moveq r8, #0			@ denote that we are traversing left
	moveq r0, r3
	beq while

	@@@@@@@ only has right child
    cmp r5, r4				@ checks if it only has a right child
    ldreq r7, [r4, #0]		@ load right child value into r7
	streq r7, [r0, #0]		@ store right child value into root
	moveq r9, r0			@ store root into parent
	moveq r8, #1 			@ denote that we are traversing right
	moveq r0, r4
	beq while

    ldr r6, [r3, #0]		@ LC value -> r6
	ldr r7, [r4, #0]		@ RC value -> r7
	
	@@@@ comparing both of the children
	cmp r6, r7
	movgt r8, #0			@ gt flag tripped when left int is greater than right
	strgt r6, [r0, #0]
	movgt r9, r0
	movgt r0, r3
	bgt while
	mov r8, #1				@ instructions called only when right int is greater than left
	str r7, [r0, #0]
	mov r9, r0
	mov r0, r4
	b while


@ This subroutine prints numbers from MaxHeap sorted (in descending order)
@ it takes a pointer-to-pointer to the heap as argument (in r0)
PrintHeapSorted:
	sub sp, sp, #8
	str r14, [sp]
	str r0, [sp, #4]	@ save the argument, which is a pointer to the pointer of the heap
L3:	
	bl deleteMax

	mov r1, r0		@ copy r0 to r1 for printing
	MOV r0, #1		@ Load 1 into register r0 (stdout handle) 
	SWI 0x6b		@ Print integer in register r1 to stdout

	@ print a space
	mov r0, #1
	ldr  r1,  =Space
	swi  0x69

	ldr r0, [sp, #4]	@ retrieve the saved argument for next iteraction

	@ check if the heap has become empty after the last call to deleteMax
	ldr r1, [r0]		
	cmp r1, #0
	beq L4			@ terminate if empty
	
	b L3
L4:	ldr r14, [sp]
	add sp, sp, #8
	mov pc, r14		


.data
MyHeap: .word 0
InFileName: .ascii "list.txt"  
InFileHandle: .word 0
Space: .ascii " "
