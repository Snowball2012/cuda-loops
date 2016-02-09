#include <handler-gen/HandlerGen.h>

using std::vector;
using std::string;

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
		arr_hdrs.push_back(VarStr(arr.name + "_base", arr.type + "*", m_token_db));


}