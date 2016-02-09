//
// Created by snowball on 03.04.15.
//

#pragma once

#pragma warning(push, 0)
#include <clang/AST/RecursiveASTVisitor.h>
#include <map>
#include <set>
#include <vector>
#include <PragmaHandling.h>
#pragma warning(pop)

class MDLoopInfo : public clang::RecursiveASTVisitor<MDLoopInfo> {
public:
    bool isAcross;
    std::map<std::string, clang::QualType> dvmArrays;
    std::map<std::string, clang::QualType> scalars;
    std::map<std::string, clang::QualType> privates;
    std::vector<LoopVarDesc> loopVars;
    std::map<std::string, clang::QualType> regArrays;
    std::vector<std::tuple<ClauseReduction, clang::QualType>> reductions;
    std::set<std::string> weirdRmas;


private:
    PragmaHandlerStub pragma;

    void FillInfo(clang::FunctionDecl * f);

public:

    MDLoopInfo(PragmaHandlerStub &pragma, clang::FunctionDecl *handler_entry)
    {
        this->pragma = pragma;
        this->loopVars = pragma.loopVars;
        this->FillInfo(handler_entry);
    }

    bool VisitDecl(clang::Decl * d);
};
