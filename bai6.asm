.data
	Array: 	.space 100	#Cấp phát 100 byte cho mảng
	length: .asciiz "Nhap kich thuoc mang:"		#Thông báo nhập kích thước mảng
	element: .asciiz "Nhap lan luot phan tu cua mang:"	#Thông báo nhập phần tử mảng
	err: .asciiz " Co loi, xin nhap lai"		#Thông báo lỗi
	kq: .asciiz "Output: "				#Thông báo kết quả
.text
.globl main

main:	
	la $s0, Array		# Lưu mảng vào s0

	#Đọc kích thước mảng
	li $v0, 51		# InputDialogInt
	la $a0, length
	syscall
	
	beq $a1, -2, exit	#Nếu người dùng nhấn cancel thì thoát chương trình
	blez $a0, error		#Nếu kích thước mảng <= 0 thì báo lỗi và yêu cầu nhập lại
	bnez $a1, error		#Nếu nhập sai kiểu dữ liệu hoặc rỗng thì yêu cầu nhập lại
	
	move $s1, $a0		#Lưu kích thước mảng vào s1
	
	# Đọc phần tử của mảng
	li $t0, 0		#Tạo chỉ số i=0
loopInput:
	bge $t0, $s1, thoatInput	# Khi i == length thì ngừng đọc Input
	li $v0, 51			# InputDialogInt
	la $a0, element
	syscall
	
	beq $a1, -2, exit		# Nếu người dùng nhấn cancel thì thoát chương trình
	bnez $a1, error		#Nếu nhập sai kiểu dữ liệu hoặc rỗng thì yêu cầu nhập lại
	
	sw $a0,0($s0)			# Lưu A[i] = a0
	addi $s0, $s0, 4		# Tăng s0 thêm 4 bit, để lưu phần tử tiếp theo
	addi $t0, $t0, 1		# i = i+1
	j loopInput 			# Đọc phần tử tiếp theo
	
thoatInput:
	la $s0, Array			# Lưu s0 bằng địa chỉ A[0]

	jal timTichMax	# Gọi hàm tìm tích lớn nhất
	
	la $a0, kq
	move $a1,$v0 	# Lưu Max vào a1
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
	addi $s1,$s1,-1
loop:	beq $t0, $s1, end_loop	# Nếu i==length-1, kết thúc vòng lặp
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
	
	
