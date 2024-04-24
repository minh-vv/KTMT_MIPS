.data
	name: .asciiz "name = " 	#Chuỗi thông báo yêu cầu người dùng nhập tên
	ketqua: .asciiz "variableName(name) = " 	# Chuỗi thông báo kết quả trả về
	true:	.asciiz	"true\n" 	#Kết quả là true
	false:	.asciiz "false\n" 	#Kết quả là false
	null: .asciiz "Chưa nhập tên xin hãy nhập lại" 	#Chuỗi thông báo khi chưa nhập tên
	buffer: .space 64 	#Cấp phát 64 byte cho bộ nhớ đệm
.text
.globl main

main:
#Đọc đầu vào từ người dùng
readInput:
	li $v0,  54 	#InputDialogString
        la $a0, name 	#Thông báo
        la $a1, buffer 	#Địa chỉ bộ đệm đầu vào 
        la $a2, 64 	#Số ký tự tối đa có thể đọc
        syscall
	
	#Trường hợp người dùng muốn Cancel
	addi $t0, $zero, -2	# t0 = -2;
	beq $a1, $t0, cancel	# Nếu a1 = -2 thì thoát
	
	#Trường hợp người dùng chưa nhập nội dung
	addi $t0, $zero, -3	# t0 = -3
	beq $a1, $t0, nhapLai	# Nếu a1 = -3 thì yêu cầu nhập lại tên
	
	#Gọi hàm kiểm tra tên biến
	la $a0, buffer
	jal kiemTraName		# Gọi hàm
	beq $v0, 0, traVeFalse	# Nếu trả về 0 thì hiện false, còn trả về 1 thì hiện true
	
traVeTrue: 
	li $v0, 59	# MessageDialogString
	la $a0, ketqua		
	la $a1, true
	syscall
	j readInput	# Quay lại đọc input khác		

traVeFalse:
	li $v0, 59	# MessageDialogString
	la $a0, ketqua
	la $a1, false
	syscall
	j readInput	# Quay lại đọc input khác
cancel:
	li $v0, 10	# Thoát khỏi chương trình
	syscall

nhapLai:
	li $v0, 55	# MessageDialog
	la $a0, null	
	li $a1, 1	# icon
	syscall
	j readInput	# Quay lại đọc input khác
	
# Hàm: Kiểm tra tên biến hợp lệ 
# a0 = Địa chỉ chuỗi tên biến
# Trả về 1 nếu hợp lệ, về 0 nếu không hợp lệ

kiemTraName: 	# Kiểm tra kí tự đầu tiên có phải chữ số hay không
	lb $t0,0($a0)
	li $t1,'0'
	li $t2,'9'
	bge $t0,$t1, kiTuDauTien  
	b loop
	
kiTuDauTien:	#Nếu kí tự đầu tiên nằm trong khoảng 0 đến 9 thì trả về false
	ble $t0,$t2, khongHopLe 

loop:
	lb $t0,0($a0) 		# Kiểm tra từng kí tự một
	beq $t0, 10, hopLe 	# Kết thúc chuỗi
	
	li $t1, 'a'
	li $t2, 'z'
	li $t3, 'A'
	li $t4, 'Z'
	li $t5, '0'
	li $t6, '9'
	li $t7, '_'
	
	blt $t0,$t1, checkInHoa 	# Nếu kí tự không phải in thường thì sẽ kiểm tra xem có là in hoa hay không
	bgt $t0, $t2, checkInHoa
	j next				# Nếu kí tự là in thường thì chuyển sang kí tự kế tiếp
checkInHoa:
	blt $t0, $t3, checkSo		# Nếu kí tự không phải in hoa thì sẽ kiểm tra xem có là chữ số hay không
	bgt $t0, $t4, checkSo
	j next				# Nếu kí tự là in hoa thì chuyển sang kí tự kế tiếp
checkSo:
	blt $t0,$t5, checkGachDuoi	# Nếu kí tự không phải chữ số thì sẽ kiểm tra xem có là gạch dưới hay không
	bgt $t0,$t6, checkGachDuoi
	j next				# Nếu kí tự là chữ số thì chuyển sang kí tự kế tiếp
checkGachDuoi:
	bne $t0,$t8, khongHopLe		# Nếu kí tự không phải là gạch dưới thì trả về false
	
next:	addi $a0, $a0, 1		# Chuyển sang kí tự tiếp theo
	j loop
	
hopLe:	li $v0, 1	# true
	jr $ra

khongHopLe:
	li $v0, 0	# false
	jr $ra
	

