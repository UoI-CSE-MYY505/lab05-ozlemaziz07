# ----------------------------------------------------------------------------------------
# lab05.s 
# Verifies the correctness of some aspects of a 5-stage pipelined RISC-V implementation
# ----------------------------------------------------------------------------------------

.data
storage:
    .word 1
    .word 10
    .word 11

.text
# ----------------------------------------------------------------------------------------
# prepare register values.
# ----------------------------------------------------------------------------------------
la   a0, storage
addi s0, zero, 0
addi s1, zero, 1
addi s2, zero, 2
addi s3, zero, 3

# ----------------------------------------------------------------------------------------
# Verify forwarding from the previous ALU instruction to input Op1 of ALU
addi t1, s0, 1     
add  t2, t1, s2     
add  zero, zero, zero  
add  zero, zero, zero  
add  zero, zero, zero  

# ----------------------------------------------------------------------------------------
# Verify load-use 1 cycle stall and correct passing of load's value
lw   t3, 4(a0)
add  t4, zero, t3   # t4 should be storage[1] = 10
add  zero, zero, zero  
add  zero, zero, zero  
add  zero, zero, zero  

# ----------------------------------------------------------------------------------------
# Check how many cycles are lost due to pipe flush following a jump.
j    next
add  t5, s1, s2   # This instruction should be skipped
add  t6, s1, s2   # This instruction should be skipped
next:
add  zero, zero, zero  
add  zero, zero, zero  
add  zero, zero, zero  

# ----------------------------------------------------------------------------------------
# Verify that no cycles are lost when a branch is NOT taken
beq  s1, s2, next
add  t5, s1, s2
add  t6, s1, s3

# ----------------------------------------------------------------------------------------
# Check how many cycles are lost when a branch IS taken
beq  s1, s1, taken
add  t0, zero, s3
add  t1, zero, s2
taken:

# ----------------------------------------------------------------------------------------
# Example where an instruction passes its result to the 2nd following instruction
add  t1, s0, s1   # t1 = 1
addi t2, s0, s2   # t2 = 2
add  t3, t1, s3   # t3 = 4
add  zero, zero, zero  
add  zero, zero, zero  
add  zero, zero, zero  

# ----------------------------------------------------------------------------------------
# Double hazard example
add  t1, s0, s1   # t1 = 1
addi t1, s0, s2   # t1 = 2
add  t3, t1, s3   # t3 = 5
add  zero, zero, zero  
add  zero, zero, zero  
add  zero, zero, zero  

# ----------------------------------------------------------------------------------------
# Load and branch example, 1 cycle stall
lw   t3, 4(a0)
beq  t3, zero, exit  # If t3 = 0, go to exit
add  zero, zero, zero  
add  zero, zero, zero  
add  zero, zero, zero  

# Correct the branch to ensure a clear path to exit
beq  zero, s0, nextInstr # This always falls through
nextInstr:
    add  t0, s1, s2 
    add  t1, s2, s3 

exit:  
    addi      a7, zero, 10    
    ecall      # Exit program
