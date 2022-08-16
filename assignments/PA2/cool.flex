/*
 *  The scanner definition for COOL.
 */

/*
 *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
 *  output, so headers and global definitions are placed here to be visible
 * to the code in the file.  Don't remove anything that was here initially
 */
%{
#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>

/* The compiler assumes these identifiers. */
#define yylval cool_yylval
#define yylex  cool_yylex

/* Max size of string constants */
#define MAX_STR_CONST 1025
#define YY_NO_UNPUT   /* keep g++ happy */

extern FILE *fin; /* we read from this file */

/* define YY_INPUT so we read from the FILE fin:
 * This change makes it possible to use this scanner in
 * the Cool compiler.
 */
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
	if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
		YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STR_CONST]; /* to assemble string constants */
char *string_buf_ptr;

extern int curr_lineno;
extern int verbose_flag;

extern YYSTYPE cool_yylval;

/*
 *  Add Your own definitions here
 */

%}



/*
 * Define names for regular expressions here.
 */

DARROW          =>
%Start COMMENT STRING



%%

"{" { return '{';}
"}" { return '}';}
"(" { return '(';}
")" { return ')';}
"." { return '.';}
":" { return ':';}
"," { return ',';}
";" { return ';';}
"+" { return '+';}
"-" { return '-';}
"*" { return '*';}
"/" { return '/';}
"=" { return '=';}
"<" { return '<';}
"<-" { return ASSIGN;}

 /*
  * single-line comment
  */

--.* {
  cout << "sing" << endl;
}

 /*
  * start of multiple-line comment
  */

"(*" {
  BEGIN COMMENT;
}

<COMMENT>.*"*)"$ {
  // end of comment;
  BEGIN 0;
}

<COMMENT><<EOF>> {
  BEGIN 0;
  cool_yylval.error_msg = "EOF in comment";
  return ERROR;
}

<COMMENT>.* {
  // skip any character in comment， don't tokenize
}

"*)" {
  cool_yylval.error_msg = "Unmatched *)";
  return ERROR;
}

 /*
  * end of multiple-line comment
  */

true {
  cool_yylval.boolean = 1;
  return BOOL_CONST;
}

false {
  cool_yylval.boolean = 0;
  return BOOL_CONST;
}


[ \t\f\r\v]* {}
  /*
   * start of string
   */


\"[^"(\n)]*\" {
  // match string
  if(yyleng >= 100){
    cool_yylval.error_msg = "String constant too long";
    return ERROR; 
  }
  yytext[yyleng -1] = 0;
  ++yytext;

  int leng = yyleng - 2;
  char p_yytext[leng];
  int flag = 0;
  int newLeng = 0;
  for(int i =0; i<leng; ++i){
    char c = yytext[i];
    if(flag){
      flag = 0;
      if(c == 'b'){
        p_yytext[newLeng] = '\b';
      } else if(c == 't'){
        p_yytext[newLeng] = '\t'; 
      } else if(c == 'n'){
        p_yytext[newLeng] = '\n'; 
      } else if(c == 'f'){
        p_yytext[newLeng] = '\f';
      } else if(c == '\\'){
        p_yytext[newLeng] = '\\';
      } else {
        p_yytext[newLeng] = c;
      }
      ++newLeng;
      continue;
    }
    if(c == '\\') {
      flag = 1;
      continue;
    }
    
    p_yytext[newLeng] = c;
    ++newLeng;
  }
  p_yytext[newLeng] = '\0';
  cout << p_yytext << endl;
  cool_yylval.symbol = stringtable.add_string(p_yytext, newLeng);
  return STR_CONST;  
}

\"[^"(\n)]*(EOF) {
  cool_yylval.error_msg = "EOF in string constant";
  return ERROR;
}


\"[^"(\n)]*(\n) {
  //match no close-quote string
  ++curr_lineno;
  cool_yylval.error_msg = "Unterminated string constant";
  return ERROR;
}

(\n) {
  ++curr_lineno;
}

 /*
  *  Keywords
  */

class {return CLASS;}
else { return ELSE; }
fi { return FI; }
if { return IF; }
in { return IN; }
inherits { return INHERITS; }
let { return LET; }
loop {return LOOP;}
pool {return POOL;}
then {return THEN;}
while {return WHILE;}
case {return CASE;}
esac {return ESAC;}
of {return OF;}
new {return NEW;}
isvoid {return ISVOID;}
not {return NOT;}





[0-9][0-9]* {
  cool_yylval.symbol = inttable.add_string(yytext);
  return INT_CONST;
}

[A-Z][a-zA-Z_]* {
  cool_yylval.symbol = idtable.add_string(yytext);
  return TYPEID;
}

[a-z][a-zA-Z_]* {
  cool_yylval.symbol = idtable.add_string(yytext);
  return OBJECTID;
}

. {
  // Add a “catch-all” rule that matches any character and reports an error.
  cool_yylval.error_msg = yytext;
  return ERROR;
}


 /*
  *  The multiple-character operators.
  */

 /*
  * Keywords are case-insensitive except for the values true and false,
  * which must begin with a lower-case letter.
  */


 /*
  *  String constants (C syntax)
  *  Escape sequence \c is accepted for all characters c. Except for 
  *  \n \t \b \f, the result is c.
  *
  */


%%