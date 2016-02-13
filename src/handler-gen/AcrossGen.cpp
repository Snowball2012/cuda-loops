//
// Created by snowball on 23.03.15.
//

#include <handler-gen/AcrossGen.h>

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

string AcrossGen::GenerateHandler()
{
	string handlerTxt;
	handlerTxt.clear();

    string handlerName = func_name + "_cuda";
    string handlerCaseName = func_name + "_cuda_across";

    handlerTxt.append("extern \"C\" void " + handlerCaseName +"(");
    handlerTxt.append("DvmType *pLoopRef");
	for (const auto & hdr : arr_hdrs) {
		handlerTxt.append( ", " + hdr.type + " " + hdr.name + "[]");
	}
	for (const auto & hdr : sclr_hdrs) {
		handlerTxt.append(", " + hdr.type + " " + hdr.name + "[]");
	}

    handlerTxt += ", int dep_mask";

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
	size_t loopDims = loopInfo.loopVars.size();

    handlerTxt.append("    /* Supplementary variables for loop handling */\n");
    handlerTxt.append("    IndexType boundsLow[" + dims_str
                      + "], boundsHigh[" + dims_str + "], loopSteps[" + dims_str + "]"
                      + ", idxs[" + dims_str + "];\n");

    handlerTxt.append("    DvmType restBlocks;\n");
    handlerTxt.append("    dim3 blocks(1, 1, 1), threads(1, 1, 1);\n");
    handlerTxt.append("    cudaStream_t stream;\n\n");

    handlerTxt.append("    /* Get CUDA configuration parameters */\n");
    handlerTxt.append("    extern DvmType " + func_name + "_cuda_kernel_int_regs;\n");
    handlerTxt.append("    DvmType shared_mem = " + to_string(16 * loopInfo.reductions.size()) +";\n"); //fixme: hardcoded mem size
    handlerTxt.append("    dvmh_loop_cuda_get_config_C(loop_ref, shared_mem, " + func_name + "_cuda_kernel_int_regs,\n" +
                      "        &threads, &stream, &shared_mem);\n\n");

    handlerTxt.append("    /* Calculate computation distribution parameters */\n");
    handlerTxt.append("    dvmh_loop_fill_bounds_C(loop_ref, boundsLow, boundsHigh, loopSteps);\n");
    handlerTxt.append("    where_dep("
                       + dims_str + ", dep_mask, idxs, 1);\n\n" );

	

    for (int i = loopDims - 1; i >= 0; --i) {
        int ri = loopDims - i - 1;
        char let = 'x' + ri;
        char let_loop = 'i' + ri;
        string thread = "";

        string block = "";

        string num_elem = "";
        if (ri < 2) {
            thread = "threads.";
            thread += let;

            block = "blocks.";
            block += let;

            num_elem = "num_elem_";
            num_elem += let;

        }

        string base = "base_";
        base += let_loop;

        string idx = to_string(i);

        handlerTxt += "    DvmType " + base + " = boundsLow[" + idx + "];\n";

        idx = to_string(i-1);

        if (ri < 2) {
            string temp = "(abs(boundsLow[" + idx + "] - boundsHigh[" + idx + "]) + 1)";
            string temp2 = "abs(loopSteps[" + idx + "])";
            handlerTxt += "    DvmType " + num_elem + " = " + temp + " / " + temp2 + " + ("
                    + temp + " % " + temp2 + " != 0);\n";

            handlerTxt += "    " + block + " = " + num_elem + " / " + thread + " + ((" + num_elem
                    + " % " + thread + " != 0)?1:0);\n";
        }


    }
    handlerTxt += "\n";
    string idx = to_string(loopDims - 1);
    handlerTxt += "    boundsHigh[" + idx + "] = (abs(boundsHigh[" + idx
                    + "] - boundsLow[" + idx + "]) + 1) / abs(loopSteps[" + idx + "]);\n";

    handlerTxt += "\n    /* Reduction-related stuff */\n";
    for (int i = 1; i <= loopInfo.reductions.size(); ++i) {
        tuple <ClauseReduction, QualType> cur_red = loopInfo.reductions[i-1];
        ClauseReduction red;
        QualType rt;
        tie(red, rt) = cur_red;  //note: clion treats this line as error, don't worry, the line is fine
        string type = rt.getAsString();
        string name = red.arrayName;
        handlerTxt += "    " + type + " " + name + ";\n";
        handlerTxt += "    " + type + " * " + name + "_grid;\n";
        handlerTxt += "    dvmh_loop_cuda_register_red_C(loop_ref, " + to_string(i) +
                      ", (void**)&" + name + "_grid, 0);\n";
        handlerTxt += "    dvmh_loop_red_init_C(loop_ref, " + to_string(i) + ", &"
                      + name + ", 0);\n";
        handlerTxt += "    dvmh_loop_cuda_red_prepare_C(loop_ref, " + to_string(i) +
                      ", blocks.x * blocks.y * blocks.z, 1);\n";
    }

    handlerTxt += "\n    /* GPU execution */\n";

    handlerTxt += "    for (int tmpV = 0; tmpV < boundsHigh[" + idx +"]; base_i += loopSteps["
            + idx + "], tmpV++) {\n";

    handlerTxt += "        " + func_name + "_cuda_kernel<<<blocks, threads, shared_mem, stream>>>(";
	for (size_t i = 0; i < arrs.size(); ++i) {
		string name = arrs[i].name;
		string dev_hdr = arr_dev_hdrs[i].name;
		handlerTxt += name + ", ";
		for (int j = 1; j <= loopDims; j++)
			handlerTxt += dev_hdr + "[" + to_string(j) + "], ";
	}
	for (const auto & sclr : sclrs) {
		handlerTxt += sclr.name + ", ";
	}

    for (int i = loopDims - 1; i >= 0; --i) {
        int ri = loopDims - i - 1;
        char let = 'x' + ri;
        char let_loop = 'i' + ri;
        string thread = "";

        string block = "";

        string num_elem = "";
        if (ri < 2) {
            thread = "threads.";
            thread += let;

            block = "blocks.";
            block += let;

            num_elem = "num_elem_";
            num_elem += let;

        }

        string base = "base_";
        base += let_loop;

        string idx = to_string(i);

        if (ri < 2) {
            handlerTxt += num_elem + ", ";
        }
        handlerTxt += base + ", ";
        handlerTxt += "loopSteps[" + idx + "], ";
        handlerTxt += "idxs[" + idx + "]";
        if (i > 0)
            handlerTxt += ", ";
    }
    for (int i = 0; i < loopInfo.reductions.size(); ++i) {
        tuple <ClauseReduction, QualType> cur_red = loopInfo.reductions[i];
        ClauseReduction red;
        QualType rt;
        tie(red, rt) = cur_red;  //note: clion treats this line as error, don't worry, the line is fine
        string type = rt.getAsString();
        string name = red.arrayName;

        handlerTxt += ", " + name + ", " + name + "_grid";

    }
    handlerTxt += ");\n";
    handlerTxt += "    }\n";

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





    handlerTxt += "\n\n";
    handlerTxt += "extern \"C\" void " + handlerName +"(";

    handlerTxt.append("DvmType *pLoopRef, ");
    for (const auto & hdr : arr_hdrs) {
        handlerTxt.append(hdr.type + " " + hdr.name + "[]");
    }
    for (const auto & hdr : sclr_hdrs) {
        handlerTxt.append(", " + hdr.type + " " + hdr.name + "[]");
    }
    handlerTxt.append(")\n");
    handlerTxt.append("{\n");

    handlerTxt += "    int dep_mask = dvmh_loop_get_dependency_mask_C(*pLoopRef);\n";

    handlerTxt += "    if (";



    for (int i = 1; i < (1 << loopDims); i = i << 1) {
        if (i > 1)
            handlerTxt += " || ";
        handlerTxt += "dep_mask == " + to_string(i);
    }

    handlerTxt += ") {\n";
    handlerTxt += "        " + handlerCaseName + "(pLoopRef";

    for (const auto & hdr : arr_hdrs) {
        handlerTxt.append(", " + hdr.name);
    }
	for (const auto & hdr : sclr_hdrs) {
        handlerTxt.append(", " + hdr.name);
    }
    handlerTxt.append(", dep_mask);\n    }\n}\n");

    return handlerTxt;
}



string AcrossGen::GenKernel()
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
        kernelTxt += arrs[i].type + " " + arrs[i].name + "[], ";
		for (int j = 1; j <= loopDims; j++)
			kernelTxt += hdr_type + " " + hdr + to_string(j) + ", ";
	}
	for (auto i = sclr_ptrs.begin(); i != sclr_ptrs.end(); ++i) {
		kernelTxt += (*i).type + " " + (*i).name + ", ";
	}

    for (int i = loopDims - 1; i >= 0; --i) {
        int ri = loopDims - i - 1;
        char let = 'x' + ri;
        char let_loop = 'i' + ri;
        string thread = "";

        string block = "";

        string num_elem = "";
        if (ri < 2) {
            thread = "threads.";
            thread += let;

            block = "blocks.";
            block += let;

            num_elem = "num_elem_";
            num_elem += let;

        }

        string base = "base_";
        base += let_loop;

        string idx = to_string(i);

        if (ri < 2) {
            kernelTxt += "DvmType " + num_elem + ", ";
        }
        kernelTxt += "DvmType " + base + ", ";
        kernelTxt += "DvmType loopSteps_" + idx + ", ";
        kernelTxt += "DvmType idxs_" + idx + "";
        if (i > 0)
            kernelTxt += ", ";
    }
    for (int i = 0; i < loopInfo.reductions.size(); ++i) {
        tuple <ClauseReduction, QualType> cur_red = loopInfo.reductions[i];
        ClauseReduction red;
        QualType rt;
        tie(red, rt) = cur_red;  //note: clion treats this line as error, don't worry, the line is fine
        string type = rt.getAsString();
        string name = red.arrayName;

        kernelTxt += ", " + type + " " + name + ", " + type + " * " + name + "_grid";

    }
    kernelTxt += ")\n";
    kernelTxt += "{\n";

	for (auto i = 0; i < arrs.size(); i++) {
		string name = arr_bases[i].name;
		string type = arr_bases[i].type;
		kernelTxt += "    " + type + " " + name + " = " + arrs[i].name + ";\n";
	}

	for (auto i = 0; i < sclrs.size(); ++i) {
		kernelTxt += "    " + sclrs[i].type + " & " + sclrs[i].name + " = *" + sclr_ptrs[i].name + ";\n";
	}

    kernelTxt += "\n";
    kernelTxt += "    /* User variables - loop index variables and other private variables */\n";

    for (auto i = loopInfo.loopVars.begin(); i != loopInfo.loopVars.end(); ++i) {
        kernelTxt += "    int " + (*i).name + ";\n";
    }

    for (auto i = loopInfo.privates.begin(); i != loopInfo.privates.end(); ++i) {
        kernelTxt += "    " + (*i).second.getAsString() + " " + (*i).first + ";\n";
    }

    for (auto && i : loopInfo.reductions) {

        ClauseReduction red;
        QualType rt;
        tie(red, rt) = i;
        string var_name = red.arrayName;

        kernelTxt += "    extern __shared__ " + rt.getAsString() + " " + var_name + "_block[];\n";

    }
    kernelTxt += "\n";

    kernelTxt += "    DvmType coords[" + to_string(loopDims) + "];\n";
    kernelTxt += "    DvmType id_x, id_y;\n";
    kernelTxt += "    DvmType red_idx1, red_idx2;\n";

    kernelTxt += "\n";

    kernelTxt += "    id_x = blockIdx.x * blockDim.x + threadIdx.x;\n";
    kernelTxt += "    id_y = blockIdx.y * blockDim.y + threadIdx.y;\n";

    kernelTxt += "\n";

    string indent = "    ";
    if (loopDims > 1) {
        indent += "    ";

        kernelTxt += "    if (id_x < num_elem_x";
        if (loopDims > 2) {
            kernelTxt += " && id_y < num_elem_y";
        }
        kernelTxt += ") {\n";
    }

    for (int i = 0; i < loopDims; i++) {
        string idx = to_string(i);
        kernelTxt += indent + "coords[idxs_" + idx + "] = base_";
        kernelTxt += (char)('i' + i);
        if (i > 0 && i < 3) {
            kernelTxt += " + id_";
            kernelTxt += (char)('x' + i - 1);
            kernelTxt += " * loopSteps_" + to_string(loopDims-i);
        }
        kernelTxt += ";\n";
    }
    for (int i = 0; i < loopDims; i++) {
        string idx = to_string(i);
        kernelTxt += indent;
        kernelTxt += (char)('i' + i);
        kernelTxt += " = coords[" + idx +"];\n";
    }

    kernelTxt += "\n";

    loopTxt.clear();
    TraverseFunctionDecl(funcDecl);
    kernelTxt += indent + rw.getRewrittenText(loopRange) + "\n    }\n";

    //Paste reduction vars


    for (int i = 0; i < loopInfo.reductions.size(); ++i) {
        tuple <ClauseReduction, QualType> cur_red = loopInfo.reductions[i];
        ClauseReduction red;
        QualType rt;
        tie(red, rt) = cur_red;  //note: clion treats this line as error, don't worry, the line is fine
        string type = rt.getAsString();
        string name = red.arrayName;

        kernelTxt += "\n// Reduction for var " + name + "\n";

        kernelTxt += "    id_x = blockDim.x * blockDim.y * blockDim.z / 2;\n";

        kernelTxt += "    red_idx1 = threadIdx.x + threadIdx.y * blockDim.x + threadIdx.z * (blockDim.x * blockDim.y);\n";
        kernelTxt += "    " + name + "_block[red_idx1] = " + name + ";\n";
        kernelTxt += "    __syncthreads();\n";
        kernelTxt += "    red_idx2 = id_x;\n";
        kernelTxt += "    while (red_idx2 >= 1) {;\n";
        kernelTxt += "        __syncthreads();\n";
        kernelTxt += "        if (red_idx1 < red_idx2) {\n";
        kernelTxt += "            " + name + "_block[red_idx1] = " + red.toOpenMP() + "("
                + name + "_block[red_idx1], " + name + "_block[red_idx1 + red_idx2]);        }\n";

        kernelTxt += "            red_idx2 = red_idx2 / 2;\n    }\n";

        kernelTxt += "    if (red_idx1 == 0) {\n";
        kernelTxt += "        " + name + "_grid[blockIdx.x + (blockIdx.y + blockIdx.z * gridDim.y) * gridDim.x] = "
                + red.toOpenMP() + "(" + name + "_grid[blockIdx.x + (blockIdx.y + blockIdx.z * gridDim.y) * gridDim.x], "
                + name + "_block[0]);\n    }\n";


    }

    kernelTxt += "}\n";

    return kernelTxt;
}
