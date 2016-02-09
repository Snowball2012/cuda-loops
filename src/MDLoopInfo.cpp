//
// Created by snowball on 03.04.15.
//

#include <MDLoopInfo.h>

#pragma warning(push, 0) 
#include <clang/AST/RecursiveASTVisitor.h>
#include <map>
#include <set>
#include <vector>
#include <iostream>
#pragma warning(pop)

#include <PragmaHandling.h>

using namespace std;
using namespace clang;


void MDLoopInfo::FillInfo(FunctionDecl * f)
{
    std::cerr << "** Declarations of the function \"" << f->getNameAsString() <<"\":" << std::endl;
    TraverseFunctionDecl(f);
    std::cerr << "****" << std::endl << std::endl;
}

bool MDLoopInfo::VisitDecl(clang::Decl * d)
{
    if (llvm::isa<clang::VarDecl>(d)) {
        clang::VarDecl * vd = static_cast<clang::VarDecl *>(d);
        std::string name = vd->getNameAsString();
        clang::QualType type = vd->getType();
        if (type->isPointerType()) {
            if (type->getPointeeType()->isArrayType()) {
                clang::QualType e = type->getPointeeType()->getAsArrayTypeUnsafe()->getElementType();
                while (e->isArrayType()) {
                    e = e->getAsArrayTypeUnsafe()->getElementType();
                }
                std::cerr << "Found a " ;
                if (pragma.dvmArrays.find(name) != pragma.dvmArrays.end()) {
                    dvmArrays[name] = e;
                    std::cerr << "distributed ";
                } else if (pragma.regArrays.find(name) != pragma.regArrays.end()){
                    regArrays[name] = e;
                    std::cerr << "regular ";
                } else {
                    std::cerr << "strange array with name: " << name << " Type: " << e.getAsString() << std::endl;
                }
                std::cerr << "array with name: " << name << " of type: " << e.getAsString() << std::endl;
            }
        } else {
            std::cerr << "Found a ";
            if (pragma.scalars.find(name) != pragma.scalars.end()) {
                std::cerr << "scalar ";
                scalars[name] = type;
            } else if (pragma.privates.find(name) != pragma.privates.end()) {
                std::cerr << "private ";
                privates[name] = type;
            } else {
                //if we are here, this is loop variable or reduction.
                bool red_var = false;
                for (auto it = pragma.reductions.begin(), end = pragma.reductions.end(); it != end; ++it) {
                    if ((*it).arrayName == name) {
                        std::cerr << "reduction ";
                        reductions.push_back(std::make_tuple(*it, type));
                        red_var = true;
                        break;
                    }
                }
                if (!red_var)
                    std::cerr << "loop ";
            }
            std::cerr << "variable with name: " << name << " of type: " << type.getAsString() << std::endl;
        }
    }
    return true;
}