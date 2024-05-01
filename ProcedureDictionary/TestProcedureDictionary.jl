include("ProcedureDictionary.jl")

import .ProcedureDictionaryMod: newProcedureDictionary, add_procedure_detail!, get_procedure_dictionary

# Create a ProcedureDictionary
proc_dict = newProcedureDictionary()

# Example 1: Adding details for a subroutine
add_procedure_detail!(
    proc_dict,
    "subroutine_1",
    "file1.f90",
    ["Files/file1.f90", "module_1"],
    false,  
    ["arg1", "arg2", "arg3"],
    false,
    ""
)

# Example 2: Adding details for a function
add_procedure_detail!(
    proc_dict,
    "function_1",
    "file1.f90",
    ["Files/file1.f90", "module_1", "subroutine_1"],
    true,  # Recursive function
    ["arg1", "arg2"],
    true,   # Is a function
    "result_1",
)

# Example 3: Adding details for another subroutine
add_procedure_detail!(
    proc_dict,
    "subroutine_1",
    "file2.f90",
    ["Files/file2.f90", "module_2"],
    true,
    ["arg1", "arg2"],
    false,
    "" 
)

# Example 4: Adding details for another function
add_procedure_detail!(
    proc_dict,
    "function_1",
    "file2.f90",
    ["Files/file2.f90", "module_2"],
    false,
    ["arg1"],
    true,
    "result_1",
)

# Example 5: Adding details for a recursive subroutine
add_procedure_detail!(
    proc_dict,
    "recursive_subroutine_1",
    "file2.f90",
    ["Files/file2.f90", "module_2", "function_1"],
    true,  # Recursive subroutine
    ["arg1", "arg2", "arg3"],
    false,  # Not a function
    ""  
)

# Print the contents of the ProcedureDictionary
println(get_procedure_dictionary(proc_dict))
