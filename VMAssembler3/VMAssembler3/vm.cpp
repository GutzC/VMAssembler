//  g++ vm.cpp -o vm -std=c++11 -static-libgcc -fpermissive
#include <cstdlib>
#include <iostream>
#include <sstream>
#include <fstream>
#include <climits>
#include <set>
#include <map>
#include <stdexcept>

using namespace std;

const size_t MEM_SIZE = 100001;
const size_t INSTR_SIZE = 3;

inline bool isInteger(const std::string & s){
	if (s.empty()) return false;

	char * p;
	strtol(s.c_str(), &p, 10);

	return (*p == 0);
}

int main(int argc, char *argv[]){
	fstream f;
	size_t counter = 0;
	int x = 0;
	char* mem[MEM_SIZE]; // Memory for assembly
	int reg[14]; // Common purpose registers
	int* pc = &reg[8]; // reg[8] is reserved for program counter
	int* a = &x;
	char* b;
	int offset = 0;
	int temp = 0;
	struct Instr{ int opcode; int opd1; int opd2; };
	Instr instruction;
	Instr* pi = &instruction;
	map<string, int> symbolTable;
	set<string> op{ "JMP", "JMR", "BNZ", "BGT", "BLT", "BRZ", "MOV",
		"LDA", "STR", "LDR", "STB", "LDB", "ADD", "ADI", "SUB", "MUL",
		"DIV", "AND", "OR", "CMP", "TRP" };

	set<string> d{ ".INT", ".BYT", ".ALN" };
	string element;
	const bool is_in = op.find(element) != op.end();

	// Registers
	map<string, int> r;
	r.insert(pair<string, int>("R0", 0));
	r.insert(pair<string, int>("R1", 1));
	r.insert(pair<string, int>("R2", 2));
	r.insert(pair<string, int>("R3", 3));
	r.insert(pair<string, int>("R4", 4));
	r.insert(pair<string, int>("R5", 5));
	r.insert(pair<string, int>("R6", 6));
	r.insert(pair<string, int>("R7", 7));
	r.insert(pair<string, int>("R8", 8)); // PC
	r.insert(pair<string, int>("SL", 9));
	r.insert(pair<string, int>("SP", 10));
	r.insert(pair<string, int>("FP", 11));
	r.insert(pair<string, int>("SB", 12));
	r.insert(pair<string, int>("PFP", 13));

	// Opcodes
	map<string, int> opcodes;
	opcodes.insert(pair<string, int>("JMP", 1));
	opcodes.insert(pair<string, int>("JMR", 2));
	opcodes.insert(pair<string, int>("BNZ", 3));
	opcodes.insert(pair<string, int>("BLT", 5));
	opcodes.insert(pair<string, int>("BRZ", 6));
	opcodes.insert(pair<string, int>("MOV", 7));
	opcodes.insert(pair<string, int>("LDA", 8));
	opcodes.insert(pair<string, int>("STR", 9));
	opcodes.insert(pair<string, int>("LDR", 10));
	opcodes.insert(pair<string, int>("STB", 11));
	opcodes.insert(pair<string, int>("LDB", 12));
	opcodes.insert(pair<string, int>("ADD", 13));
	opcodes.insert(pair<string, int>("ADI", 14));
	opcodes.insert(pair<string, int>("SUB", 15));
	opcodes.insert(pair<string, int>("MUL", 16));
	opcodes.insert(pair<string, int>("DIV", 17));
	opcodes.insert(pair<string, int>("CMP", 20));
	opcodes.insert(pair<string, int>("TRP", 0));

	// START PASS ONE
	bool passOne = true;
	*pc = 0;

	if (passOne){
		// Obtain the name of an assembly file to read from the command line (argv[1]). Print an error message and halt
		//the program if there is no command-line argument provided. */

	PASS:	try{
		if (argc != 2){
			throw runtime_error("No file provided.");
		}
		// Open file
		f.open(argv[1]);

		if (!f){
			throw runtime_error("Failed to open file");
		}
	}
			catch (runtime_error& e){
				//cout << e.what() << "\n";
				//cin.get();
				return 0;
			}

			// Read and store labels
			string line;
			string label;
			string labelValue;
			string size;
			int opc;
			int opd1;
			int opd2;
			//bool race = false;		
			int counting = 0;
		START:		while (getline(f, line)){
			stringstream ssLine(line);
			ssLine >> element;
			//if (element == "TRP") race = true;
			// Check if first word in line is a label
			// if (op.find(element) != op.end()) is true, it means the element was found
			// and find returned a different iter than end()
			try{
				// Using FSM to check syntax and create symbol table
				int curState = 1;
				while (curState != 9){
					switch (curState){
					case 1:
						if (r.find(element) != r.end()){
							curState = 8;
						}
						else if (isInteger(element)){
							curState = 8;
						}
						else if (op.find(element) != op.end()){
							if (!passOne){
								opc = opcodes[element];
								if (opc == 0){
									curState = 14;
									break;
								}
								// JMP
								else if (opc == 1 || opc == 2){
									curState = 15;
									break;
								}
								// MOV
								else if (opc == 7){
									curState = 5;
									break;
								}
								// BNZ, BGT, BLT, BRZ, LDA
								else if (opc == 3 || opc == 4 || opc == 5 || opc == 6 || opc == 8){
									curState = 16;
									break;
								}
								// STR, LDR, STB, LDB
								else if (opc == 9 || opc == 10 || opc == 11 || opc == 12){
									curState = 18;
									break;
								}
								// ADD, ADI, SUB, MUL, DIV
								else if (opc == 13 || opc == 14 || opc == 15 || opc == 16 || opc == 17){
									curState = 5;
									break;
								}
								// CMP
								else if (opc == 20){
									curState = 5;
									break;
								}
							}
							else if (element == "JMP"){
								curState = 6;
							}
							else{
								curState = 5;
							}
						}
						else if (d.find(element) != d.end()){
							if (element == ".ALN"){
								curState = 9;
							}
							else{
								// Store if it is an INT or BYT to add to mem[]
								// if valid line
								size = element;
								curState = 3;
							}
						}
						// Handle lines that are only comments
						else if (element == ";"){
							goto START;
						}
						else
						{
							// Check if symbol already exists
							if (symbolTable.find(element) != symbolTable.end()){
								if (!passOne){
									curState = 2;
								}
								else{
									throw runtime_error("Duplicate label.");
								}
							}
							else{
								// Copy label name and keep checking that it is valid
								// before actually adding to symbol table
								label = element;
								curState = 2;
							}
						}
						break;
					case 2:
						if (d.find(element) != d.end()){
							if (element == ".ALN"){
								curState = 8;
							}
							else{
								// Store if it is an INT or BYT to add to mem[]
								// if valid line
								size = element;
								curState = 3;
							}
						}
						else if (op.find(element) != op.end()){
							if (!passOne){
								opc = opcodes[element];
								if (opc == 0){
									curState = 14;
									break;
								}
							}
							curState = 10;
						}
						else{
							curState = 8;
						}
						break;
					case 3:
						// Make sure element is an integer and store value
						// for adding into memory if valid
						if (isInteger(element)){
							labelValue = element;
							curState = 4;
						}
						else{
							curState = 8;
						}
						break;
					case 4:
						if (passOne){
							if (size == ".INT"){
								a = reinterpret_cast<int*>(&mem[counter]);
								*a = atoi(labelValue.c_str());
								symbolTable.insert(pair<string, int>(label, counter));
								counter++;
							}
							else if (size == ".BYT"){
								b = reinterpret_cast<char*>(&mem[counter]);
								*b = atoi(labelValue.c_str());
								symbolTable.insert(pair<string, int>(label, counter));
								counter++;
							}
						}
						curState = 9;
						break;
					case 5:
						if (r.find(element) != r.end()){
							if (!passOne){
								opd1 = r[element];
							}
							curState = 6;
						}
						else if (isInteger(element)){
							if (!passOne){
								if (opc == opcodes["TRP"]){
									opd1 = atoi(element.c_str());
								}
								// Store integer in op1 for add immediate
								if (opc == opcodes["ADI"]){
									// not sure on this
								}
							}
							curState = 6;
						}
						else if (symbolTable.find(element) != symbolTable.end()){
							if (!passOne){
								// Get value from memory from symbol table for opd1
								a = reinterpret_cast<int*>(&mem[symbolTable[element]]);
								opd1 = *a;
							}
							curState = 6;
						}
						else if (d.find(element) != d.end()){
							curState = 8;
						}
						else if (op.find(element) != op.end()){
							curState = 8;
						}
						else
							curState = 8;
						break;
					case 6:
						if (r.find(element) != r.end()){
							if (!passOne){
								opd2 = r[element];
							}
							curState = 7;
						}
						else if (isInteger(element)){
							if (!passOne){
								// Store integer in op2 for immediate addressing mode
								opd2 = atoi(element.c_str());
							}
							curState = 7;
						}
						else if (symbolTable.find(element) != symbolTable.end()){
							if (!passOne){
								// Get value from memory from symbol table for opd2
								a = reinterpret_cast<int*>(&mem[symbolTable[element]]);
								opd2 = *a;
							}
							curState = 7;
						}
						else if (d.find(element) != d.end()){
							curState = 8;
						}
						else if (op.find(element) != op.end()){
							curState = 8;
						}
						else{
							counter += INSTR_SIZE;
							curState = 9;
						}
						break;
					case 7:
						if (!passOne){
							instruction.opcode = opc;
							instruction.opd1 = opd1;
							instruction.opd2 = opd2;
							//pi = &instruction;
							pi = reinterpret_cast<Instr*>(&mem[counter + offset]);
							*pi = instruction;
						}
						counter += INSTR_SIZE;
						curState = 9;
						break;
					case 8:
						throw runtime_error("Invalid assembly format.");
						break;
					case 9:
						while (!ssLine.eof()){
							ssLine >> element;
						}
						break;
					case 10:
						if (r.find(element) != r.end()){
							if (!passOne){
								opd1 = r[element];
							}
							curState = 11;
						}
						else if (isInteger(element)){
							if (!passOne){
								// Store integer in op1 for add immediate
							}
							curState = 11;
						}
						else if (symbolTable.find(element) != symbolTable.end()){
							if (!passOne){
								// Get value from memory from symbol table for opd1
								a = reinterpret_cast<int*>(&mem[symbolTable[element]]);
								opd1 = *a;
							}
							curState = 11;
						}
						else if (op.find(element) != op.end()){
							curState = 8;
						}
						else if (d.find(element) != d.end()){
							curState = 8;
						}
						else{
							curState = 8;
						}
						break;
					case 11:
						if (r.find(element) != r.end()){
							if (!passOne){
								opd2 = r[element];
							}
							curState = 12;
						}
						else if (isInteger(element)){
							if (!passOne){
								// Store integer in op2 for immediate addressing mode
							}
							curState = 12;
						}
						else if (symbolTable.find(element) != symbolTable.end()){
							if (!passOne){
								// Get value from memory from symbol table for opd2
								a = reinterpret_cast<int*>(&mem[symbolTable[element]]);
								opd2 = *a;
							}
							curState = 12;
						}
						else if (op.find(element) != op.end()){
							curState = 8;
						}
						else if (d.find(element) != d.end()){
							curState = 8;
						}
						else{
							symbolTable.insert(pair<string, int>(label, counter));
							counter += INSTR_SIZE;
							curState = 9;
						}
						break;
					case 12:
						if (passOne){
							symbolTable.insert(pair<string, int>(label, counter));
						}
						else{
							// PASS TWO							
							instruction.opcode = opc;
							instruction.opd1 = opd1;
							instruction.opd2 = opd2;
							//pi = &instruction;
							pi = reinterpret_cast<Instr*>(&mem[counter + offset]);
							*pi = instruction;
						}
						curState = 9;
						counter += INSTR_SIZE;
						break;
					case 14:
						if (isInteger(element)){
							opd1 = atoi(element.c_str());
							curState = 12;
						}
						else
							curState = 8;
						break;
					case 15:
						// Handle JMP on Pass 2
						if (symbolTable.find(element) != symbolTable.end()){
							opd1 = symbolTable[element];
							curState = 7;
						}
						// Handle JMR on Pass 2
						else if (r.find(element) != r.end()){
							opd1 = r[element];
							curState = 7;
						}
						// If opd1 isn't a label or register, throw exception
						else
							curState = 8;
						break;
					case 16:
						// Handle opd1 for opcodes BNZ, BGT, BLT, BRZ, LDA
						if (r.find(element) != r.end()){
							opd1 = r[element];
							curState = 17;
						}
						else
							curState = 8;
						break;
					case 17:
						// Make sure opd2 is a label and store address pointed to in opd2 (BNZ, BGT, BLT, BRZ, LDA)
						if (symbolTable.find(element) != symbolTable.end()){
							opd2 = symbolTable[element];
							curState = 7;
						}
						else{
							curState = 8;
						}
						break;
					case 18:
						// Handle opd1 for opcodes STR, LDR, STB, LDB
						if (r.find(element) != r.end()){
							opd1 = r[element];
							curState = 19;
						}
						else
							curState = 8;
						break;
					case 19:
						// Handle opd2 for opcodes STR, LDR, STB, LDB: direct or indirect addressing
						// Update opc to for direct or indirect
						// direct: opd2 is a label, store value from 
						if (symbolTable.find(element) != symbolTable.end()){
							if (opc == 10 || opc == 12){
								a = reinterpret_cast<int*>(&mem[symbolTable[element]]);
								opd2 = *a;
							}
							else if (opc == 9 || opc == 11){
								opd2 = symbolTable[element];
							}
							curState = 7;
						}
						// indirect: opd2 is a register
						else if (r.find(element) != r.end()){
							opd2 = r[element];
							// Update opcode for indirect addressing mode
							if (opc == 9){
								// STR indirect
								opc = 21;
							}
							else if (opc == 10){
								// LDR indirect
								opc = 22;
							}
							else if (opc == 11){
								// STB indirect
								opc = 23;
							}
							else if (opc == 12){
								// LDB indirect
								opc = 24;
							}
							curState = 7;
						}
						else{
							curState = 8;
						}
						break;
					default:
						throw runtime_error("Invalid assembly format.");
					}
					if (element == ";"){
						while (!ssLine.eof()){
							ssLine >> element;
						}
					}
					// Get next string and continue FSM
					ssLine >> element;
				}
			}
			catch (runtime_error& e){
				//cout << e.what() << " at pc: " << *pc << "\n";
				//cout << element << "\n";
				//cin.get();
				return 0;
			}
			(*pc)++;
		}
					// Pass one successful, update data and prepare for pass two
					if (passOne){
						*pc = 0;
						counter = 0;
						offset = symbolTable["START"];
						passOne = false;
						f.close();
						goto PASS;
					}
	}
	// RUN ASSEMBLER
	bool running = true;
	bool end = false;
	char c = NULL;
	int i = 0;
	int operand = 0;
	*pc = symbolTable["START"];
	while (running){
		pi = reinterpret_cast<Instr*>(&mem[*pc]);
		operand = static_cast<int>(pi->opcode);
		switch (operand){
		case 0: // TRP
			switch (pi->opd1){
			case 0:
				end = true;
				break;
			case 1:
				cout << reg[0];
				break;
			case 2:
				cin >> i;
				break;
			case 3:
				c = static_cast<char>(reg[0]);
				cout << c;
				break;
			case 4:				
				reg[0] = getc(stdin);
				break;
			}
			break;
		case 1: // JMP
			*pc = pi->opd1 - INSTR_SIZE;
			break;
		case 2: // JMR
			*pc = reg[pi->opd1] - INSTR_SIZE;
			break;
		case 3: // BNZ
			if (reg[pi->opd1] != 0){
				*pc = pi->opd2 - INSTR_SIZE;
			}
			break;
		case 4: // BGT
			if (reg[pi->opd1] > 0){
				*pc = pi->opd2 + symbolTable["START"] - INSTR_SIZE;
			}
			break;
		case 5: // BLT
			if (reg[pi->opd1] < 0){
				*pc = pi->opd2 + symbolTable["START"] - INSTR_SIZE;
			}
			break;
		case 6: // BRZ
			if (reg[pi->opd1] == 0){
				*pc = pi->opd2 - INSTR_SIZE;
			}
			break;
		case 7: // MOV
			reg[pi->opd1] = reg[pi->opd2];
			break;
		case 8: // LDA
			// Indirect load. Go to address in opd2 and load value from there into register in opd1.
			reg[pi->opd1] = pi->opd2;
			break;
		case 9: // STR
			a = reinterpret_cast<int*>(&mem[pi->opd2]);
			*a = reg[pi->opd1];
			break;
		case 10: // LDR (direct)
			// Move value from register(label in opd2) to register(opd1)
			// opd2 is a label, use direct addressing
			reg[pi->opd1] = pi->opd2;
			break;
		case 11: // STB
			// Move byte value from reg[opd1] to mem[opd2]
			/*a = reinterpret_cast<int*>(&mem[pi->opd2]);
			*a = atoi(reinterpret_cast<char*>(reg[pi->opd1]));*/
			//*mem[pi->opd2]
			break;
		case 12: // LDB
			// Move byte value from memory(label in opd2) to register(opd1)
			reg[pi->opd1] = static_cast<char>(pi->opd2);
			break;
		case 13: // ADD
			reg[pi->opd1] += reg[pi->opd2];
			break;
		case 14: // ADI
			reg[pi->opd1] += pi->opd2;
			break;
		case 15: // SUB
			reg[pi->opd1] -= reg[pi->opd2];
			break;
		case 16: // MUL
			reg[pi->opd1] *= reg[pi->opd2];
			break;
		case 17: // DIV
			reg[pi->opd1] /= reg[pi->opd2];
			break;
		case 20: // CMP
			if (reg[pi->opd1] == reg[pi->opd2]){
				reg[pi->opd1] = 0;
			}
			else if (reg[pi->opd1] < reg[pi->opd2]){
				reg[pi->opd1] = -1;
			}
			else{
				reg[pi->opd1] = 1;
			}
			break;
		case 21: // STR (register indirect)
			// Move byte value from register location, opd1, to memory location in reg[opd2]
			// Move byte value from reg[opd1] to mem[reg[opd2]]
			//temp = reg[pi->opd2];
			a = reinterpret_cast<int*>(&mem[reg[pi->opd2]]);
			*a = reg[pi->opd1];
			break;
			//*a = atoi(reinterpret_cast<char*>(reg[pi->opd1]));
		case 22: // LDR (indirect)
			// Move value from memory location in reg[opd2] to opd1
			reg[pi->opd1] = reinterpret_cast<int>(mem[reg[pi->opd2]]);
			break;
		case 23: // STB (indirect)
			// Move byte value from register location, opd1, to memory location in to reg[opd2]
			// Move byte value from reg[opd1] to mem[reg[opd2]]
			// Storing into an address that has been cast as an int*
			a = reinterpret_cast<int*>(&mem[(reg[pi->opd2])]);
			*a = reg[pi->opd1];
			break;
		case 24: // LDB (indirect)
			// Move byte value from memory location in reg[opd2] to opd1
			reg[pi->opd1] = reinterpret_cast<char>(mem[reg[pi->opd2]]);
			break;
		default:
			break;
		}
		if (end == true)
			break;
		else
			(*pc) += INSTR_SIZE;
	}
	cin.get();
}