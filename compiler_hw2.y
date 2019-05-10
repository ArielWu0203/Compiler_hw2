/*	Definition section */
%{

#include <stdio.h>
#include <stdlib.h>

extern int yylineno;
extern int yylex();
extern void yyerror(char *s);
extern char* yytext;   // Get current token from lex
extern char buf[256];  // Get current code line from lex

/* Symbol table function - you can add new function if needed. */
int lookup_symbol();
void create_symbol();
void insert_symbol();
void dump_symbol();

%}

/* Use variable or self-defined structure to represent
 * nonterminal and token type
 */

%union {
    int i_val;
    double f_val;
    char* string;
}

/* Token without return */

/* Arithmetic */
%token ADD SUB MUL DIV MOD INC DEC

/* Relational */
%token MT LT MTE LTE EQ NE

/* Assignment */
%token ASGN ADDASGN SUBASGN MULASGN DIVASGN MODASGN

/* Logical */
%token AND OR NOT

/* Delimeters */
%token LB RB LCB RCB LSB RSB COMMA

/* Print Keywords*/
%token PRINT 

/* Condition and Loop Keywords */
%token IF ELSE FOR WHILE

/* boolean Keywords */
%token TRUE FALSE
%token RET CONT BREAK

/* String Constant */
%token STR_CONST QUOTA

/* Comment */

/* Variable ID & others */
%token SEMICOLON

/* precedence */
%left ADD SUB
%left MUL DIV MOD
%left INC DEC
%left LB RB

/* Token with return, which need to sepcify type */

%token <i_val> I_CONST
%token <f_val> F_CONST
%token <string> VOID INT FLOAT BOOL STRING ID

/* Nonterminal with return, which need to sepcify type */
/*
%type <f_val> stat
*/
%type <string> type

/* Yacc will start at this nonterminal */
%start program

/* Grammar section */
%%

program
    : stat
    | program stat
;

stat
    : declaration
    /*
    | compound_stat
    | expression_stat
    | print_func
    */
;

declaration
    : type ID SEMICOLON
    | type ID assign_operator initializer SEMICOLON
;

assign_operator
    : ASGN
    | ADDASGN
    | SUBASGN
    | MULASGN
    | DIVASGN
    | MODASGN
;

initializer
    : operator_stat
;

operator_stat
    : operator_stat MUL operator_stat
    | MUL term
    | operator_stat DIV operator_stat
    | DIV term
    | operator_stat MOD operator_stat
    | MOD term
    | operator_stat ADD operator_stat
    | ADD term
    | operator_stat SUB operator_stat
    | SUB term
    | ID INC
    | INC ID
    | ID DEC
    | DEC ID
    | term
    | LB operator_stat RB
;

term
    : F_CONST 
    | I_CONST
    | ID
;

/*unary_operator
    : INC
    | DEC
;

compare_operator
    : MT
    | LT
    | MTE
    | LTE
    | EQ
    | NE
;*/

/* actions can be taken when meet the token or rule */
type
    : INT
    | FLOAT
    | BOOL 
    | STRING 
    | VOID 
;


%%

/* C code section */
int main(int argc, char** argv)
{
    yylineno = 0;

    yyparse();
	printf("\nTotal lines: %d \n",yylineno);

    return 0;
}

void yyerror(char *s)
{
    printf("\n|-----------------------------------------------|\n");
    printf("| Error found in line %d: %s\n", yylineno, buf);
    printf("| %s", s);
    printf("\n|-----------------------------------------------|\n\n");
}

void create_symbol() {}
void insert_symbol() {}
int lookup_symbol() {}
void dump_symbol() {
    printf("\n%-10s%-10s%-12s%-10s%-10s%-10s\n\n",
           "Index", "Name", "Kind", "Type", "Scope", "Attribute");
}
