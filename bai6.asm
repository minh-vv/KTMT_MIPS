.data
	Array: 	.space 100
	length: .asciiz "Nhap kich thuoc mang:"
	element: .asciiz "Nhap lan luot phan tu cua mang:"
	err: .asciiz " Co loi, xin nhap lai"
	kq: .asciiz "Output: "
.text
.globl main

main:	
	la $s0, Array
	#Doc kich thuoc mang
	li $v0, 51
	la $a0, length
	syscall
	
	beq $a1, -2, exit
	blez $a0, error
	
	move $s1, $a0
	
	# Nhap phan tu cua mang
	li $t0, 0
loopInput:
	bge $t0, $s1, thoatInput
	li $v0, 51
	la $a0, element
	syscall
	
	beq $a1, -2, exit
	blez $a0, error
	
	sw $a0,0($s0)
	addi $s0, $s0, 4
	addi $t0, $t0, 1
	j loopInput 
	
thoatInput:
	la $s0, Array

	jal timTichMax	# Gọi hàm tìm tích lớn nhất
	
	la $a0, kq
	move $a1,$v0 	# Lưu Max vào a0
	li $v0, 56	# in ra màn hình
	
	syscall
exit:
	li $v0, 10	# kết thúc chương trình
	syscall
	
error:
	li $v0, 55
	la $a0, err
	li $a1, 0
	syscall
	j main

# Hàm tìm tích lớn nhất
timTichMax: 
	li $t0,0		# Chỉ số i=0
	lw $t1, 0($s0)		# t1 = A[i]
	li $v0, -2147483648	# Khởi tạo $v0 lưu Max
	
loop:	beq $t0, $s1, end_loop	# Nếu i==length, kết thúc vòng lặp
	addi $t2, $t0, 1	# t2 = i+1
	
	sll $t2, $t2, 2		# t2 = (i+1)*4
	add $t2, $t2, $s0	# Lưu địa chỉ A[i+1] vào t2
	lw $t3, 0($t2)		# t3 = A[i+1]
	mul $t4, $t1, $t3	# Tích t4 = A[i] * A[i+1]
	bgt $t4, $v0, updateMax	# Nếu t4 > Max, cập nhật max
	j continue		

updateMax: move $v0, $t4	# Cập nhật max, v0 = t4

continue:
	addi $t0, $t0,1		# i++
	move $t1, $t3		# Di chuyển đến phần tử tiếp
	j loop			# Lặp lại vòng lặp

end_loop:
	jr $ra			# Quay về main
	
	
