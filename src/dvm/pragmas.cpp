#include "pragmas.h"

#include <cassert>


// DistribAxisRule

bool DistribAxisRule::isConstant() const {
    if (distrType == dtReplicated || distrType == dtBlock)
        return true;
    if (distrType == dtMultBlock)
        return true;
    return false;
}

// DistribRule

bool DistribRule::isConstant() const {
    for (int i = 0; i < rank; i++)
        if (!axes[i].isConstant())
            return false;
    return true;
}

// ClauseReduction

std::string ClauseReduction::guessRedType(std::string tokStr) {
    if (!redTypesInitialized)
        initRedTypes();
    std::map<std::string, std::string>::iterator it = redTypes.find(tokStr);
    if (it == redTypes.end())
        return "";
    else
        return it->second;
}

std::string ClauseReduction::toOpenMP() const {
    if (redType == "rf_SUM") return "+";
    else if (redType == "rf_PROD" || redType == "rf_MULT") return "*";
    else if (redType == "rf_AND") return "&";
    else if (redType == "rf_OR") return "|";
    else if (redType == "rf_XOR") return "^";
    else if (redType == "rf_MIN") return "min";
    else if (redType == "rf_MAX") return "max";
    else return "";
}

std::string ClauseReduction::toClause() const {
    std::string redFunc = redType;
    for (std::map<std::string, std::string>::iterator it = redTypes.begin(); it != redTypes.end(); it++)
        if (redType == it->second)
            redFunc = it->first;
    return redFunc + "(" + arrayName + (isLoc() ? ", " + locName + ", " + locSize.strExpr : "") + ")";
}

void ClauseReduction::initRedTypes() {
    redTypes["sum"] = "rf_SUM";
    redTypes["product"] = "rf_PROD";
    redTypes["max"] = "rf_MAX";
    redTypes["min"] = "rf_MIN";
    redTypes["and"] = "rf_AND";
    redTypes["or"] = "rf_OR";
    redTypes["xor"] = "rf_XOR";
    redTypes["maxloc"] = "rf_MAXLOC";
    redTypes["minloc"] = "rf_MINLOC";
    redTypesInitialized = true;
}

std::map<std::string, std::string> ClauseReduction::redTypes;
bool ClauseReduction::redTypesInitialized = false;

// ClauseRemoteAccess

bool ClauseRemoteAccess::matches(std::string seenExpr, int idx) {
    if (axisRules[idx].axisNumber == -1)
        return true;
    std::string origExpr = axisRules[idx].origExpr.strExpr;
    int i1, i2;
    i1 = 0;
    i2 = 0;
    while (i1 < seenExpr.size() && i2 < origExpr.size()) {
        while (i1 < seenExpr.size() && seenExpr[i1] == ' ')
            i1++;
        while (i2 < origExpr.size() && origExpr[i2] == ' ')
            i2++;
        if ((i1 < seenExpr.size()) != (i2 < origExpr.size()))
            return false;
        if (i1 < seenExpr.size() && i2 < origExpr.size()) {
            if (seenExpr[i1] != origExpr[i2])
                return false;
            i1++;
            i2++;
        }
    }
    return (i1 >= seenExpr.size() && i2 >= origExpr.size());
}

// PragmaRegion


