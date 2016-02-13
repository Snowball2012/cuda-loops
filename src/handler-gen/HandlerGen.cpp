#include <handler-gen/HandlerGen.h>

using std::vector;
using std::string;

using namespace clang;

void HandlerGen::GenNames()
{
	func_name = funcDecl->getName().str();
	
	arrs.reserve(loopInfo.dvmArrays.size());
	for (const auto & arr : loopInfo.dvmArrays)
		arrs.push_back(VarStr(arr.first, arr.second.getAsString(), m_token_db));

	sclrs.reserve(loopInfo.scalars.size());
	for (const auto & sclr : loopInfo.scalars)
		sclrs.push_back(VarStr(sclr.first, sclr.second.getAsString(), m_token_db));

	arr_dev_hdrs.reserve(arrs.size());
	for (const auto & arr : arrs)
		arr_dev_hdrs.push_back(VarStr(arr.name + "_devHdr", "DvmType", m_token_db));

	arr_hdrs.reserve(arrs.size());
	for (const auto & arr : arrs)
		arr_hdrs.push_back(VarStr(arr.name + "_hdr", "DvmType", m_token_db));

	sclr_hdrs.reserve(sclrs.size());
	for (const auto & sclr : sclrs)
		sclr_hdrs.push_back(VarStr(sclr.name + "_hdr", sclr.type + "*", m_token_db));

	sclr_ptrs.reserve(sclrs.size());
	for (const auto & sclr : sclrs)
		sclr_ptrs.push_back(VarStr(sclr.name + "_ptr", sclr.type + "*", m_token_db));

	arr_bases.reserve(arrs.size());
	for (const auto & arr : arrs)
		arr_bases.push_back(VarStr(arr.name + "_base", arr.type + "*", m_token_db));

}

int HandlerGen::GetIndexByArr(std::string &str) {
	if ( loopInfo.dvmArrays.find(str) == loopInfo.dvmArrays.end() ) {
		return -1;
	}
	else {
		for (int i = 0, size = arrs.size(); i < size; i++) {
			if (arrs[i].old_name == str)
				return i;
		}
	}
	return -1;
}

int HandlerGen::GetIndexBySclr(std::string &str) {
	if ( loopInfo.scalars.find(str) == loopInfo.scalars.end() ) {
		return -1;
	}
	else {
		for (int i = 0, size = sclrs.size(); i < size; i++) {
			if (sclrs[i].old_name == str)
				return i;
		}
	}
	return -1;
}

bool HandlerGen::VisitStmt(Stmt * st)
{
	if (find(visitedNodes.begin(), visitedNodes.end(), st) == visitedNodes.end()) {
		// looking for indexation
		// note: perhaps it's better to keep visitedNodes sorted
		if (isa<CompoundStmt>(st)) {
			CompoundStmt * cs = static_cast<CompoundStmt *>(st);
			loopRange = cs->getSourceRange();
		}
		if (isa<ArraySubscriptExpr>(st)) {
			SourceRange subRange;
			vector<Expr *> subs;
			subRange.setEnd(st->getLocEnd());
			do {
				visitedNodes.push_back(st);
				ArraySubscriptExpr *arSt = static_cast<ArraySubscriptExpr *>(st);
				Expr * sub = arSt->getRHS();
				subs.push_back(sub);
				st = arSt->getLHS();
				subRange.setBegin(st->getLocEnd());
				if (isa<ImplicitCastExpr>(st))
					st = static_cast<ImplicitCastExpr *>(st)->getSubExpr();
			} while (isa<ArraySubscriptExpr>(st));

			reverse(subs.begin(), subs.end());

			string base = "";
			if (isa<DeclRefExpr>(st)) {
				base = rw.ConvertToString(st);
				if (find(pragma->dvmArrays.begin(), pragma->dvmArrays.end(), base) == pragma->dvmArrays.end())
					return true;
			}
			string idxRepl;
			idxRepl.clear();
			int arr_idx = GetIndexByArr(base);
			if (arr_idx == -1)
				throw std::exception();

			idxRepl += arr_bases[arr_idx].name + "[";
			int j = 1;
			for (auto i = subs.begin(); i != subs.end(); ++i, ++j) {
				string curSub;
				curSub = "(" + rw.ConvertToString(*i) + ")*(" + arr_hdrs[arr_idx].name + std::to_string(j) + ")";
				if (j != 1)
					idxRepl += " + ";
				idxRepl += curSub;
			}
			idxRepl += "]";
			rw.ReplaceText(subRange, idxRepl);
		}
	}
	return true;
}