@echo off
1>nul copy /y %1\STANDARD %2
rem requires sorted file-system
for %%a in (%1\*) do if %%a neq STANDARD 1>nul copy /b /y %2+%%a %2
