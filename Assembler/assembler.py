'''  Assembler for RV16R  '''

import sys

#Retorna tipo da instrução e opcode
def getOpcode(string, L_Type, R_Type, B_Type, S_Type):
	if string in S_Type:
		return S_Type["op"], S_Type[string]
	if string in L_Type:
		return L_Type["op"], L_Type[string]
	if string in R_Type:
		return R_Type["op"], R_Type[string]
	if string in B_Type:
		return B_Type["op"], B_Type[string]
	return -1, -1

#Retorna o registro
def getRegister(string):
	return int(string[1:])

#Retorna immediato com complemento de dois
def getImmediate(string):
	flag = False
	num = int(string)
	if num < 0:
		return 16 + num
	return num

#Retorna o binario do numero
def getBin(num):
	strBin = bin(num) 
	strBin = strBin.lstrip('0b')
	strBin = completBin(strBin)
	return strBin

#Completa o tamanho do campo
def completBin(strBin):
	temp = len(strBin)
	temp = 4 - temp
	for i in range(temp):
		strBin = "0" + strBin
	return strBin

#
def formatInt(num, tam):
	h = str(format(num, 'X'))
	if len(h) == tam:
		return h
	while len(h)<tam:
		a = "0" + h
		h = a
	return h	

#Cria arquivo HEX
def geraHEX(intrs):
	n = 0
	arq = open("program.hex","w")
	pos = 0
	for i in intrs:
		temp = hex(int(i, 2))
		a = str(temp[2:])
		while len(a) < 4:
			a = "0" + a
		a = a.upper()
		HEX =  a
		pos += 1
		#print(HEX)
		arq.write(HEX)
		arq.write("\n")


	while pos <= 65535:
		HEX = "0000"
		pos += 1
		#print(HEX)
		arq.write(HEX)
		arq.write("\n")
	
	arq.close()

''' main '''

L_Type = {"op": "01", "load": "01" , "addi": "00", "andi": "10", "ori": "11"}
R_Type = {"op": "00", "add": "00", "sub": "01", "and": "10", "or": "11"}
B_Type = {"op": "11", "beq": "01"}
S_Type = {"op": "10", "store": "00"}

intrs = []

#Leitura das instruções
for instruction in sys.stdin:
	#Separa as partes da instrução
	instr_parts = instruction.split()

	#Recebe o Opcode e o Func da instrução
	Op, Func = getOpcode(instr_parts[0], L_Type, R_Type, B_Type, S_Type)

	#Instrução de Tipo R
	if Op == "00":

		#Recebe registradores
		Rd = getRegister(instr_parts[1])
		Rs1 = getRegister(instr_parts[2])
		Rs2 = getRegister(instr_parts[3])

		rd = getBin(Rd)
		rs1 = getBin(Rs1)
		rs2 = getBin(Rs2)
		
		binInstr = rs2 + rs1 + Func + rd + Op


	elif Op == "01":

		Rd = getRegister(instr_parts[1])
		Rs1 = getRegister(instr_parts[2])
		immed = getImmediate(instr_parts[3])

		rd = getBin(Rd)
		rs1 = getBin(Rs1)
		immed = getBin(immed)

		binInstr = immed + rs1 + Func + rd + Op


	elif Op == "11" or Op == "10":

		Rs1 = getRegister(instr_parts[1])
		Rs2 = getRegister(instr_parts[2])
		immed = getImmediate(instr_parts[3])

		rs1 = getBin(Rs1)
		rs2 = getBin(Rs2)
		immed = getBin(immed)
		
		binInstr = rs2 + rs1 + Func + immed + Op

	intrs.append(binInstr)


geraHEX(intrs)

