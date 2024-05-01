# Importing necessary modules and packages
include("ProcedureDictionary/ProcedureDictionary.jl")

# Importing PyCall to interact with Python modules
using PyCall

# Importing Data Structure routines for Dictionary
import .ProcedureDictionaryMod: newProcedureDictionary, add_procedure_detail!, get_procedure_dictionary
# Importing ArgParse for command-line argument parsing
import ArgParse: ArgParseSettings, parse_args, @add_arg_table!  

# Importing antlr4 Python modules
const antlr4 = pyimport("antlr4")

const ParseTreeWalker = antlr4.ParseTreeWalker
const FileStream = antlr4.FileStream
const CommonTokenStream = antlr4.CommonTokenStream

# Adding current directory to Python sys path
pushfirst!(PyVector(pyimport("sys")."path"), pwd())  

# Import necessary modules from the local Python files
const Fortran90Lexer = pyimport("Fortran90Grammer.Fortran90Lexer")  
const Fortran90Parser = pyimport("Fortran90Grammer.Fortran90Parser")

Fortran90ParserListener = pyimport("Fortran90Grammer.Fortran90ParserListener")

# Defining a Julia struct representing a listener for Fortran90Parser events
@pydef mutable struct FSEFortran90Listener <: Fortran90ParserListener.Fortran90ParserListener
  function __init__(self, root::String)
    self.root = root
    self.parentStack = [root]
    self.proc_dict = newProcedureDictionary()
  end

  function enterMainProgram(listener::PyObject, ctx::PyObject)
    # Retrieving program name from context
    programName = ""
    if ctx.programStmt() !== nothing
      programName = ctx.programStmt().NAME().getText()
    end
    # Updating parent stack with program name
    listener.parentStack = [listener.parentStack..., programName]  
  end
   
  function exitMainProgram(listener::PyObject, ctx::PyObject)
    listener.parentStack = listener.parentStack[1:end-1] 
  end   

  function enterModule(listener::PyObject, ctx::PyObject)
    # Retrieving module name from context
    moduleName = ctx.moduleStmt().moduleName().ident().NAME().getText()  
    listener.parentStack = [listener.parentStack..., moduleName]
  end
    
  function exitModule(listener::PyObject, ctx::PyObject)
    listener.parentStack = listener.parentStack[1:end-1] 
  end

  function enterFunctionSubprogram(listener::PyObject, ctx::PyObject)
    functionName = ctx.functionName().NAME().getText() 
    
    # Checking if function is recursive
    recursive = false
    if ctx.functionPrefix().recursive() !== nothing
        recursive = true
    end
    
    args = String[]
    # Retrieving function arguments
    functionParListCtx = ctx.functionRange().functionParList().functionPars()
    if functionParListCtx !== nothing
      for argCtx in functionParListCtx.functionPar()
        # Collecting function arguments
        args = [args..., argCtx.dummyArgName().NAME().getText()]
      end
    end

    result = ""
    if ctx.functionRange().RESULT() !== nothing
      # Retrieving function result
      result = ctx.functionRange().NAME().getText() 
    end
    
    # Adding function details to procedure dictionary
    add_procedure_detail!(listener.proc_dict, functionName, listener.root, listener.parentStack, recursive, args, true, result)
    listener.parentStack = [listener.parentStack..., functionName]
  end
    
  function exitFunctionSubprogram(listener::PyObject, ctx::PyObject)
      listener.parentStack = listener.parentStack[1:end-1]
  end

  function enterSubroutineSubprogram(listener::PyObject, ctx::PyObject)
    subroutineName = ctx.subroutineName().NAME().getText()
    recursive = false
    if ctx.RECURSIVE() !== nothing
      recursive = true
    end 

    args = String[]
    # Retrieving subroutine arguments
    subroutineParListCtx = ctx.subroutineRange().subroutineParList().subroutinePars()
    if subroutineParListCtx !== nothing
      for argCtx in subroutineParListCtx.subroutinePar()
        if argCtx.dummyArgName() !== nothing
          # Collecting subroutine arguments
          args = [args..., argCtx.dummyArgName().NAME().getText()]  
        elseif argCtx.STAR() !== nothing
          args = [args..., argCtx.STAR().getText()]
        end
      end
    end        

    # Adding subroutine details to procedure dictionary
    add_procedure_detail!(listener.proc_dict, subroutineName, listener.root, listener.parentStack, recursive, args, false, "")
    listener.parentStack = [listener.parentStack..., subroutineName]  
  end

  function exitSubroutineSubprogram(listener::PyObject, ctx::PyObject)
    listener.parentStack = listener.parentStack[1:end-1]
  end
end

# Function for processing all files in a directory
function process_directory(directoryPath::String, listener::PyObject)
  for file in readdir(directoryPath)
    # Checking file extension
    if endswith(file, ".f90") || endswith(file, ".f95") || endswith(file, ".f03")  
      filePath = joinpath(directoryPath, file)
      # Processing each source file
      process_source_file(filePath, listener)  
    end
  end
end

# Function for processing a single source file
function process_source_file(filePath::String, listener::PyObject)
  input = antlr4.FileStream(filePath)
  lexer = Fortran90Lexer.Fortran90Lexer(input)
  tokens = antlr4.CommonTokenStream(lexer)
  parser = Fortran90Parser.Fortran90Parser(tokens)
  tree = parser.program()
  # Setting the root name as the base name of the file
  listener.root = basename(filePath)
  # Initializing parent stack with file path
  listener.parentStack = [filePath]  
  walker = ParseTreeWalker()
  # Walking the parse tree with the listener
  walker.walk(listener, tree)
end

# Setting up command-line arguments
settings = ArgParseSettings()
@add_arg_table! settings begin
  "inputDirectory"
    help = "Path to the input directory containing Fortran files"
    required = true
  "outputFilePath"
    help = "Path to the output file (.txt)"
    required = true
end
# Parsing command-line arguments
parsed_args = parse_args(settings)

# Retrieving input directory path from parsed arguments
inputDirectory = parsed_args["inputDirectory"]  
# Retrieving output file path from parsed arguments
outputFilePath = parsed_args["outputFilePath"]  

# Initializing the listener with an empty root name
listener = FSEFortran90Listener("")  

try
  process_directory(inputDirectory, listener)
  
  # Getting the procedure dictionary content
  content = get_procedure_dictionary(listener.proc_dict)  

  open(outputFilePath, "w") do f
    # Writing content to the output file
    write(f, content)  
  end
  println("Text file created successfully at: ", outputFilePath)
# Handling unexpected errors
catch e 
  println("An unexpected error occurred:", e)  
  rethrow()
end
