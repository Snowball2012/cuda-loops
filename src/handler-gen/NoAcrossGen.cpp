//
// Created by snowball on 23.03.15.
//

#include <handler-gen/NoAcrossGen.h>

#pragma warning(push, 0) 
#include <clang/AST/Type.h>
#include <string>
#pragma warning(pop)

using namespace clang;
using std::string;
using std::set;
using std::map;
using std::vector;
using std::to_string;
using std::tuple;
using std::tie;
using std::find;
using std::reverse;

string NoAcrossGen::GenerateHandler()
{
    string handlerTxt;
    handlerTxt.clear();
    

    handlerTxt.append("extern \"C\" void " + func_name + "_cuda(");
    handlerTxt.append("DvmType *pLoopRef, ");	
    for (const auto & hdr : arr_hdrs) {
        handlerTxt.append( hdr.type + " " + hdr.name + "[]");
    }
    for (const auto & hdr : sclr_hdrs) {
        handlerTxt.append(", " + hdr.type + " " + hdr.name + "[]");
    }

    handlerTxt.append(")\n");
    handlerTxt.append("{\n");

    handlerTxt.append("    DvmType tmpVar;\n\n");
    handlerTxt.append("    DvmType loop_ref = *pLoopRef;\n");
    handlerTxt.append("    DvmType device_num = dvmh_loop_get_device_num_C(loop_ref);\n");	

    for (size_t i = 0; i < arrs.size(); ++i) {
		string name = arrs[i].name;
        string type = arrs[i].type;
		string arr_hdr = arr_hdrs[i].name;
		string arr_hdr_type = arr_hdrs[i].type;
		string arr_dev_hdr = arr_dev_hdrs[i].name;
		string arr_dev_hdr_type = arr_dev_hdrs[i].type;
        handlerTxt.append("    dvmh_loop_autotransform_C(loop_ref, " + arr_hdr + ");");
        handlerTxt.append("    " + type + " * " + name);
        handlerTxt.append(" = (" + type + " *)\n");
        handlerTxt.append("        dvmh_get_natural_base_C(device_num, " + arr_hdr + ");\n");
        handlerTxt.append("    " + arr_dev_hdr_type + " " + arr_dev_hdr + "[" + to_string(loopInfo.loopVars.size() + 3) + "];\n");
        handlerTxt.append("    tmpVar = dvmh_fill_header_C(device_num, " + name + ", " + arr_hdr);
        handlerTxt.append(", " + arr_dev_hdr + ", 0);\n");
        handlerTxt.append("    assert(tmpVar == 0 || tmpVar == 1);\n\n");
    }

    for (size_t i = 0; i < sclrs.size(); ++i) {
        string type = sclrs[i].type;
        string name = sclrs[i].name;
		string ptr_type = sclr_ptrs[i].type;
		string ptr_name = sclr_ptrs[i].name;
        handlerTxt.append("    " + type + " * " + name + " = (" + type + " *)dvmh_get_device_addr_C("
            + "device_num, " + ptr_name + ");\n");
    }

	string dims_str = to_string(loopInfo.loopVars.size());

    handlerTxt.append("    /* Supplementary variables for loop handling */\n");
	handlerTxt.append("    IndexType boundsLow[" + dims_str
            + "], boundsHigh[" + dims_str + "], loopSteps[" + dims_str + "];\n");
    handlerTxt.append("    DvmType blocksS[" + dims_str + "];\n");
    handlerTxt.append("    DvmType restBlocks;\n");
    handlerTxt.append("    dim3 blocks(1, 1, 1), threads(0, 0, 0);\n");
    handlerTxt.append("    cudaStream_t stream;\n\n");

    handlerTxt.append("    /* Get CUDA configuration parameters */\n");
    handlerTxt.append("    extern DvmType " + func_name + "_cuda_kernel_regs;\n");
    handlerTxt.append("    dvmh_loop_cuda_get_config_C(loop_ref, 0, " + func_name + "_cuda_kernel_regs,\n" +
                      "        &threads, &stream, 0);\n\n");

    handlerTxt.append("    /* Calculate computation distribution parameters */\n");
    handlerTxt.append("    dvmh_loop_fill_bounds_C(loop_ref, boundsLow, boundsHigh, loopSteps);\n");

    int loopDims = loopInfo.loopVars.size();
    for (int i = loopDims - 1; i >= 0; --i) {
        int ri = loopDims - i - 1;
        char let = 'x' + ri;
        string thread = "";
        if (ri <= 2) {
            thread = "threads.";
            thread += let;
        } else {
            thread = "";
        }
        string k = "";
        if (i != loopDims - 1)
            k = "blocksS[" + to_string(i + 1) + "]";

        handlerTxt += "    blocksS[" + to_string(i) + "] = " + (k.empty()?"": k + " * ") +
                "((boundsHigh[" + to_string(i) + "] - boundsLow[" + to_string(i) + "]) / loopSteps[" +
                to_string(i) + "] + 1" + (thread.empty()?")":string(" + (" + thread + " - 1)) / " + thread)) + ";\n";
    }

    handlerTxt += "\n    /* Reduction-related stuff */\n";
    for (int i = 1; i <= loopInfo.reductions.size(); ++i) {
        tuple <ClauseReduction, QualType> cur_red = loopInfo.reductions[i-1];
        ClauseReduction red;
        QualType rt;
        tie(red, rt) = cur_red;
        string type = rt.getAsString();
        string name = red.arrayName;
        handlerTxt += "    " + type + " " + name + ";\n";
        handlerTxt += "    " + type + " * " + name + "_grid;\n";
        handlerTxt += "    dvmh_loop_cuda_register_red_C(loop_ref, " + to_string(i) +
                ", (void**)&" + name + "_grid, 0);\n";
        handlerTxt += "    dvmh_loop_red_init_C(loop_ref, " + to_string(i) + ", &"
                + name + ", 0);\n";
        handlerTxt += "    dvmh_loop_cuda_red_prepare_C(loop_ref, " + to_string(i) +
                ", blocksS[0] * threads.x * threads.y * threads.z, 0);\n";
    }

    handlerTxt += "\n    /* GPU execution */\n";
    handlerTxt += "    restBlocks = blocksS[0];\n";
    handlerTxt += "    while (restBlocks > 0) {\n";
    handlerTxt += "        blocks.x = (restBlocks <= 65535 ? restBlocks : (restBlocks <= 65535 * 2 ? restBlocks / 2 : 65535));\n";
    handlerTxt += "        " + func_name + "_cuda_kernel<<<blocks, threads, 0, stream>>>(";
    for (size_t i = 0; i < arrs.size(); ++i) {
        string name = arrs[i].name;
        string dev_hdr = arr_dev_hdrs[i].name;
        handlerTxt += name + ", ";
        for (int j = 1; j <= loopDims; j++)
            handlerTxt += dev_hdr + "[" + to_string(j) +"], ";
    }
    for (const auto & sclr : sclrs) {
        handlerTxt += sclr.name + ", ";
    }
    for (int i = 0; i < loopDims; ++i) {
        string index = to_string(i);
        handlerTxt += "boundsLow[" + index + "], boundsHigh[" + index + "], "
                + "loopSteps[" + index + "], "
                + (i>0?(string("blocksS[") + index + string("], ")):"");
    }
    for (int i = 0; i < loopInfo.reductions.size(); ++i) {
        tuple <ClauseReduction, QualType> cur_red = loopInfo.reductions[i];
        ClauseReduction red;
        QualType rt;
        tie(red, rt) = cur_red;  //note: clion treats this line as error, don't worry, the line is fine
        string type = rt.getAsString();
        string name = red.arrayName;
        handlerTxt += name + ", " + name + "_grid, ";
    }
    handlerTxt += "blocksS[0] - restBlocks);\n";
    handlerTxt += "        restBlocks -= blocks.x;\n    }\n";

    for (int i = 1; i <= loopInfo.reductions.size(); ++i) {
        tuple <ClauseReduction, QualType> cur_red = loopInfo.reductions[i-1];
        ClauseReduction red;
        QualType rt;
        tie(red, rt) = cur_red;  //note: clion treats this line as error, don't worry, the line is fine
        string type = rt.getAsString();
        string name = red.arrayName;
        handlerTxt += "    dvmh_loop_cuda_red_finish_C(loop_ref, " + to_string(i) + ");\n";
    }

    handlerTxt += "}\n";

    return handlerTxt;
}



string NoAcrossGen::GenKernel()
{
    string kernelTxt;
    kernelTxt.clear();

    int loopDims = loopInfo.loopVars.size();

    kernelTxt += "__global__ void " + func_name + "_cuda_kernel(";

    for (auto i = 0; i < arrs.size(); ++i) {
        string name = arr_bases[i].name;
		string hdr = arr_hdrs[i].name;
        string type = arr_bases[i].type;
		string hdr_type = arr_hdrs[i].type;
        kernelTxt += type + " " + name + ", ";
        for (int j = 1; j <= loopDims; j++)
            kernelTxt += hdr_type + " " + hdr + to_string(j) +", ";
    }
    for (auto i = sclr_ptrs.begin(); i != sclr_ptrs.end(); ++i) {
        kernelTxt += (*i).type + " " + (*i).name + ", ";
    }
    for (int i = 0; i < loopDims; ++i) {
        string index = to_string(i + 1);
        kernelTxt += "DvmType boundsLow_" + index + ", DvmType boundsHigh_" + index + ", "
                     + "DvmType loopSteps_" + index + ", "
                      + (i>0?(string("DvmType blocksS_") + index + string(", ")):"");
    }
    for (int i = 0; i < loopInfo.reductions.size(); ++i) {
        tuple <ClauseReduction, QualType> cur_red = loopInfo.reductions[i];
        ClauseReduction red;
        QualType rt;
        tie(red, rt) = cur_red;  //note: clion treats this line as error, don't worry, the line is fine
        string type = rt.getAsString();
        string name = red.arrayName;
        kernelTxt += type + " " + name + ", " + type + " " + name + "_grid[], ";
    }
    kernelTxt += "DvmType blockOffset)\n";
    kernelTxt += "{\n";

    for (auto i = arr_bases.begin(); i != arr_bases.end(); ++i) {
        string name = (*i).name;
        string type = (*i).type;
        kernelTxt += "    " + type + " " + name + " = " + name + ";\n";
    }

    for (auto i = 0; i < sclrs.size(); ++i) {
        kernelTxt += "    " + sclrs[i].type + " & " + sclrs[i].name + " = *" + sclr_ptrs[i].name +";\n";
    }

    kernelTxt += "    DvmType restBlocks, curBlocks;\n\n";
    kernelTxt += "    /* User variables - loop index variables and other private variables */\n";

    for (auto i = loopInfo.loopVars.begin(); i != loopInfo.loopVars.end(); ++i) {
        kernelTxt += "    int " + (*i).name + ";\n";
    }

    for (auto i = loopInfo.privates.begin(); i != loopInfo.privates.end(); ++i) {
        kernelTxt += "    " + (*i).second.getAsString() + " " + (*i).first + ";\n";
    }

    kernelTxt += "\n";
    int indent = 4;
    #define paste_indent for(int i = 0; i < indent; ++i) kernelTxt += " ";
    int i = 1;
    for (auto lv = loopInfo.loopVars.begin(); lv != loopInfo.loopVars.end(); ++lv, ++i) {
        paste_indent
        if (i == 1)
            kernelTxt += "restBlocks = blockIdx.x + blockOffset";
        else
            kernelTxt += "restBlocks = restBlocks - curBlocks * blocksS_" + to_string(i);
        kernelTxt += ";\n";
        paste_indent
        kernelTxt += "curBlocks = restBlocks";
        if (i != loopDims)
            kernelTxt += " / blocksS_" + to_string(i + 1);
        kernelTxt += ";\n";
        paste_indent
        int ri = loopDims - i;
        char let = 'x' + ri;
        kernelTxt += (*lv).name + " = boundsLow_" + to_string(i) + " + (loopSteps_" + to_string(i) + ") * ";
        if (ri > 2)
            kernelTxt += "curBlocks";
        else {
            kernelTxt += "( curBlocks * blockDim.";
            kernelTxt += let;
            kernelTxt += " + threadIdx.";
            kernelTxt += let;
            kernelTxt += ")";
        }
        kernelTxt += ";\n";
        paste_indent
        kernelTxt += "if (" + (*lv).name + " <= boundsHigh_" + to_string(i) + ") ";
        if (i == loopDims) {
            //make loop text
            kernelTxt += "\n";
            paste_indent
            loopTxt.clear();
            TraverseFunctionDecl(funcDecl);
            kernelTxt += rw.getRewrittenText(loopRange) + "\n";
        } else {
            kernelTxt += " {\n";
        }
        indent += 4;
    }
    indent -= 4;
    for (; i > 2; --i) {
        indent -= 4;
        paste_indent
        kernelTxt += "}\n";
    }
    #undef paste_indent


    //Paste reduction vars

    for (int i = 0; i < loopInfo.reductions.size(); ++i) {
        tuple<ClauseReduction, QualType> cur_red = loopInfo.reductions[i];
        ClauseReduction red;
        QualType rt;
        tie(red, rt) = cur_red;  //note: clion treats this line as error, don't worry, the line is fine
        string type = rt.getAsString();
        string name = red.arrayName;
        kernelTxt += "    " + name + "_grid[ threadIdx.x + blockDim.x * ( threadIdx.y + blockDim.y * " +
                      "( threadIdx.z + blockDim.z * ( blockIdx.x + blockOffset ) ) ) ] = " + name + ";\n";
    }

    kernelTxt += "}\n";

    return kernelTxt;
}


bool NoAcrossGen::VisitStmt(Stmt * st)
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
            idxRepl += base + "[";
            int j = 1;
            for (auto i = subs.begin(); i != subs.end(); ++i, ++j) {
                string curSub;
                curSub = "(" + rw.ConvertToString(*i) + ")*(" + base + "_hdr" + to_string(j) + ")";
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