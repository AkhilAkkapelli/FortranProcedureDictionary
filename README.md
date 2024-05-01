# FortranProcedureDictionary

## Description
Fortran Procedure Dictionary parses Fortran source files and extract information about procedures such as main programs, modules, functions, and subroutines. It utilizes the ANTLR4 library through PyCall to parse Fortran syntax and generates a text file containing the extracted procedure details.

## Features
- **Procedure Extraction**: Parses Fortran source files to extract information about main programs, modules, functions, and subroutines.
- **Recursive Procedure Handling with Argument Extraction**: Identifies recursive functions and subroutines, extracts their input and output arguments, and maintains a parent stack for hierarchical context tracking.
- **Command-Line Interface**: Offers a command-line interface for specifying the input directory containing Fortran files and the output file path for storing extracted procedure details.
- **Text File Output**: Outputs the extracted procedure details into a text file for easy access and further analysis.

## Dependencies
- **Julia**: Programming language used for implementing the Fortran Procedure Dictionary.
  - Install Julia: [Download and installation instructions](https://julialang.org/downloads/)
  - **Julia Modules**:
    - PyCall: Julia package for interfacing with Python modules.
      ```julia
      using Pkg
      Pkg.add("PyCall")
      ```
    - ArgParse: Julia package for command-line argument parsing.
      ```julia
      using Pkg
      Pkg.add("ArgParse")
      ```
- **Python**: Required for interfacing with the ANTLR4 Python modules.
  - Install Python: [Download and installation instructions](https://www.python.org/downloads/)
  - **Python Modules**:
    - antlr4: Lexer and parser generator used for parsing Fortran 90 source files.
      ```bash
      pip3 install antlr4-python3-runtime
      ```
## How to Use
1. **Installation**: Ensure all the dependencies are installed on your system.
2. **Clone the Repository**: Clone the Fortran Procedure Dictionary repository to your local machine.
3. **Navigate to Repository Directory**: Open a terminal and navigate to the directory where the repository is cloned.
4. **Run the Program**: Execute the program by running on example program.
   ```bash
   julia FPDFortran90.jl TestProgram/ TestProgram/TestProgramDictionary.txt
5. **View Procedure Dictionary**: Open the generated text file containing the extracted procedure details.

## License
This project is licensed under the MIT License.
