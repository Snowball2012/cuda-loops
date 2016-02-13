#include "TokenDB.h"

#include <exception>
#include <boost/lexical_cast.hpp>

using std::string;

TokenDB::TokenDB(const string& addition, int estimated_size)
	: m_addition(addition), m_cur_id(0)
{
	m_used_tokens.reserve(estimated_size);
}


TokenDB::~TokenDB()
{
}

const string& TokenDB::GetUniqueToken(const string& token)
{
	if (m_tokens.count(token) == 0) {
		m_tokens.insert(std::pair<string, string>(token, GetNewNameForToken(token)));
	}
	return m_tokens[token];
}

bool TokenDB::InsertUsedToken(const std::string& token)
{
	m_used_tokens.insert(token);
	return true;
}

string TokenDB::GetNewNameForToken(const string& token)
{
	string res(token);
	if (m_addition.length() > 0) {
		res += "_" + m_addition;
	}

	for (; ; m_cur_id++) {
		string temp(res + "_" + boost::lexical_cast<string>(m_cur_id));
		if (m_used_tokens.count(temp) == 0) {
			res = temp;
			m_used_tokens.insert(temp);
			break;
		}
		if (m_cur_id >=  max_token_num) // extremely unlikely this will ever happen
			throw std::exception();
	}

	return res;
}