;1���û��������붨��ʱ�����˼���
;2����¼ģ��ʹ���� �������ݶ��� �Լ�ʹ����"�����޸ķ��ص�ַ"���ӳ���
;3��SF���㺯��ʹ���˶�̬�޸�ִ�д���,�����޸���SF�ļ��㹫ʽ
;4��SF���㺯���Ľ�һ�����ܺ����д�������Ч����
;5��ʹ���˼�ӵ����ӳ���
.686P 
.model flat, stdcall
  ExitProcess proto stdcall :dword
  includelib  kernel32.lib
  printf      proto c :vararg
  scanf      proto c :vararg
  VirtualProtect proto:dword, :dword, :dword, :dword
  putchar proto c:byte
  includelib  libcmt.lib
  includelib  legacy_stdio_definitions.lib

strcmp MACRO str1,str2;�ַ����ȽϺ�ָ��
	local L1, outer, right, checkagain
	mov ecx,0
L1:
	mov al, str1[ecx]
	mov bl, str2[ecx]
	cmp bl,0 ;ע��һ������
	je checkagain
	xor bl, 'W' 
	cmp al,bl
	jnz outer
	inc ecx
	jmp L1
checkagain:
	cmp al, 0
	je right
outer:
	mov signflag, 0
	jmp sign_error
right:
endm

.data
;username db 'mengxiangwenxin',0
;password db 'kazuha1029',0
username db 'm' xor 'W', 'e' xor 'W','n' xor 'W','g' xor 'W','x' xor 'W','i' xor 'W','a' xor 'W','n' xor 'W','g' xor 'W','w' xor 'W','e' xor 'W','n' xor 'W','x' xor 'W','i' xor 'W','n' xor 'W',0
password db 'k' xor 'W', 'a' xor 'W','z' xor 'W','u' xor 'W','h' xor 'W','a' xor 'W','1' xor 'W','0' xor 'W','2' xor 'W', '9' xor 'W', 0 
tip1 db 'Welcome to this lab! Please input the username and your password(Enter to trans):',0
welcomestc db 'YES! Let''s start our travel!',0
retry db 'Wrong information! Please input again!',0
restart db 'Now all done. Click R to restart, or click Q to quit',0
wrong_to_quit db 'You have tried three times but all were wrong, now quit.',0
wrong_of_click db 'Input error! Please try again:',0

format1 db "%s",0;�����û����������ַ���
format2 db "%c",0
lpFmt db "%s",0ah,0dh,0
sdaprint db 'SDA:%d', 0ah, 0dh, 0
sdbprint db 'SDB:%d', 0ah, 0dh, 0
sdcprint db 'SDC:%d', 0ah, 0dh, 0
sfprint db 'SF:%d', 0ah, 0dh, 0ah, 0dh, 0
samidprint db 'SAMID:%s', 0ah, 0dh, 0

inputname db 20 dup(0)
inputpass db 20 dup(0)

signcount dd ?;��¼���Դ���
signflag dd ?;��¼�Ƿ�ɹ����ɹ�Ϊ1��ʧ��Ϊ0

samples STRUCT
SAMID  db 9 DUP(0)	;ÿ�����ݵ���ˮ��
SDA   dd  ?			;״̬��Ϣa
SDB   dd  ?			;״̬��Ϣb
SDC   dd  ?			;״̬��Ϣc
SF    dd  ?			;������f
samples ENDS

demo    SAMPLES <'00000001', 3200, 0, 0, >		    ;mid
	    SAMPLES <'00000002', 2333, 1136, 1, >		;
		SAMPLES <'00000003', 3100, 112, 6, >		;mid
		SAMPLES <'00000004', 3012, 196, 4, >		;mid
		SAMPLES <'00000005', 2333, 1451, 316, >		;
LOWF SAMPLES 50 dup(<>)
MIDF SAMPLES 50 dup(<>)
HIGHF SAMPLES 50 dup(<>)

samplecount dd ?
lowcnt dd ?
midcnt dd ?
highcnt dd ?

restarttip db 100 dup(0)

;���ڶ�̬�޸�ִ�д���ı���
machine_code db 0E8H, 05H,0, 0, 0;ע��˴���
machine_len = $ - machine_code
oldprotect dd ?

;�޸�
Sampletype dd ?  
Choice dd ?
Result dd ?
TempNum dd ?
EsiBackUp dd ?
Table dd MySignIn, MySave, printMID, MyLreStart
num dd 0, 4, 8, 12


.stack 200
.code

;�ӳ���1 ���MySignIN����ʵ�ִ������ݶ��壬ʵ�������޸ķ��ص�ַ
Display proc
	pop ebx
PrintLoop:
	cmp byte ptr [ebx], 0
	je PrintExit
	invoke putchar, byte ptr [ebx]
	inc ebx
	jmp PrintLoop
PrintExit:
	inc ebx
	push ebx
	ret
Display endp

;�ӳ���2 ��¼����
MySignIn proc c
	mov Sampletype, type SAMPLES
	;��¼ģ��
	mov signcount,3
SignIn:
	;invoke printf, offset lpFmt, offset tip1 ;��Ϊ�������ݶ���
	call Display
	msg1 db 'Welcome to this lab! Please input the username and your password(Enter to trans):',0ah, 0dh, 0
	invoke scanf, offset format1, offset inputname
	invoke scanf, offset format1, offset inputpass
	mov signflag, 1
	strcmp inputname, username
	strcmp inputpass, password
	cmp signflag, 1
	je sign_done
sign_error:
	dec signcount
	cmp signcount,0
	je sign_false
	;invoke printf, offset lpFmt, offset retry ;��Ϊ�������ݶ���
	call Display
	msg2 db 'Wrong information! Please input again!',0ah, 0dh, 0
	jmp SignIn
sign_done:
	;invoke printf, offset lpFmt, offset welcomestc ;��Ϊ�������ݶ���
	call Display
	msg3 db 'YES! Let''s start our travel!',0ah, 0dh, 0
	ret
sign_false:
	;invoke printf, offset lpFmt, offset wrong_to_quit ;��Ϊ�������ݶ���
	call Display
	msg4 db 'You have tried three times but all were wrong, now quit.',0ah, 0dh, 0
	invoke ExitProcess, 0
	ret
MySignIn endp

;�ӳ���3 ����SF���� ��̬�޸�ִ�д���
calculate proc, AA:dword, BB:dword, CC:dword  ;SF�ļ��㹫ʽΪ SF = (SDA + SDB - 2 * SDC) >> 5
	mov eax, AA
    mov edx, BB
    add eax, edx
    mov edx, CC
	mov Result, eax
	mov TempNum, edx
	pushad;�����Ĵ���
	;call encipher ;����������Ϊ��̬�޸�
	mov eax, machine_len
    mov ebx, 40H
    lea ecx, CopyHere
    invoke VirtualProtect, ecx, eax, ebx, offset oldprotect
    mov ecx, machine_len
    mov edi, offset CopyHere
    mov esi, offset machine_code
 CopyCode:
    mov al, [esi]
    mov [edi], al
    inc esi
    inc edi
    loop CopyCode
 CopyHere:
    db machine_len dup(0)
	popad;�ָ��Ĵ���
    ret
calculate endp

;�ӳ���4 ��SF������и���һ���ļ��� ���Ҵ���һЩ��Ч����
encipher proc
	mov eax, Result
	mov edx, TempNum
	imul edx, 2
	mov ecx, 100;��Ч����1
	sub eax, edx
	sub ebx, edx;��Ч����2
	sar eax, 5
	mov ecx, eax;��Ч����3
	mov Result, eax
	ret
encipher endp

;�ӳ���5 �洢ģ��
MySave proc c
	mov eax, Result
	mov esi, EsiBackUp
	cmp eax, 100
	jg HIGHN
	jl LOWN
	je MIDN

LOWN:
	mov edi,lowcnt
    mov LOWF[edi].SF, eax
    mov eax, demo[esi].SDA
    mov LOWF[edi].SDA, eax
    mov eax,demo[esi].SDB
    mov LOWF[edi].SDB, eax
    mov eax,demo[esi].SDC
    mov LOWF[edi].SDC, eax
    mov ecx,0
LLow:
    mov ebx,dword ptr demo[esi].SAMID[ecx]
    mov dword ptr LOWF[edi].SAMID[ecx],ebx
    add ecx,4
    cmp ecx,8
    jl LLow
		add edi, Sampletype
		mov lowcnt,edi
        jmp SaveExit

MIDN:
	mov edi, midcnt
    mov MIDF[edi].SF, eax
    mov eax, demo[esi].SDA
    mov MIDF[edi].SDA, eax
    mov eax, demo[esi].SDB
    mov MIDF[edi].SDB, eax
    mov eax, demo[esi].SDC
    mov MIDF[edi].SDC, eax
    mov ecx,0
MMid:
    mov ebx,dword ptr demo[esi].SAMID[ecx]
    mov dword ptr MIDF[edi].SAMID[ecx],ebx
    add ecx,4
    cmp ecx,8
    jl MMid
		add edi, Sampletype
		mov midcnt, edi
        jmp SaveExit

HIGHN:
	mov edi,highcnt
    mov HIGHF[edi].SF,eax
    mov eax, demo[esi].SDA
    mov HIGHF[edi].SDA, eax
    mov eax, demo[esi].SDB
    mov HIGHF[edi].SDA, eax
    mov eax, demo[esi].SDC
    mov HIGHF[edi].SDA, eax
    mov ecx,0
HHigh:
    mov ebx,dword ptr demo[esi].SAMID[ecx]
    mov dword ptr LOWF[edi].SAMID[ecx],ebx
    add ecx,4
    cmp ecx,8
    jl HHigh
		add edi, Sampletype
		mov highcnt, edi
        jmp SaveExit

SaveExit:
	ret	
MySave endp

;�ӳ���6 ��ӡMIDF
printMID proc
    mov ebx,0
L1:
	mov edi, offset MIDF
	add edi, ebx
	invoke printf, offset samidprint, edi
    invoke printf, offset sdaprint, MIDF[ebx].SDA
    invoke printf, offset sdbprint, MIDF[ebx].SDB
    invoke printf, offset sdcprint, MIDF[ebx].SDC
    invoke printf, offset sfprint, MIDF[ebx].SF
    add ebx,Sampletype
    cmp ebx,midcnt
    jne L1
ret
printMID endp

;�ӳ���7 �����ȴ�״̬����
MyLreStart proc
	invoke printf, offset lpFmt, offset restart
Linput:
	invoke scanf, offset format1, offset restarttip
	mov al, restarttip ;��ȡ��һ���ַ�
	cmp al, 'r'
	je Exit1
	cmp al, 'q'
	je Exit2
	jne Lwrong
Lwrong:
	invoke printf, offset lpFmt, offset wrong_of_click
	jmp Linput
Exit1:
	mov Choice, 1
	ret
Exit2:
	mov Choice, 0
	ret
MyLreStart endp

;������
main proc c
;��¼ģ��
	call Table[0] ;��ӵ��� 
	;call MySignIn
;���㲢�洢��ˮ��ģ��
MyLoop:
	mov lowcnt,0;LOW
	mov midcnt,0;MID
	mov highcnt,0;HIGH
	mov samplecount, 0
Lp:
	;����ģ��
	mov esi, samplecount ;ʹ����esi ע��
	imul esi,Sampletype
	mov EsiBackUp, esi
	invoke calculate, demo[esi].SDA, demo[esi].SDB, demo[esi].SDC
	mov esi, EsiBackUp
	mov eax, Result
	mov demo[esi].SF, eax
	;�洢ģ��
	mov ebx, num + 4
	call Table[ebx];��ӵ���
	;call MySave
	;ѭ������
	inc samplecount
	cmp samplecount, 5
	jne Lp
;��ӡģ��
	lea eax, Table + 8
	call dword ptr [eax];��ӵ���
	;call printMID 
;�����ȴ�ģ��
	call Table[12];��ӵ���
	;call MyLreStart
	cmp Choice, 0
	je Exit
	jmp MyLoop
;�����˳�ģ��
Exit:
	invoke ExitProcess, 0
main endp
end

