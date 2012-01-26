-- Lake file for luaclang

local needs = { "clang", "llvm", "lua" }

LLVM_LIBS = "LLVMRuntimeDyld LLVMObject LLVMLinker LLVMipo LLVMJIT LLVMExecutionEngine LLVMDebugInfo LLVMBitWriter LLVMX86Disassembler LLVMX86AsmParser LLVMX86CodeGen LLVMX86Desc LLVMX86AsmPrinter LLVMX86Utils LLVMX86Info LLVMArchive LLVMBitReader LLVMSelectionDAG LLVMAsmPrinter LLVMMCParser LLVMCodeGen LLVMScalarOpts LLVMInstCombine LLVMTransformUtils LLVMipa LLVMAnalysis LLVMTarget LLVMCore LLVMMC LLVMSupport"

CLANG_LIBS = "clangFrontend clangLex clangParse clangDriver clangCodeGen clangSema clangSerialization clangAnalysis clangAST clangBasic"

if PLAT == "Darwin" then

	LLVM_DIR = 'osx/llvm-3.0'
	CLANG_DIR = 'osx/llvm-3.0'

elseif PLAT == "Linux" then

	-- currently assumes 64-bit...
	LLVM_DIR = 'linux/llvm-3.0'
	CLANG_DIR = 'linux/llvm-3.0'

	needs[#needs+1] = "pthread"
	PTHREAD_DIR = '/usr/'
	PTHREAD_LIBS = 'pthread'

else
	error (PLAT .. " not supported")
end

cpp.shared{ 
	'clang', 
	-- source files:
	src = {
		'src/Compiler.cpp',
		'src/luaopen_clang.cpp', 
	},
	-- LLVM needs these defines / flags:
	defines = {
		"NDEBUG",
		"_GNU_SOURCE",
		"__STDC_LIMIT_MACROS", 
		"__STDC_CONSTANT_MACROS",
		"__STDC_FORMAT_MACROS",
	},
	flags = "-fno-rtti -fomit-frame-pointer -fno-exceptions -fPIC -O3",
	--flags = "-fno-rtti -fomit-frame-pointer -fno-exceptions -fPIC -O3 -Woverloaded-virtual -Wcast-qual",
	-- library dependencies:
	needs = needs,
	-- put results in debug / release folders 
	--odir = true,	
}
