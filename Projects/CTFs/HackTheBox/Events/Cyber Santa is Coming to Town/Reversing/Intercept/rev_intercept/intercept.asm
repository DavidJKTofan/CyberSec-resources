	.text
	.globl	state
	.bss
	.type	state, @object
	.size	state, 1
state:
	.zero	1
	.text
	.globl	do_encrypt
	.type	do_encrypt, @function
do_encrypt:
	push	rbp
	mov	rbp, rsp
	mov	eax, edi
	mov	BYTE PTR [rbp-4], al
	movzx	eax, BYTE PTR state[rip]
	add	eax, 19
	xor	BYTE PTR [rbp-4], al
	movzx	eax, BYTE PTR state[rip]
	add	eax, 55
	mov	BYTE PTR state[rip], al
	movzx	eax, BYTE PTR [rbp-4]
	pop	rbp
	ret
