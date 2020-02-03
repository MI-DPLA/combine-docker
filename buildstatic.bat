setlocal enableextensions
set workdir=%cd%
set livy_tagged_release="v0.6.0-incubating"
set spark_version="2.3.2"


cd %workdir%\combine\combine
if not exist "%cd%\static\js\" (
  md %cd%\static\js\
)
robocopy /s %cd%\core\static\ static\
if not exist "%workdir%\external-static\livy\" (
  md %workdir%\external-static\livy
)
cd %workdir%\external-static\livy
svn export --force https://github.com/apache/incubator-livy/tags/%livy_tagged_release%/server/src/main/resources/org/apache/livy/server/ui/static/js/
robocopy /s %cd%\js\ %workdir%\combine\combine\static\js\
if not exist "%workdir%\external-static\spark\" (
  md %workdir%\external-static\spark
)
cd %workdir%\external-static\spark
svn export --force https://github.com/apache/spark/tags/v%spark_version%/core/src/main/resources/org/apache/spark/ui/static
robocopy /s %cd%\static\ %workdir%\combine\combine\static\
cd %workdir%\combine\combine\static
for /r %%f in (*) do @copy "%%f" .
copy *.js %cd%\js
