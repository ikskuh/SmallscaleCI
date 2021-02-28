@ECHO OFF
SET "PATH=C:\CI\bin;%PATH%"

RMDIR /S /Q C:\CI\work 
RMDIR /S /Q C:\CI\artifacts
MKDIR C:\CI\work|| goto fatal
MKDIR C:\CI\artifacts|| goto fatal

ECHO failure > C:\CI\result

CD /D C:\CI\work || goto err
ftz get ftz://192.168.122.1/task.bat || goto err
CALL task.bat || goto err
ECHO success > C:\CI\result

:err
CD /D C:\CI\work 
TYPE C:\CI\result

FOR /R C:\CI\artifacts %%f in (*) do (
	ftz put "%%f" "ftz://192.168.122.1/%%~nf"
)

ftz put C:\CI\result ftz://192.168.122.1/result

shutdown /s /t 0

:fatal
pause
