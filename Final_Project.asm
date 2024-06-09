.data 
    hex: .byte '0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'
    prompt: .asciiz "Nhap chuoi du lieu (do dai la boi cua 8): "
    string: .space 256    # chuoi dau vao
    
    disk1: .space 100
    disk2: .space 100
    disk3: .space 100
    parity: .space 1000
    
    newline: .asciiz "\n"
    error_msg: .asciiz "Do dai chuoi khong hop le! Nhap lai.\n"
    
    in1:     .asciiz "      Disk1              Disk2                 Disk3     \n"
    in2:     .asciiz "----------------     ----------------     ----------------\n"
    indau:     .asciiz "|     "    
    ingiua:  .asciiz            "     |     "
    enter:     .asciiz "\n"
    insodau: .asciiz "[[ "
    insocuoi:.asciiz "]]"
    inphay:  .asciiz ","
.text
    main:
        la $s1, disk1
        la $s2, disk2
        la $s3, disk3
        
    input:
    # Thong bao nhap chuoi
        li $v0, 4
        la $a0, prompt
        syscall
        
    # Nhap du lieu
        li $v0, 8
        la $a0, string        
        li $a1, 256        # Cap phat bo nho
        syscall
                
        move $s0, $a0        # s0 chua dia chi input
    # Kiem tra do dai
        addi $t0, $0, 0        # t0 = length
        la $t2, 0($s0) 
    count_length:
        lb $t1, 0($t2)        # t1 = string[i]
        beq $t1,10, check_length
        addi $t2, $t2, 1
        addi $t0, $t0, 1
        j count_length

    check_length:
        li $t2, 8
        div $t0, $t2
        mflo $s4        # $4: so lan lap = thuong
        mfhi $t3        # so du
        bnez $t3, error_length  # so du khac 0 thi bao loi
            
        beqz $s4, exit
    # In dong 1
        li $v0, 4
        la $a0, in1
        syscall
    # In dong 2
        li $v0, 4
        la $a0, in2 
        syscall
        
    # chay chuong trinh
        j split1
        
    error_length:            # loi khong chia het cho 8
        li $v0, 4
        la $a0, error_msg
        syscall
        j input
        
    exit:
        li $v0, 10
        syscall

    #-----HEX-----
    HEX:    li     $t4, 1
    loopH:    blt     $t4, $0, endloopH
        sll     $s6, $t4, 2        # s6 = t4*4
        srlv     $a0, $t8, $s6            # a0 = t8>>s6
        andi     $a0, $a0, 0xf     # a0 = a0 & 0000 0000 0000 0000 0000 0000 0000 1111 => lay byte cuoi cung cua a0
        la     $t7, hex 
        add     $t7, $t7, $a0 
        lb     $a0, 0($t7)             # print hex[a0]
        li     $v0, 11
        syscall
        
        addi     $t4,$t4,-1
        j     loopH

    endloopH: jr     $ra
    #-------------

    # block1 vao disk1, block2 vao disk2, parity vao disk3
    split1:    
        la $s1, disk1
        la $s2, disk2
        la $s3, disk3
        
        addi $t0, $0, 0        # so ki tu doc moi block
    block11: # luu ki tu vao disk1
        lb $t1, ($s0)
        sb $t1, ($s1)
    block21: # Luu ki tu vao disk2 
        lb $t2, 4($s0)
        sb $t2, ($s2)
    parity1: # Luu xor vao parity
        xor $t3, $t1, $t2 
        sb  $t3, 0($s3)
        
        addi $s0, $s0, 1    # tang dia chi string
        addi $s1, $s1, 1    # Tang dia chi cac disk
        addi $s2, $s2, 1
        addi $s3, $s3, 4
        
        addi $t0, $t0, 1    # Kiem tra du 4 ki tu = 1 block chua
        beq $t0, 4, reset
        j block11

    reset:     # Khoi phuc dia chi ban dau
        la $s1, disk1
        la $s2, disk2
        la $s3, disk3
    print11:
        li $v0, 4
        la $a0, indau
        syscall
        
                
    prbk11:    # In block 1
        sb $zero, 4($s1)    # Them ki tu \0 de bien thanh chuoi
        li $v0, 4
        la $a0, ($s1)
        syscall
        
    print21:
        li     $v0, 4
        la     $a0, ingiua
        syscall
        li     $v0, 4
        la     $a0, indau
        syscall
        
        
    prbk21: # In block 2
        sb $zero, 4($s2)    # Them ki tu \0 de bien thanh chuoi
        li $v0, 4
        la $a0, ($s2)
        syscall
        
        
    print31:
        li $v0, 4
        la $a0, ingiua
        syscall
        li $v0, 4
        la $a0, insodau
        syscall

        addi $t0, $0, 0
    prbk31: #in disk 3
        lb $t8, ($s3)
        jal HEX
        li $v0, 4
        la $a0, inphay 
        syscall
        
        addi $t0, $t0, 1
        addi $s3, $s3, 4
        bgt $t0, 2, end1
        j prbk31

    end1:
        lb $t8, ($s3)    # truyen thanh t8 vao ham hex
        jal HEX
        li $v0, 4
        la $a0, insocuoi    # ,
        syscall
        
        li     $v0, 4        # \n
        la     $a0, newline
        syscall
        
        addi $s4,$s4,-1        # So lan lap -1
        beqz $s4, exitln   # Lap = 0 out
        
       addi $s0, $s0, 4
 #       addi $s1, $s1, 1
 #       addi $s2, $s2, 1
  #      addi $s3, $s3, 4 
        
   

    #----- Split 2 -----
    # block1 vao disk1, block2 vao disk3, parity vao disk2
    split2:    
        la $s1, disk1
        la $s2, disk2
        la $s3, disk3
        
        addi $t0, $0, 0        # so ki tu doc moi block
    block12: # luu ki tu vao disk1
        lb $t1, ($s0)
        sb $t1, ($s1)
    block22: # Luu ki tu vao disk3 
        lb $t2, 4($s0)
        sb $t2, ($s3)
    parity2: # Luu xor vao parity
        xor $t3, $t1, $t2 
        sb  $t3, 0($s2)
        
        addi $s0, $s0, 1    # tang dia chi string
        addi $s1, $s1, 1    # Tang dia chi cac disk
        addi $s2, $s2, 4
        addi $s3, $s3, 1
        
        addi $t0, $t0, 1    # Kiem tra du 4 ki tu = 1 block chua
        beq $t0, 4, reset2
        j block12

    reset2:     # Khoi phuc dia chi ban dau
        la $s1, disk1
        la $s2, disk2
        la $s3, disk3
    print12:
        li $v0, 4
        la $a0, indau
        syscall
        
                
    prbk12:    # In block 1
        sb $zero, 4($s1)    # Them ki tu \0 de bien thanh chuoi
        li $v0, 4
        la $a0, ($s1)
        syscall
        
    print22:
        li     $v0, 4
        la     $a0, ingiua
        syscall
        li     $v0, 4
        la     $a0, insodau
        syscall
        
         addi $t0, $0, 0
    prbk22: #in disk 2
        lb $t8, ($s2)
        jal HEX
        li $v0, 4
        la $a0, inphay 
        syscall
        
        addi $t0, $t0, 1
        addi $s2, $s2, 4
        bgt $t0, 2, end2
        j prbk22

    end2:
        lb $t8, ($s2)    # truyen thanh t8 vao ham hex
        jal HEX
        li $v0, 4
        la $a0, insocuoi    
        syscall
        
print32:
        li $v0, 4
        la $a0, ingiua
        syscall

prbk32: # In (disk3)
        sb $zero, 4($s3)    # Them ki tu \0 de bien thanh chuoi
        li $v0, 4
        la $a0, ($s3)
        syscall
        
print33:
        li $v0, 4
        la $a0, ingiua
        syscall  
        
        li     $v0, 4        # \n
        la     $a0, newline
        syscall
        
        addi $s4,$s4,-1        # So lan lap -1
        beqz $s4, exitln    # Lap = 0 out
        
        addi $s0, $s0, 4
  #      addi $s1, $s1, 1
 #       addi $s2, $s2, 4
  #      addi $s3, $s3, 1

#----- Split 3 -----
# block1 vao disk3, block2 vao disk2, parity vao disk1
split3:    
        la $s1, disk1
        la $s2, disk2
        la $s3, disk3
        
        addi $t0, $0, 0        # so ki tu doc moi block
block13: # luu ki tu vao disk2
        lb $t1, ($s0)
        sb $t1, ($s2)
block23: # Luu ki tu vao disk3 
        lb $t2, 4($s0)
        sb $t2, ($s3)
parity3: # Luu xor vao parity
        xor $t3, $t1, $t2 
        sb  $t3, 0($s1)
        
        addi $s0, $s0, 1    # tang dia chi string
        addi $s1, $s1, 4    # Tang dia chi cac disk
        addi $s2, $s2, 1
        addi $s3, $s3, 1
        
        addi $t0, $t0, 1    # Kiem tra du 4 ki tu = 1 block chua
        beq $t0, 4, reset3
        j block13

reset3:     # Khoi phuc dia chi ban dau
        la $s1, disk1
        la $s2, disk2
        la $s3, disk3
print13:
        li $v0, 4
        la $a0, insodau
        syscall

	addi $t0, $0, 0
prbk13: #in disk 2
        lb $t8, ($s1)
        jal HEX
        li $v0, 4
        la $a0, inphay 
        syscall
        
        addi $t0, $t0, 1
        addi $s1, $s1, 4
        bgt $t0, 2, end3
        j prbk13

end3:
        lb $t8, ($s1)    # truyen thanh t8 vao ham hex
        jal HEX
        li $v0, 4
        la $a0, insocuoi    
        syscall

        li     $v0, 4		# "    |     "
        la     $a0, ingiua
        syscall      
                        
prbk23:    # In disk2
        sb $zero, 4($s2)    # Them ki tu \0 de bien thanh chuoi
        li $v0, 4
        la $a0, ($s2)
        syscall
        

        li     $v0, 4		# "     |      |     "
        la     $a0, ingiua
        syscall
        li     $v0, 4
        la     $a0, indau
        syscall
             
prbk33: # In disk3
        sb $zero, 4($s3)    # Them ki tu \0 de bien thanh chuoi
        li $v0, 4
        la $a0, ($s3)
        syscall
        
        li $v0, 4		# "     |      "
        la $a0, ingiua
        syscall
        
        li     $v0, 4        # \n
        la     $a0, newline
        syscall
        
        addi $s4,$s4,-1        # So lan lap -1
        beqz $s4, exitln    # Lap = 0 out
       
    
      	addi $s0, $s0, 4
      	j split1
##        addi $s1, $s1, 4
 #       addi $s2, $s2, 1
 #       addi $s3, $s3, 1
           
exitln: 
        li     $v0, 4
        la     $a0, in2
        syscall
        j exit
