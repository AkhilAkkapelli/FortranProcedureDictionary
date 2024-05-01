module ProcedureDictionaryMod

export newProcedureDictionary, add_procedure_detail!, get_procedure_dictionary

struct ProcedureDetails
  file_name      :: String
  container      :: Vector{String}
  is_recursive   :: Bool
  input_arguments:: Vector{String}
  is_function    :: Bool
  result         :: String
end

struct ProcedureDictionary
  procedures::Dict{String, Vector{ProcedureDetails}}
end

function newProcedureDictionary()
    return ProcedureDictionary(Dict{String, Vector{ProcedureDetails}}())
end

function add_procedure!( proc_dict::ProcedureDictionary, procedure_name::String, details::ProcedureDetails )
  if haskey(proc_dict.procedures, procedure_name)
    push!(proc_dict.procedures[procedure_name], details)
  else
    proc_dict.procedures[procedure_name] = [details]
  end
end

function add_procedure_detail!(
  proc_dict::ProcedureDictionary,
  procedure_name::String,
  file_name::String,
  container::Vector{String},
  is_recursive::Bool,
  input_arguments::Vector{String},
  is_function::Bool,
  result::String
)
  details = ProcedureDetails( file_name, container, is_recursive, input_arguments, is_function, result )
  add_procedure!(proc_dict, procedure_name, details)
end

function get_procedure_dictionary(proc_dict::ProcedureDictionary)
  output = "Procedure Dictionary:\n\n"
  for (procedure_name, details_list) in proc_dict.procedures
    output *= "Procedure Name: $procedure_name\n"
    for details in details_list
      output *= "   File Name: $(details.file_name)\n"
      output *= "   Container: $(details.container)\n"
      output *= "   Is Recursive: $(details.is_recursive)\n"
      output *= "   Input Arguments: $(details.input_arguments)\n"
      output *= "   Is Function: $(details.is_function)\n"
      output *= "   Result: $(details.result)\n\n"
    end
  end
  return output
end

end # module
