#pragma once

#include <string>
#include <map>
#include <memory>
#include <boost/container/flat_set.hpp>

// Makes unique name for token. You must put all existing tokens in db first
// Every token is generated using following method:
// <token_name_new> ::= <token_name>_<addition>
// This procedure is required to avoid collisions with internal template tokens


class TokenDB
{
public:
	TokenDB(const std::string& addition, int estimated_size = 0);
	~TokenDB();

	// Retrieve unique token, generate one if needed
	const std::string& GetUniqueToken(const std::string& token);

	// Insert an item to m_used_tokens. Use this for keywords, reserved names, etc.
	// Do not use this for variables, use GetUniqueToken instead
	bool InsertUsedToken(const std::string& token);

private:
	std::map<std::string, const std::string> m_tokens;
	boost::container::flat_set<std::string> m_used_tokens;
	size_t m_cur_id;
	std::string m_addition;

	std::string GetNewNameForToken(const std::string& token);

	const size_t max_token_num = 0xffffffff;
};

struct VarStr
{
	VarStr(const std::string& a_name, const std::string& a_type, std::shared_ptr<TokenDB>& db) : type(a_type), old_name(a_name)
	{
		if (db)
			name = db->GetUniqueToken(a_name);
		else
			name = a_name;
	}
	std::string name;
	std::string old_name;
	std::string type;
};
