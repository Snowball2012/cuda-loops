/* ------------------------------------------------------ *
 * Made by Sergey Kulikov                                 *
 * clang-based tool to build CUDA-handlers for loops      *
 * with dependencies                                      *
 * 2015                                                   *
 * ------------------------------------------------------ */
#include <PragmaHandling.h>
#include <MDLoopInfo.h>
#include <handler-gen/NoAcrossGen.h>
#include <handler-gen/AcrossGen.h>

#pragma warning(push, 0) 

#include <iostream>
#include <string>
#include <sstream>
#include <vector>
#include <algorithm>
#include <tuple>
#include <memory>

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

#pragma warning(pop)

using namespace std;
using namespace clang;
using namespace clang::driver;
using namespace clang::tooling;
using namespace llvm;

BlankPragmaHandler * pragma_handler; //fixme: global var

struct ArrayDef
{
    string type;
    string name;
};

typedef ArrayDef ScalarDef;
typedef ArrayDef PrivateDef;

string header =
        "#include <cassert>\n"
        "\n"
        "/* DVMH includes */\n"
        "#include <dvmhlib2.h>\n"
        "#include <curand_mtgp32_kernel.h>\n"
        "\n"
        "int where_dep(int n, DvmType type_of_run, DvmType *idxs, int dep) {\n"
        "    int count = 0;\n"
        "    int h = 0;\n"
        "    int hd = dep;\n"
        "    for (int i = n - 1; i >= 0; --i) {\n"
        "        if (type_of_run % 2 != 0) {\n"
        "            count++;\n"
        "            idxs[h] = i;\n"
        "            h++;\n"
        "        } else {\n"
        "            idxs[hd] = i;\n"
        "            hd++;\n"
        "        }\n"
        "        type_of_run = type_of_run / 2;\n"
        "    }\n"
        "    return count;\n"
        "}\n"
        "\n";


class HandlerGenVisitor : public RecursiveASTVisitor<HandlerGenVisitor>
{
private:
    ASTContext *astContext;

    BlankPragmaHandler * ph;
    SourceManager * srcMgr;
public:
    explicit HandlerGenVisitor(CompilerInstance *CI, BlankPragmaHandler * ph)
    : astContext(&(CI->getASTContext()))
    {
        this->ph = ph;
        srcMgr = &astContext->getSourceManager();

        cout << header << "\n\n";
    }


    bool VisitFunctionDecl(FunctionDecl * f)
    {
        FileID fileID = srcMgr->getFileID(f->getLocStart());
        int pragmaLine = srcMgr->getLineNumber(fileID, srcMgr->getFileOffset(f->getLocStart())) - 1;
        PragmaHandlerStub *curPragma = ph->getPragmaAtLine(pragmaLine);
        std::string funcName = f->getName();
        std::string handlerStr;
        std::string kernelStr;
        if (curPragma) {
            cerr << "******* Found loop to handle:" << endl
                 << "***" << endl
                 << "*** Line: " << curPragma->line << endl
                 << "***" << endl
                 << "*** Is across: " << (curPragma->isAcross?"true":"false") << endl
                 << "***" << endl
                 << "*******" << endl << endl;
            if (!curPragma->isAcross) {
                NoAcrossGen generator(curPragma, astContext, f, make_shared<TokenDB>("gen", 100));
                handlerStr = generator.GenerateHandler();
                kernelStr = generator.GenKernel();
                cout << endl << kernelStr;
                cout << endl << handlerStr;
            } else {
                AcrossGen generator(curPragma, astContext, f, make_shared<TokenDB>("gen", 100));
                handlerStr = generator.GenerateHandler();
                kernelStr = generator.GenKernel();
                cout << endl << kernelStr;
                cout << endl << handlerStr;
            }
        }
        return true;
    }

    bool TraverseFunctionDecl(FunctionDecl *f)
    {
        bool res = RecursiveASTVisitor<HandlerGenVisitor>::TraverseFunctionDecl(f);
        return res;
    }

};



class DimCountASTConsumer : public ASTConsumer
{
private:
    HandlerGenVisitor *visitor;
public:
    explicit DimCountASTConsumer(CompilerInstance * CI)
            :visitor(new HandlerGenVisitor(CI, pragma_handler))
    {
        CI->getPreprocessor().AddPragmaHandler(pragma_handler); //fixme: global var
    }

    virtual void HandleTranslationUnit(ASTContext &Context)
    {
        visitor->TraverseDecl(Context.getTranslationUnitDecl());
    }

};


class DimCountFrontendAction : public ASTFrontendAction
{
public:
    virtual ASTConsumer * CreateASTConsumer(CompilerInstance &CI, StringRef file)
    {
        pragma_handler = new BlankPragmaHandler(CI); //fixme: global var pragma_handler
        return new DimCountASTConsumer(&CI);
    }
};


int main(int argc, const char **argv) {
    CommonOptionsParser op(argc, argv);
    ClangTool Tool(op.getCompilations(), op.getSourcePathList());

    int result = Tool.run(newFrontendActionFactory<DimCountFrontendAction>());
    cerr << "\n***********DimCount FrontendAction finished***************\n\n";
    return result;
}