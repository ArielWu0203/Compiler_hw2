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
%token QUOTA

/* Comment */

/* Variable ID & others */
%token SEMICOLON

/* precedence */
%left EQ NE LT LTE MT MTE
%left ADD SUB
%left MUL DIV MOD
%left INC DEC
%left LB RB

/* Token with return, which need to sepcify type */

%token <i_val> I_CONST
%token <f_val> F_CONST
%token <string> VOID INT FLOAT BOOL STRING ID STR_CONST

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
    : print_func
    | statement
;

declaration
    : type ID SEMICOLON
    | type ID ASGN initializer SEMICOLON
;

statement
    : if_stat
    | compound_stat
    | assign_stat
    | declaration
;

if_stat
    : IF LB operator_stat RB statement
    | IF LB operator_stat RB compound_stat ELSE statement
;

compound_stat
    : LCB RCB
    | LCB stat_list RCB
;

stat_list
    : statement
    | stat_list statement
;

assign_stat
    : ID assign_operator operator_stat SEMICOLON
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
    : operator_stat ADD operator_stat
    | operator_stat SUB operator_stat
    | operator_stat MUL operator_stat
    | operator_stat DIV operator_stat
    | operator_stat MOD operator_stat
    | operator_stat MT operator_stat  
    | operator_stat LT operator_stat
    | operator_stat MTE operator_stat
    | operator_stat LTE operator_stat
    | operator_stat EQ operator_stat
    | operator_stat NE operator_stat
    | ID INC
    | ID DEC
    | INC ID
    | DEC ID
    | ADD operator_stat
    | SUB operator_stat
    | term
    | LB operator_stat RB
;

print_func
    : PRINT LB ID RB SEMICOLON
    | PRINT LB STR_CONST RB SEMICOLON
;

term
    : F_CONST
    | I_CONST
    | STR_CONST
    | TRUE
    | FALSE
    | ID
;

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
