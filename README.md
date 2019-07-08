# Pester-TestingTools
# https://github.com/opensequence

#Testing Functions for use when testing Scripts using Pester
#Especially when scripts contain functions within the same file
#Remove-FunctionsFromScript - reads in a script and outputs a List containing all Scripts lines (excluding Functions)
#New-FunctionFromScript - reads in a List of Script lines and wraps it in a function start and end and writes to file.
#Copy-FunctionsFromScript - reads in a script and creates a new file containing just the functions from the source script