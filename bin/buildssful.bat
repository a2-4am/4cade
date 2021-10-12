@echo off
1>nul copy /y nul %2
for %%a in (%1\*) do 1>nul copy /b /y %2+%%a %2
