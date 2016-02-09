
#pragma once

#include <string>
#include <memory>

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


class HandlerGen : public clang::RecursiveASTVisitor<HandlerGen>
{

protected:

	PragmaHandlerStub * pragma;
	clang::ASTContext * ctx;
	clang::SourceManager * srcMgr;
	MDLoopInfo loopInfo;
	clang::FunctionDecl * funcDecl;

	std::string loopTxt;
	clang::SourceRange loopRange;
	std::vector<clang::Stmt *> visitedNodes;

	clang::Rewriter rw;

	std::shared_ptr<TokenDB> m_token_db;

	std::string func_name;
	std::vector<VarStr> arrs;
	std::vector<VarStr> sclrs;
	std::vector<VarStr> arr_dev_hdrs;
	std::vector<VarStr> arr_hdrs;
	std::vector<VarStr> sclr_hdrs;
	std::vector<VarStr> sclr_ptrs;
	std::vector<VarStr> arr_bases;

public:

	explicit  HandlerGen(PragmaHandlerStub * pragma, clang::ASTContext * ctx, clang::FunctionDecl * f, std::shared_ptr<TokenDB>& token_db)
		:loopInfo(*pragma, f), rw(ctx->getSourceManager(), ctx->getLangOpts()), m_token_db(token_db)
	{
		this->pragma = pragma;
		this->ctx = ctx;
		this->funcDecl = f;
		srcMgr = &ctx->getSourceManager();
		visitedNodes.clear();
		GenNames();
	}

	virtual std::string GenerateHandler() = 0;

	virtual std::string GenKernel() = 0;

	virtual bool VisitStmt(clang::Stmt * st) = 0;

private:
	void GenNames();

};


