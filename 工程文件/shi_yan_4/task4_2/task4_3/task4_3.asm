;�������汾
;1���û�������������˼���
;2���û���������ıȽϺ��� ���� xor Mychar, 'M' �����˶�̬�޸�ִ�д���ķ�ʽ���и�ǿ�ļ��ܣ�ʹ�ñ������Է��ֶ��ַ������˺��ֲ���
;2��Calcoptimize�ӳ���ĵ��ø�Ϊ�˶�̬�޸�ִ�д��� �����޸���SF�ļ��㹫ʽ
;3�������һ�������calculate���������ڸ���
;4������������calc�����ж�������һЩ��Ч���� ���ڸ���
;5�������ȴ�״̬�ӳ����д��������ݶ���
;6����ӵ���Login����

.686P
.model flat, stdcall
 ExitProcess proto stdcall:dword
 printf proto c:ptr sbyte, :vararg
 scanf proto c:ptr sbyte, :vararg
 putchar proto c:byte
 VirtualProtect proto:dword, :dword, :dword, :dword
 includelib kernel32.lib
 includelib libcmt.lib
 includelib legacy_stdio_definitions.lib
 timeGetTime proto stdcall
 includelib Winmm.lib

 ;�ṹ�嶨�� 
 SAMPLES STRUCT 
 	SAMID DB 6 DUP(0)
 	SDA DD ?
 	SDB DD ?
	SDC DD ?
	SF DD ?
 SAMPLES ENDS

.data ;���ݶζ���
 ;�����洢��
 LOWF SAMPLES 1000 DUP(<>)
 MIDF   SAMPLES 1000 DUP(<>)
 HIGHF  SAMPLES 1000 DUP(<>)
 ;�洢��ƫ��
 LowBias dd 0
 MidBias dd 0
 HighBias dd 0
 ;�ṹ������
 INPUT  SAMPLES <'1',1260, 100, 22, ?> ;mid
		SAMPLES <'2',1200, 478, 100, ?> ;mid
		SAMPLES <'3',10, 1, 1, ?> ;low
		SAMPLES <'4',20, 4, 1, ?> ;low
		SAMPLES <'5',1200000, 1, 1, ?> ;high
 ;�ṹ���С
 SizeOfSamples dd ?
 ;�û���������
 ;names db 'linguangming', 0 ;ԭ�ȵ��û���
 ;password db 'lgm381521', 0 ;ԭ�ȵ�����
 names db 'l' xor 'M', 'i' xor 'M', 'n' xor 'M', 'g' xor 'M',  'u' xor 'M',  'a' xor 'M',  'n' xor 'M',  'g' xor 'M',  'm' xor 'M',  'i' xor 'M',  'n' xor 'M',  'g' xor 'M', 0
 password db 'l' xor 'M','g' xor 'M', 'm' xor 'M','3' xor 'M', '8' xor 'M', '1' xor 'M', '5' xor 'M', '2' xor 'M', '1' xor 'M', 0
 name_in db 100 dup(0)
 password_in db 100 dup(0)
 flag dd ? ;��־λ
 len1 dd ?
 len2 dd ?
 len3 dd ?
 len4 dd ?
 TryCount dd 3
 Mychar db ?
 ;�ȴ�����״̬
 op db 100 dup(0)
 len5 dd ?
 endflag dd ? ;��־λ
 ;�������ڴ�ӡor������ַ���
 PrintForString db '%s', 0ah, 0dh, 0 ;���ڴ�ӡ�ַ���
 PrintForStruct db '%s %d %d %d %d', 0ah, 0dh, 0 ;���ڴ�ӡ�ṹ��
 Welcome db 'Please input your username and password', 0 ;�����û���������
 Check db 'Verifying username and password', 0 ;���ں�ʵ
 Correct db 'The username and password are correct', 0 ;��ȷ
 Wrong db 'The username or password is incorrect, please re-enter it', 0 ;�����������������
 MyEnd db 'Too many attempts: The program ends', 0 ;���������࣬����
 ScanfForString db '%s', 0 ;���������ַ���
 ;��̬�޸�ִ�д���
 machine_code db 0E8H, 24H, 0, 0, 0 ;ע��˴���2FH
 machine_code_len = $ - machine_code
 oldprotect dd ?
 machine_code2 db 0E8H, 44H, 01H, 0, 0
 machine_code_len2 = $ - machine_code2
 oldprotect2 dd ?
 ;���ڼ�ӵ����ӳ���
 functable dd MyMode, Login

.stack 200
.code ;�����
 ;�ӳ���1 ����ַ�������
 GetLen proc c, buf: dword, num:dword
 	pushad
 	mov ebx, buf
 	mov ecx, 0
 lp:
 	cmp byte ptr [ebx], 0
 	je exit
 	inc ebx
 	inc ecx
 exit:
 	mov ebx, num
 	mov [ebx], ecx
 	popad
    ret
 GetLen endp

 ;�ӳ���2 ��ӡMIDF
 PrintMid proc c, buf:dword, bias:dword
	local num:dword ;��Ҫ��ӡ������
	;�������Ҫ��ӡ������ ��bias / sizeof SAMPLES
	mov eax, bias
	cdq ;������չ
	idiv SizeOfSamples
	mov num, eax 
	;����ѭ��
	mov ebx, 0 ;ǧ�����ecx,,,printf��ı�ecx��ֵ
	mov esi, buf
 lp:
	cmp ebx, num
	je exit
	;����ƫ�Ƶ�ַ
	invoke printf, offset PrintForStruct, esi, [esi].SAMPLES.SDA, [esi].SAMPLES.SDB, [esi].SAMPLES.SDC, [esi].SAMPLES.SF
	add esi, SizeOfSamples
	inc ebx
	jmp lp
 exit:
	ret
 PrintMid endp
 
 ;�ӳ���3 ��������ӳ���5ʵ��"�����޸ķ��ص�ַ���ӳ���"
 Display proc
 	pop ebx
 PrintChar:
 	cmp byte ptr [ebx], 0
 	je DisplayExit
 	invoke putchar, byte ptr [ebx]
 	inc ebx
 	jmp PrintChar
 DisPlayExit:
 	inc ebx
 	push ebx
 	ret
 Display endp
 
 ;�ӳ���4 ѡ��ģʽ
 MyMode proc c
 	call Display
 	msg1 db 'Click Q to quit, click R to redo: ', 0ah, 0dh, 0
 InputPlease:
 	invoke scanf, offset ScanfForString, offset op
 	invoke GetLen, offset op, offset len5
 	cmp len5, 1
 	je LengthOne
 	call Display
 	msg2 db 'The input is invalid', 0ah, 0dh, 0
 	jmp InputPlease
 LengthOne:
 	cmp op, 'Q'
 	je IsQ
 	cmp op, 'q'
 	je IsQ
 	cmp op, 'R'
 	je IsR
 	cmp op, 'r'
 	je IsR 
    call Display
    msg3 db 'The input is invalid',0ah, 0dh, 0
    jmp InputPlease
 IsQ:
 	call Display
 	msg4 db 'End of program', 0ah, 0dh, 0
 	mov endflag, 0
 	ret
 IsR:
 	call Display
 	msg5 db 'Choose Redo', 0ah, 0dh, 0
 	mov endflag, 1
 	ret
 MyMode endp
 
 ;�ӳ���5 �ַ����Ƚ�
 ;ΪʲôҪ�Ѻ��Ϊ�ӳ�����Ϊ��������Change�����Ķ�̬�޸�ִ�д��룬��Ҫ֪��ƫ����
 MyCom proc, Stringone:dword, Stringtwo:dword, Lens1:dword, Lens2:dword  ;ע�ⲻ���ִ�Сд ����������
   mov eax, Lens1
   cmp eax, Lens2
   jne WA
   ;��ʼ�Ƚϴ�
   mov edi, Stringone
   mov esi, Stringtwo
   mov ecx, 0
   mov edx, Lens1
 StringCom:
    mov al, byte ptr [edi]
    mov Mychar, al
    pushad;����Ĵ���
    ;call Change ;������������ø�Ϊ��ִ̬��
    mov eax, machine_code_len
    mov ebx, 40H
    lea ecx, CopyHere
    invoke VirtualProtect, ecx, eax, ebx, offset oldprotect
    mov ecx, machine_code_len
    mov edi, offset CopyHere
    mov esi, offset machine_code
 CopyCode:
    mov al, [esi]
    mov [edi], al
    inc esi
    inc edi
    loop CopyCode
 CopyHere:
    db machine_code_len dup(0)
    
    popad;�ָ��Ĵ���
    mov al, byte ptr [esi]
    cmp Mychar, al
    jne WA
    inc edi
    inc esi
    inc ecx
    cmp ecx, edx
    jne StringCom
    jmp ExitCom
 WA:
    mov flag, 0
    jmp ExitCom
 ExitCom:
    ret
 MyCom endp
 	
 ;�ӳ���6���� ����Ϸ��ַ����ȽϺ��� ��Ϊ��̬�޸�ִ�д���
 Change proc 
 	xor Mychar, 'M'
 	ret
 Change endp
 
 ;������
 main proc c
	mov eax, functable + 4
 	call eax ;��ӵ���Login����
 Calc:
    mov eax, machine_code_len2
 	mov ebx, 40H
 	lea ecx, CopyHere2
 	invoke VirtualProtect, ecx, eax, ebx, offset oldprotect2
 	mov ecx, machine_code_len
 	mov edi, offset CopyHere2
 	mov esi, offset machine_code2
 CopyCode2:
 	mov al, [esi]
 	mov [edi], al
 	inc esi
 	inc edi
 	loop CopyCode2
 CopyHere2:
 	db machine_code_len2 dup(0)
 Print:
 	invoke PrintMid, offset MIDF, MidBias ;��ӡ
 ChooseMode:
 	call MyMode ;ѡ��ģʽ
 	cmp endflag, 0
 	je Exit
 	jmp Calc
 Exit:
 	invoke ExitProcess, 0
 main endp
 
 ;�ӳ���7 �û���¼����
 Login proc c
 	invoke printf, offset PrintForString, offset Welcome
 	invoke GetLen, offset names, offset len1
 	invoke GetLen, offset password, offset len2
 lp:
 	invoke scanf, offset ScanfForString, offset name_in
 	invoke scanf, offset ScanfForString, offset password_in
 	invoke GetLen, offset name_in, offset len3
 	invoke GetLen, offset password_in, offset len4
 	mov flag, 1
    invoke MyCom, offset names, offset name_in, len1, len3
 	invoke MyCom, offset password, offset password_in, len2, len4
 	cmp flag, 0
 	jne CorrectRet
 	dec TryCount
 	cmp TryCount, 0
 	je WrongExit
 	invoke printf, offset PrintForString, offset Wrong
 	jmp lp
 CorrectRet:
 	invoke printf, offset PrintForString, offset Correct
 	ret
 WrongExit:
 	invoke printf, offset PrintForString, offset MyEnd
 	invoke ExitProcess, 0 ;ֱ�ӱ����˳�
 	ret
 Login endp

  ;�ӳ���8 ���� ��ʽ�޸�Ϊ
 ;�����ʱ�������һЩ��Чָ��
 Calcoptimize proc c
	mov SizeOfSamples, sizeof SAMPLES
	mov esi, offset INPUT ;��esi��Žṹ���������ʼ��ַ
	mov ecx, 5 ;�������nһ��ֵ
 lp:
	mov eax, [esi].SAMPLES.SDA
	mov ebx, 10 ;��Чָ��1
	lea eax, 22[eax][eax * 4]
	add eax, [esi].SAMPLES.SDB
	add ebx, eax ;��Чָ��2
	sub eax, [esi].SAMPLES.SDC
	sar eax, 6 ;�ĳ���������
	xor edx, 10; ��Чָ��3
	mov [esi].SAMPLES.SF, eax
	cmp eax, 64H
	jg L1
	jl L2
	;�����ݴ��ȥMID
	mov ebx, offset MIDF
	add ebx, MidBias
	add MidBias, sizeof SAMPLES
	jmp action
	mov eax, 10 ;��Чָ��4
	mov ebx, 20 ;��Чָ��5
	mov edx, SizeOfSamples ;��Чָ��6
 L1:
	;�����ݴ��ȥHIGH
	mov ebx, offset HIGHF
	add ebx, HighBias
	add HighBias, sizeof SAMPLES
	jmp action
 L2:
	;�����ݴ��ȥLOW
	mov ebx, offset LOWF 
	add ebx, LowBias
	add LowBias, sizeof SAMPLES
	jmp action
 action:
	mov eax, dword ptr [esi] ;ǰ4���ֽ�
	mov dword ptr [ebx], eax
	mov ax, word ptr 4[esi] ;�������ֽ�
	mov word ptr 4[ebx], ax
	;����4������
	mov eax, [esi].SAMPLES.SDA
	mov [ebx].SAMPLES.SDA, eax
	mov eax, [esi].SAMPLES.SDB
	mov [ebx].SAMPLES.SDB, eax
	mov eax, [esi].SAMPLES.SDC
	mov [ebx].SAMPLES.SDC, eax
	mov eax, [esi].SAMPLES.SF
	mov [ebx].SAMPLES.SF, eax
	add esi, sizeof SAMPLES
	dec ecx
	cmp ecx, 0
	je L4
	jmp lp
 L4:
	ret
 Calcoptimize endp

 ;�ӳ���10 �����calculate���� ���ڸ���
 ;�ü��㺯��Ϊ SF = (SDA * 9 + 100 - SDB + SDC) >> 8
 Calcoptimize2 proc c
	mov SizeOfSamples, sizeof SAMPLES
	mov esi, offset INPUT ;��esi��Žṹ���������ʼ��ַ
	mov ecx, 5 ;�������nһ��ֵ
 lp:
	;��5 + 100��lea�Ż�
	mov eax, [esi].SAMPLES.SDA
	mov ebx, 10 ;��Чָ��1
	lea eax, 100[eax][eax * 8]
	add eax, [esi].SAMPLES.SDB
	add ebx, eax ;��Чָ��2
	sub eax, [esi].SAMPLES.SDC
	sar eax, 8 ;�ĳ���������
	xor edx, 10; ��Чָ��3
	mov [esi].SAMPLES.SF, eax
	cmp eax, 64H
	jg L1
	jl L2
	;�����ݴ��ȥMID
	mov ebx, offset MIDF
	add ebx, MidBias
	add MidBias, sizeof SAMPLES
	jmp action
	mov eax, 10 ;��Чָ��4
	mov ebx, 20 ;��Чָ��5
	mov edx, SizeOfSamples ;��Чָ��6
 L1:
	;�����ݴ��ȥHIGH
	mov ebx, offset HIGHF
	add ebx, HighBias
	add HighBias, sizeof SAMPLES
	jmp action
 L2:
	;�����ݴ��ȥLOW
	mov ebx, offset LOWF 
	add ebx, LowBias
	add LowBias, sizeof SAMPLES
	jmp action
 action:
	mov eax, dword ptr [esi] ;ǰ4���ֽ�
	mov dword ptr [ebx], eax
	mov ax, word ptr 4[esi] ;�������ֽ�
	mov word ptr 4[ebx], ax
	;����4������
	mov eax, [esi].SAMPLES.SDA
	mov [ebx].SAMPLES.SDA, eax
	mov eax, [esi].SAMPLES.SDB
	mov [ebx].SAMPLES.SDB, eax
	mov eax, [esi].SAMPLES.SDC
	mov [ebx].SAMPLES.SDC, eax
	mov eax, [esi].SAMPLES.SF
	mov [ebx].SAMPLES.SF, eax
	add esi, sizeof SAMPLES
	dec ecx
	cmp ecx, 0
	je L4
	jmp lp
 L4:
	ret
 Calcoptimize2 endp
end