/* ------------------------------------------------------ *
 * Made by Sergey Kulikov                                 *
 * clang source-to-source transformations example          *
 * #pragma handling                                       *
 * 2014                                                   *
 * ------------------------------------------------------ */

#include <PragmaHandling.h>

#include <string>
#include <sstream>
#include <vector>
#pragma warning(push, 0) 
#include <clang/Lex/Lexer.h>
#include <clang/Driver/Options.h>
#include <clang/AST/AST.h>
#include <clang/AST/ASTContext.h>
#include <clang/AST/ASTConsumer.h>
#include <clang/AST/RecursiveASTVisitor.h>
#include <clang/Frontend/ASTConsumers.h>
#include <clang/Frontend/FrontendActions.h>
#include <clang/Frontend/CompilerInstance.h>
#include <clang/Tooling/CommonOptionsParser.h>
#include <clang/Tooling/Tooling.h>
#include <clang/Rewrite/Core/Rewriter.h>
#include <clang/Lex/Pragma.h>
#pragma warning(pop)

using namespace std;
using namespace clang;
using namespace clang::driver;
using namespace clang::tooling;
using namespace llvm;

void BlankPragmaHandler::HandlePragma(Preprocessor &PP, PragmaIntroducerKind Introducer, Token &FirstToken) {
    SourceLocation loc = FirstToken.getLocation();
    loc = comp.getSourceManager().getFileLoc(loc);
    FileID fileID = comp.getSourceManager().getFileID(loc);
    int line = comp.getSourceManager().getLineNumber(fileID, comp.getSourceManager().getFileOffset(loc));
    Token &Tok = FirstToken;
    PP.LexNonComment(Tok);
#define msg "Handler stub directive syntax error"
    std::string tokStr = Tok.getIdentifierInfo()->getName();
    PragmaHandlerStub *curPragma = new PragmaHandlerStub;
    curPragma->line = line;
    curPragma->isAcross = false; //note: tell Pritula dvm src are incorrect
    PP.LexNonComment(Tok);
    while (Tok.isAnyIdentifier()) {
        std::string clauseName = Tok.getIdentifierInfo()->getName();
        PP.LexNonComment(Tok);
        PP.LexNonComment(Tok);
        if (clauseName == "dvm_array") {
            while (Tok.isAnyIdentifier()) {
                tokStr = Tok.getIdentifierInfo()->getName();
                curPragma->dvmArrays.insert(tokStr);
                PP.LexNonComment(Tok);
                if (Tok.is(tok::comma)) {
                    PP.LexNonComment(Tok);
                }
            }
        } else if (clauseName == "regular_array") {
            while (Tok.isAnyIdentifier()) {
                tokStr = Tok.getIdentifierInfo()->getName();
                curPragma->regArrays.insert(tokStr);
                PP.LexNonComment(Tok);
                if (Tok.is(tok::comma)) {
                    PP.LexNonComment(Tok);
                }
            }
        } else if (clauseName == "scalar") {
            while (Tok.isAnyIdentifier()) {
                tokStr = Tok.getIdentifierInfo()->getName();
                curPragma->scalars.insert(tokStr);
                PP.LexNonComment(Tok);
                if (Tok.is(tok::comma)) {
                    PP.LexNonComment(Tok);
                }
            }
        } else if (clauseName == "loop_var") {
            while (Tok.isAnyIdentifier()) {
                LoopVarDesc loopVar;
                tokStr = Tok.getIdentifierInfo()->getName();
                loopVar.name = tokStr;
                PP.LexNonComment(Tok);
                PP.LexNonComment(Tok);
                tokStr = PP.getSpelling(Tok);
                loopVar.stepSign = atoi(tokStr.c_str());
                PP.LexNonComment(Tok);
                PP.LexNonComment(Tok);
                if (Tok.isNot(tok::r_paren)) {
                    tokStr = PP.getSpelling(Tok);
                    loopVar.constStep = tokStr;
                    PP.LexNonComment(Tok);
                }
                curPragma->loopVars.push_back(loopVar);
                PP.LexNonComment(Tok);
                if (Tok.is(tok::comma)) {
                    PP.LexNonComment(Tok); //note: tell Pritula dvm src are incorrect
                }
            }
        } else if (clauseName == "reduction") {
            while (Tok.isAnyIdentifier()) {
                ClauseReduction red;
                tokStr = Tok.getIdentifierInfo()->getName();
                red.redType = ClauseReduction::guessRedType(tokStr);
                PP.LexNonComment(Tok);
                PP.LexNonComment(Tok);
                red.arrayName = Tok.getIdentifierInfo()->getName();
                PP.LexNonComment(Tok);
                if (red.isLoc()) {
                    PP.LexNonComment(Tok);
                    red.locName = Tok.getIdentifierInfo()->getName();
                    PP.LexNonComment(Tok);
                    PP.LexNonComment(Tok);
                    tokStr = PP.getSpelling(Tok);
                    red.locSize.strExpr = tokStr;
                    PP.LexNonComment(Tok);
                }
                curPragma->reductions.push_back(red);
                PP.LexNonComment(Tok);
                if (Tok.is(tok::comma)) {
                    PP.LexNonComment(Tok);
                }
            }
        } else if (clauseName == "private") {
            while (Tok.isAnyIdentifier()) {
                tokStr = Tok.getIdentifierInfo()->getName();
                curPragma->privates.insert(tokStr);
                PP.LexNonComment(Tok);
                if (Tok.is(tok::comma)) {
                    PP.LexNonComment(Tok);
                }
            }
        } else if (clauseName == "weird_rma") {
            while (Tok.isAnyIdentifier()) {
                tokStr = Tok.getIdentifierInfo()->getName();
                curPragma->weirdRmas.insert(tokStr);
                PP.LexNonComment(Tok);
                if (Tok.is(tok::comma)) {
                    PP.LexNonComment(Tok);
                }
            }
        } else if (clauseName == "across") {
            curPragma->isAcross = true;
        } else if (clauseName == "remote_access") {
            int depth = 1;
            while (Tok.isNot(tok::r_paren) || depth > 1) {
                if (Tok.is(tok::l_paren))
                    depth++;
                if (Tok.is(tok::r_paren))
                    depth--;
                PP.LexNonComment(Tok);
            }
        } else {
        }
        PP.LexNonComment(Tok);
        if (Tok.is(tok::comma))
            PP.LexNonComment(Tok);
    }
    pragmas[line] = curPragma;
#undef msg
}