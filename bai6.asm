.data
	Array: 	.word 3, 6, -2, -5, 7, 3	# Input mảng
	length:	.word 6				# kích thước mảng
.text
.globl main

main:	la $a0, Array	# Tải địa chỉ mảng vào a0
	lw $a1, length	# Tải kích thước mảng vào a1
	
	jal timTichMax	# Gọi hàm tìm tích lớn nhất
	
	move $a0,$v0 	# Lưu Max vào a0
	li $v0, 1	# in ra màn hình
	syscall
	
	li $v0, 10	# kết thúc chương trình
	syscall
	
	
	
	
	
# Hàm tìm tích lớn nhất
timTichMax: 
	li $t0,0		# Chỉ số i=0
	lw $t1, 0($a0)		# t1 = A[i]
	li $v0, -2147483648	# Khởi tạo $v0 lưu Max
	
loop:	beq $t0, $a1, end_loop	# Nếu i==length, kết thúc vòng lặp
	addi $t2, $t0, 1	# t2 = i+1
	sll $t2, $t2, 2		# t2 = (i+1)*4
	add $t2, $t2, $a0	# Lưu địa chỉ A[i+1] vào t2
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
	
	
