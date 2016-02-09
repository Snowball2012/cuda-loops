#pragma once

#include <vector>
#include <string>
#include <map>
#include <set>
#include <algorithm>
#include <cassert>

struct LoopVarDesc {
    std::string name;
    int stepSign; // +1 or -1
    std::string constStep; // empty if not const
};

class ArrayRefDesc {
public:
    std::string name;
    std::pair<int, int> head;
    std::vector<std::pair<int, int> > indexes; // With brackets
};

class MyExpr {
public:
    std::string strExpr;
    std::set<std::string> usedNames;
    std::vector<ArrayRefDesc> arrayRefs;
public:
    bool empty() const { return strExpr.empty(); }
    void append(const std::string &s) { strExpr += s; }
    void prepend(const std::string &s) {
        int offs = s.size();
        strExpr = s + strExpr;
        for (int i = 0; i < arrayRefs.size(); i++) {
            arrayRefs[i].head.first += offs;
            arrayRefs[i].head.second += offs;
            for (int j = 0; j < arrayRefs[i].indexes.size(); j++) {
                arrayRefs[i].indexes[j].first += offs;
                arrayRefs[i].indexes[j].second += offs;
            }
        }
    }
};

class DerivedRange {
public:
    std::pair<int, int> begin, end;
};

class DerivedAxisRule {
public:
    std::string templ;
    int templRank;
    std::map<std::string, int> nameToAxis;
    MyExpr expr;
    std::vector<DerivedRange> ranges;
};

class DistribAxisRule {
public:
    enum DistrType {dtReplicated, dtBlock, dtWgtBlock, dtGenBlock, dtMultBlock, dtIndirect, dtDerived, dtInvalid};
public:
    DistribAxisRule(): distrType(dtInvalid) {}
public:
    bool isConstant() const;
public:
    DistrType distrType;
    std::pair<std::string, MyExpr> wgtBlockArray; // pair of name of array and its size
    std::string genBlockArray; // name of array
    MyExpr multBlockValue; // size expression
    std::string indirectArray; // name of array
    DerivedAxisRule derivedRule;
};

class DistribRule {
public:
    DistribRule(): rank(-1) {}
public:
    bool isConstant() const;
public:
    int rank;
    std::vector<DistribAxisRule> axes;
};

class AlignAxisRule {
public:
    AlignAxisRule(): axisNumber(-2) {}
public:
    MyExpr origExpr; // whole expression
    int axisNumber; // -1 means replicate. 0 means mapping to constant. 1-based
    MyExpr multiplier; // 0 means mapping to constant
    MyExpr summand;
};

class AlignRule {
public:
    AlignRule(): rank(-1), templ("unknown"), templRank(-1) {}
public:
    int rank;
    std::string templ;
    int templRank;
    std::map<std::string, int> nameToAxis;
    std::vector<AlignAxisRule> axisRules;
};

class SlicedArray {
public:
    SlicedArray(): name("unknown"), slicedFlag(-1) {}
public:
    std::string name;
    int slicedFlag;
    std::vector<std::pair<MyExpr, MyExpr> > bounds; // lower, high
};

class ClauseReduction {
public:
    ClauseReduction(): redType("unknown"), arrayName("unknown"), locName("unknown") {}
public:
    static std::string guessRedType(std::string tokStr);
public:
    std::string redType;
    std::string arrayName;
    std::string locName;
    MyExpr locSize;
public:
    bool isLoc() const { return redType == "rf_MINLOC" || redType == "rf_MAXLOC"; }
    bool hasOpenMP() const { return toOpenMP() != ""; }
    std::string toOpenMP() const;
    std::string toClause() const;
protected:
    static std::map<std::string, std::string> redTypes;
    static bool redTypesInitialized;
    static void initRedTypes();
};

class ClauseShadowRenew {
public:
    ClauseShadowRenew(): arrayName("unknown"), rank(-1), cornerFlag(-1) {}
public:
    std::string  arrayName;
    int rank;
    std::vector<std::pair<MyExpr, MyExpr> > widths; // lower, high
    int cornerFlag;
};

class ClauseAcross {
public:
    ClauseAcross(): arrayName("unknown"), rank(-1) {}
public:
    std::string  arrayName;
    int rank;
    std::vector<std::pair<MyExpr, MyExpr> > widths; // flow, anti
};

class ClauseRemoteAccess {
public:
    ClauseRemoteAccess(): arrayName("unknown"), rank(-1), excluded(false) {}
public:
    bool matches(std::string seenExpr, int idx);
public:
    std::string arrayName;
    int rank;
    int nonConstRank;
    std::vector<int> axes; // non-const axis numbers. 1-based
    std::vector<AlignAxisRule> axisRules;
    bool excluded;
};

class DvmPragma {
public:
    enum Kind {pkTemplate, pkDistribArray, pkRedistribute, pkRealign, pkRegion, pkParallel, pkGetActual, pkSetActual, pkInherit, pkRemoteAccess, pkHostSection,
            pkInterval, pkNoKind};
public:
    explicit DvmPragma(Kind aKind): fileName("unknown"), line(-1), srcFileName("unknown"), srcLine(-1), kind(aKind) {}
public:
    std::string fileName;
    int line;
    std::string srcFileName;
    int srcLine;
    Kind kind;
};

class PragmaTemplate: public DvmPragma {
public:
    PragmaTemplate(): DvmPragma(pkTemplate), rank(-1), alignFlag(-1), dynamicFlag(-1) {}
public:
    int rank;
    std::vector<MyExpr> sizes;
    int alignFlag;
    int dynamicFlag;
    DistribRule distribRule;
    AlignRule alignRule;
};

class PragmaDistribArray: public DvmPragma {
public:
    PragmaDistribArray(): DvmPragma(pkDistribArray), rank(-1), alignFlag(-1), dynamicFlag(-1) {}
public:
    int rank;
    int alignFlag;
    int dynamicFlag;
    DistribRule distribRule;
    AlignRule alignRule;
    std::vector<std::pair<MyExpr, MyExpr> > shadows;
};

class PragmaRedistribute: public DvmPragma {
public:
    PragmaRedistribute(): DvmPragma(pkRedistribute), name("unknown"), rank(-1) {}
public:
    std::string name;
    int rank;
    DistribRule distribRule;
};

class PragmaRealign: public DvmPragma {
public:
    PragmaRealign(): DvmPragma(pkRealign), name("unknown"), rank(-1), newValueFlag(false) {}
public:
    std::string name;
    int rank;
    AlignRule alignRule;
    bool newValueFlag;
};



class PragmaParallel: public DvmPragma {
public:
    PragmaParallel(): DvmPragma(pkParallel), rank(-1), mappedFlag(false) {}
public:
    int rank;
    bool mappedFlag;
    AlignRule mapRule;
    std::vector<ClauseReduction> reductions;
    MyExpr cudaBlock[3];
    std::vector<ClauseShadowRenew> shadowRenews;
    std::vector<std::string> privates;
    std::vector<ClauseAcross> acrosses;
    MyExpr stage;
    std::vector<ClauseRemoteAccess> rmas;
};

class PragmaGetSetActual: public DvmPragma {
public:
    explicit PragmaGetSetActual(Kind aKind): DvmPragma(aKind) {}
public:
    std::vector<SlicedArray> vars;
};

class PragmaInherit: public DvmPragma {
public:
    PragmaInherit(): DvmPragma(pkInherit) {}
public:
    std::vector<std::string> names;
};

class PragmaRemoteAccess: public DvmPragma {
public:
    PragmaRemoteAccess(): DvmPragma(pkRemoteAccess) {}
public:
    std::vector<ClauseRemoteAccess> rmas;
};

class PragmaHostSection: public DvmPragma {
public:
    PragmaHostSection(): DvmPragma(pkHostSection) {}
};

class PragmaInterval: public DvmPragma {
public:
    PragmaInterval(): DvmPragma(pkInterval) {}
};

