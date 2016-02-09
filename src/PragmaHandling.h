#ifndef CDVMH_PRAGMA_HANDLING_H
#define CDVMH_PRAGMA_HANDLING_H

#include <dvm/pragmas.h>

#include <string>
#include <sstream>
#include <vector>

#pragma warning(push, 0)
#include <clang/Lex/Preprocessor.h>
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



struct PragmaHandlerStub {
    int line;
    std::set<std::string> dvmArrays;
    std::set<std::string> regArrays;
    std::set<std::string> scalars;
    std::vector<LoopVarDesc> loopVars;
    std::vector<ClauseReduction> reductions;
    std::set<std::string> privates;
    std::set<std::string> weirdRmas;
    bool isAcross;
};


class BlankPragmaHandler: public clang::PragmaHandler {
public:
    explicit BlankPragmaHandler(clang::CompilerInstance &aComp): PragmaHandler("dvm"), comp(aComp) {}
public:
    void HandlePragma(clang::Preprocessor &PP, clang::PragmaIntroducerKind Introducer, clang::Token &FirstToken);
public:
    PragmaHandlerStub *getPragmaAtLine(int line) {
        if (pragmas.find(line) != pragmas.end())
            return pragmas[line];
        else
            return 0;
    }
protected:
    clang::CompilerInstance &comp;
    std::map<int, PragmaHandlerStub *> pragmas;
};


#endif