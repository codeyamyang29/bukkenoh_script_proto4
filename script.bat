@echo off
net file 1>nul 2>nul && goto :run || powershell -ex unrestricted -Command "Start-Process -Verb RunAs -FilePath '%comspec%' -ArgumentList '/c %~fnx0 %*'"
goto :eof
:run
pushd %~dp0
set env=./environment.txt
set config=./cfg.txt
set htaccess=./htaccess.txt
set mypath=%cd%
SETLOCAL enabledelayedexpansion
for /f "tokens=2 delims==" %%a in ('findstr /I "saveLocation=" !config!') do set "key_cloneLoc=%%a";
for /f "tokens=2 delims==" %%a in ('findstr /I "gitRepositoryUrl=" !config!') do set "key_cloneUrl=%%a";
@REM example url : https://bukkenoh.backlog.com/git/U0323/drp-estate.com.git
@REM REMOVE ex. https://bukkenoh.backlog.com/git/U0323/
for /f "tokens=5,6 delims=/" %%a in ("!key_cloneUrl!") do (
    set "key_cloneName=%%a"
);
@REM result of cloneName = drp-estate.com.git
@REM REMOVE .git
set key_cloneName=!key_cloneName:~0,-4!
@REM set laragon root
set laragon_root=!key_cloneLoc:~0,-4!
@REM
echo ============================================================================================================
echo =	PLEASE CHECK 
echo =	1. cfg.txt is correct
echo =	2. NODE VERSION 8.15.0
echo =	3. PHP VERSION 8.2.6
echo =	4. COMPOSER 2.5.8
echo =	
echo =	CURRENT CONFIG
echo =	1. laragon = !key_cloneLoc!
echo =	2. Git Url = !key_cloneUrl!
echo =	3. Expected Result = !key_cloneLoc!\!key_cloneName!
echo ============================================================================================================
echo .
echo .
pause
echo ============================================================================================================
echo =	cloning git
echo ============================================================================================================

cd !key_cloneLoc!
echo %CD%
git clone !key_cloneUrl!
cd !key_cloneLoc!\!key_cloneName!
echo ============================================================================================================
echo =	setup laravel
echo ============================================================================================================
cd laravel
echo %CD%
@REM check composer version 
@REM *version 2.0 causes error with laravel json
for /f "tokens=3" %%a in ('composer -V') do set version=%%a
for /f "delims=. tokens=1" %%a in ("%version%") do set version_root=%%a 
for /f "tokens=3" %%a in ('composer -V') do set version=%%a
for /f "delims=. tokens=1" %%a in ("%version%") do set version_root=%%a
IF !version_root! LEQ 2 (
    call composer install
    call composer update
    goto:continue
) ELSE (
    @REM rollback to version 1.*
    call composer self-update --1
    call composer install && composer update
    goto:continue
)
GOTO :EOF
:continue
echo .
echo .
echo ============================================================================================================
echo =	copying htaccess
echo ============================================================================================================
cd .. 
echo !mypath!\htaccess.txt to %CD%
cp !mypath!\htaccess.txt .htaccess
GOTO :yarn
GOTO :EOF

:yarn
IF EXIST "src" (
    echo ============================================================================================================
    echo =	setup yarn
    echo ============================================================================================================
    cd src
    echo %CD%
    call yarn install --silent
    echo .
    echo .
    GOTO :laragon
) ELSE (
    echo ============================================================================================================
    echo =	skipping yarn setup
    echo ============================================================================================================
    echo .
    echo .
    GOTO :laragon
)
GOTO :EOF

:laragon
echo ============================================================================================================
echo =	RESTARTING LARAGON !!!!
echo ============================================================================================================
echo terminate laragon related exe
call taskkill /IM "laragon.exe" /T /F 
echo open laragon
start "" %laragon_root%\laragon.exe
echo .
echo .
echo .
echo ============================================================================================================
echo =  Setup Complete (1/2)
echo ============================================================================================================
echo .
GOTO :prompt_user
GOTO :EOF

:prompt_user
set /p p_edit_env= " Do you want to set up env.user_id and env.store_id? (y/n): "
IF "!p_edit_env!"=="y" (
    goto:action_edit_env;
) ELSE IF "!p_edit_env!"=="n" (
    goto:action_skip_env;
    echo .
    echo .
) ELSE (
    echo ** Wrong input try again! **
    goto:prompt_user;
)
GOTO :EOF
:action_edit_env
set /p p_edit_user_id= "Set user_id: "
set /p p_edit_store_id= "Set store_id: "
goto:execute_edit_env;
pause
GOTO :EOF

:execute_edit_env
cd !key_cloneLoc!\!key_cloneName!\laravel
echo current path: %cd%
echo .
echo .

IF EXIST "temp.txt" (
    DEL temp.txt
    goto:inject_user_store_ids
) ELSE (
    goto:inject_user_store_ids  
)
pause
GOTO :EOF



:inject_user_store_ids
@REM CREATE A TEMP FILE WITH THE USER_ID AND STORE_ID
(
  TYPE %mypath%\environment.txt
  echo USER_ID=%p_edit_user_id%
  echo STORE_ID=%p_edit_store_id%
) >> temp.txt
cp temp.txt .env
DEL temp.txt 
pause
goto:end
GOTO :EOF


:action_skip_env
echo .
echo .
echo ============================================================================================================
echo =  Setup Incomplete (skipped) (2/2) - *Manually setup the env user_id and store_id 
echo ============================================================================================================
echo .
echo .
pause
echo ============================================================================================================
echo =	STARTING THE WEBSITE
echo ============================================================================================================
start http://%key_cloneName%.test/cmd/makecache
exit
GOTO :EOF

:end
echo .
echo .
echo ============================================================================================================
echo =  Setup Complete (2/2)
echo ============================================================================================================
echo .
echo .
pause
echo .
echo .
echo ============================================================================================================
echo =	STARTING THE WEBSITE
echo ============================================================================================================
start http://%key_cloneName%.test/cmd/makecache
exit
GOTO :EOF
