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

	@ To-Do: Here you should creat a base node (ROOT NODE) containing the just-read integer for your MaxHeap
	@ and save the base node address to the label MyHeap (which is declared in .data) for later references	
	mov R1, R0			@ store int read into r1
	mov R0, #12			@ allocate 12 bytes
	swi 0x12 			@ allocating space and set r0 to base addr
	str r0, [=MyHeap, #0] @ Store root node address into heap 
	str r1, [r0, #0]	@ saving integer into node
	mov r3, #0
	str r3, [r0, #4]	@ set left child null
	str r3, [r0, #8]	@ set right child null
	
	@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

    Loop:
	@ read integer from file
	ldr r1, =InFileHandle
	ldr r0, [r1]
	swi 0x6c	@ read an integer put in r0
	BCS CloseF	@ branch when the end of the file is reached

	@ TO-DO: You should comment out the above code for printing
	@ Instead, you creat a new node and save the integer into the first 4 bytes of the node
	@ Put the base node address in r0, and the address of the to-be-inserted node in r1
	@ call the subroutine Insert to insert the newly created node into the MaxHeap
	
	@ mov r0, r1 @ move int read into r1
	mov r0, #12 @ allocate 12 bytes for node
	swi 0x12 @ allocate space for new node and set r0 to the base address of newly created node
	str r1, [ r0, #0 ] @ storing int read into first 4 bytes of node
	mov r0, r1 @ moving to-be-inserted node's address into r1
	ldr r0, =MyHeap @ moving base node address into r0

	

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

@ TO-DO: write the Insert function below
@ The function takes two arguments: a pointer to the heap (in r0) and a pointer to a new node to be inserted to the heap (in r1) 
@ The function returns (in r0) a pointer to the root node (potentially can be the new node) of the heap
Insert: 

	mov pc, r14
	
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

@ TO_DO: write deleteMax function below
@ call-by-reference: the function takes a pointer-to-pointer as argument (in r0)
@ when the heap contains only one node (i.e., the root node), 
@ deleteMax should return root.data (to r0) and nullify the pointer to the root node
deleteMax:

	mov pc, r14

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
