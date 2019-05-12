/*	Definition section */
%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
extern int yylineno;
extern int yylex();
extern void yyerror(char *s);
extern char* yytext;   // Get current token from lex
extern char buf[256];  // Get current code line from lex

/* Symbol table function - you can add new function if needed. */
int lookup_symbol();
void insert_symbol(int index,char *name,char *kind,char *type,int scope_level);
void create_symbol();
void dump_symbol();

typedef struct symble_entry{
    int index;
    char name[50];
    char kind[15];
    char type[10];
    int scope_level;
    char attr[500];
    struct symbol_entry *next;
} Entry;

Entry *front,*rear;

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
    : statement
;

declaration
    : type ID SEMICOLON
    | type ID ASGN initializer SEMICOLON
;

statement
    : if_stat
    | while_stat
    | compound_stat
    | function_stat
    | assign_stat
    | declaration
    | return_stat
    | print_func
;

if_stat
    : IF LB operator_stat RB statement
    | IF LB operator_stat RB compound_stat ELSE statement
;

while_stat
    : WHILE LB operator_stat RB compound_stat
;

function_stat
    : type ID LB declaration_list RB SEMICOLON
    | type ID LB declaration_list RB compound_stat
    | type ID LB RB SEMICOLON
    | type ID LB RB compound_stat
;

return_stat
    : RET SEMICOLON
    | RET operator_stat SEMICOLON
    | RET ID assign_operator operator_stat SEMICOLON
;
    
declaration_list
    : func_declaration
    | declaration_list COMMA func_declaration
;

func_declaration
    : type ID
    | type ID ASGN initializer
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
    | ID INC SEMICOLON
    | ID DEC SEMICOLON
    | INC ID SEMICOLON
    | DEC ID SEMICOLON

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

    create_symbol();
    //char x[10] = "abc";
    //insert_symbol(0,x,x,x,0);
    //insert_symbol(1,"b","func","void",0);
	//insert_symbol(2,"c","func","void",1);
    //printf("%d %s\n",rear->index,rear->name);
    //printf("%d %s\n",front->index,front->name);
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

void create_symbol() {
    front = rear = NULL;
}
void insert_symbol(int index,char *name,char *kind,char *type,int scope_level) {

    printf("%s\n",name);
    //Entry *new;
    //new = (Entry*) malloc(sizeof(Entry));
    //new->index = index;
    //strcpy(new->name,name);
    //strcpy(new->kind,kind);
    //strcpy(new->type,type);
    //new->scope_level=scope_level;
    //if(front == NULL) {
    //    front = new;
    //}
    //new->next=NULL;
    //rear = new;

}
int lookup_symbol() {}
void dump_symbol() {
    printf("\n%-10s%-10s%-12s%-10s%-10s%-10s\n\n",
           "Index", "Name", "Kind", "Type", "Scope", "Attribute");
}
