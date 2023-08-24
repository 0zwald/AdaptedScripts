@ECHO OFF
:: NAME: DCPortTest.CMD v1.1 https://www.radians.com.ar/blog/?p=3640
:: Adapted by Oswaldo Ortiz to query dynamic ports identified over 135.
:: PURPOSE: Test connectivity from one DC to one or more remote DCs
:: using PORTQRY utility.
:: The SERVERS.TXT contains a list of servers (one server per line)
:: to check connectivity to.

ECHO DATE: %DATE% > DC_PORTQRY.TXT
ECHO TIME: %TIME% >> DC_PORTQRY.TXT
ECHO USER: %USERNAME% >> DC_PORTQRY.TXT
ECHO COMPUTER: %COMPUTERNAME% >> DC_PORTQRY.TXT
ECHO. >> DC_PORTQRY_rpc.TXT
ECHO. >> DC_PORTQRY.TXT
ECHO. >> DC_PORTQRY.TXT
ECHO. >> DC_PORTQRY.TXT
ECHO "Hostname/IP","Port","Result" >> DC_PORTQRY.TXT

FOR /F "tokens=1" %%i IN (servers.txt) DO (
  ECHO Testing %%i
  ECHO. >> DC_PORTQRY.TXT
  ECHO. > DC_PORTQRY_rpc.TXT
  FOR %%p IN (135 389 636 3268 3269 53 88 445 464) DO (
    FOR /F "tokens=* USEBACKQ" %%F IN (
      `PORTQRY -n %%i -e %%p -p TCP ^| findstr /i "%%p"`
    ) DO (
      SET "var=%%F"
      ECHO %%i,%%p,%%F >> DC_PORTQRY.TXT
    )

    IF %%p==135 (

      FOR /F "tokens=* USEBACKQ" %%R IN (
        `PORTQRY -n %%i -e %%p -p TCP `
      ) DO (
        SET "var=%%R"
        ECHO %%R >> DC_PORTQRY_rpc.TXT
      )
      setlocal enabledelayedexpansion

      set "concatenateNextLine="
      for /f "delims=" %%a in (DC_PORTQRY_rpc.TXT) do (
        set "line=%%a"
        if "!concatenateNextLine!"=="1" (
          set "concatenateNextLine="
          if "!line:ncacn_ip_tcp=!" neq "!line!" (
            set "result=!previousLine! !line!"
            :: Extract number between "[" and "]" in the line
            set "number="
            for /f "tokens=2 delims=[]" %%n in ("!result!") do (
              set "number=%%n"
            )
              FOR /F "tokens=* USEBACKQ" %%F IN (
                `PORTQRY -n %%i -e !number! -p TCP ^| findstr /i "!number!"`
              ) DO (
                SET "var=%%F"
                ECHO %%i,!number!,%%F >> DC_PORTQRY.TXT
              )

          )
        )
        if "!line:Directory=!" neq "!line!" (
          set "concatenateNextLine=1"
        )
        set "previousLine=!line!"
      )

      endlocal
    )
  )
  ECHO. >> DC_PORTQRY.TXT
  ECHO. >> DC_PORTQRY.TXT
)
