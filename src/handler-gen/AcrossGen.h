
#pragma once
#include <handler-gen/HandlerGen.h>
#include <string>

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
#pragma warning(pop)

#include <PragmaHandling.h>
#include <MDLoopInfo.h>
#include <TokenDB.h>

class AcrossGen: public HandlerGen
{

public:

    explicit  AcrossGen(PragmaHandlerStub * pragma, clang::ASTContext * ctx, clang::FunctionDecl * f, const std::shared_ptr<TokenDB>& token_db)
    :HandlerGen(pragma, ctx, f, token_db)
    {
    }

	virtual std::string GenerateHandler() override;

	virtual std::string GenKernel() override;
	
};

