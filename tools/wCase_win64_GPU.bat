@echo off

rem "name" and "dirout" are named according to the testcase

set name=test2
set dirout=%name%_out
set diroutdata=%dirout%\data

rem "executables" are renamed and called from their directory

set dirbin=C:\Users\hamme\Documents\300_analysis\DualSPHysics_v4.2\bin\windows
set gencase="%dirbin%/GenCase4_win64.exe"
set dualsphysicscpu="%dirbin%/DualSPHysics4.2CPU_win64.exe"
set dualsphysicsgpu="%dirbin%/DualSPHysics4.2_win64.exe"
set boundaryvtk="%dirbin%/BoundaryVTK4_win64.exe"
set partvtk="%dirbin%/PartVTK4_win64.exe"
set partvtkout="%dirbin%/PartVTKOut4_win64.exe"
set measuretool="%dirbin%/MeasureTool4_win64.exe"
set computeforces="%dirbin%/ComputeForces4_win64.exe"
set isosurface="%dirbin%/IsoSurface4_win64.exe"
set flowtool="%dirbin%/FlowTool4_win64.exe"
set floatinginfo="%dirbin%/FloatingInfo4_win64.exe"

rem "dirout" to store results is removed if it already exists
if exist %dirout% rd /s /q %dirout%

rem CODES are executed according the selected parameters of execution in this testcase

rem Executes GenCase4 to create initial files for simulation.
%gencase% %name%_Def %dirout%/%name% -save:all
if not "%ERRORLEVEL%" == "0" goto fail

rem Executes DualSPHysics to simulate SPH method.
%dualsphysicsgpu% -gpu %dirout%/%name% %dirout% -dirdataout data -svres
if not "%ERRORLEVEL%" == "0" goto fail

rem Executes PartVTK4 to create VTK files with particles.
set dirout2=%dirout%\particles
%partvtk% -dirin %diroutdata% -savevtk %dirout2%/PartFluid -onlytype:-all,+fluid
if not "%ERRORLEVEL%" == "0" goto fail

rem Executes PartVTKOut4 to create VTK files with excluded particles.
%partvtkout% -dirin %diroutdata% -savevtk %dirout2%/PartFluidOut -SaveResume %dirout2%/_ResumeFluidOut
if not "%ERRORLEVEL%" == "0" goto fail

rem Executes MeasureTool4 to create VTK files with velocity and a CSV file with velocity at each simulation time.
rem set dirout2=%dirout%\measuretool
rem %measuretool% -dirin %diroutdata% -points CaseDambreak_PointsVelocity.txt -onlytype:-all,+fluid -vars:-all,+vel.x,+vel.m -savevtk %dirout2%/PointsVelocity -savecsv %dirout2%/_PointsVelocity
rem if not "%ERRORLEVEL%" == "0" goto fail

rem Executes MeasureTool4 to create VTK files with incorrect pressure and a CSV file with value at each simulation time.
rem %measuretool% -dirin %diroutdata% -points CaseDambreak_PointsPressure_Incorrect.txt -onlytype:-all,+fluid -vars:-all,+press,+kcorr -kcusedummy:0 -kclimit:0.5 -savevtk %dirout2%/PointsPressure_Incorrect -savecsv %dirout2%/_PointsPressure_Incorrect
rem if not "%ERRORLEVEL%" == "0" goto fail

rem rem Executes MeasureTool4 to create VTK files with correct pressure and a CSV file with value at each simulation time.
rem %measuretool% -dirin %diroutdata% -points CaseDambreak_PointsPressure_Correct.txt -onlytype:-all,+fluid -vars:-all,+press,+kcorr -kcusedummy:0 -kclimit:0.5 -savevtk %dirout2%/PointsPressure_Correct -savecsv %dirout2%/_PointsPressure_Correct
rem if not "%ERRORLEVEL%" == "0" goto fail

rem rem Executes ComputeForces to create a CSV file with force at each simulation time.
rem set dirout2=%dirout%\forces
rem %computeforces% -dirin %diroutdata% -onlymk:21 -savecsv %dirout2%/_ForceBuilding
rem if not "%ERRORLEVEL%" == "0" goto fail

rem Executes IsoSurface4 to create VTK files with surface fluid and slices of surface.
set dirout2=%dirout%\surface
set planesy="-slicevec:0:0.1:0:0:1:0 -slicevec:0:0.2:0:0:1:0 -slicevec:0:0.3:0:0:1:0 -slicevec:0:0.4:0:0:1:0 -slicevec:0:0.5:0:0:1:0 -slicevec:0:0.6:0:0:1:0"
set planesx="-slicevec:0.1:0:0:1:0:0 -slicevec:0.2:0:0:1:0:0 -slicevec:0.3:0:0:1:0:0 -slicevec:0.4:0:0:1:0:0 -slicevec:0.5:0:0:1:0:0 -slicevec:0.6:0:0:1:0:0 -slicevec:0.7:0:0:1:0:0 -slicevec:0.8:0:0:1:0:0 -slicevec:0.9:0:0:1:0:0 -slicevec:1.0:0:0:1:0:0"
set planesd="-slice3pt:0:0:0:1:0.7:0:1:0.7:1"
%isosurface% -dirin %diroutdata% -saveiso %dirout2%/Surface -vars:-all,vel,rhop,idp,type -saveslice %dirout2%/Slices %planesy% %planesx% %planesd%
if not "%ERRORLEVEL%" == "0" goto fail

rem Executes FlowTool4 to create VTK files with particles assigned to different zones and a CSV file with information of each zone.
set dirout2=%dirout%\flow
%flowtool% -dirin %diroutdata% -fileboxes CaseDambreak_FileBoxes.txt -savecsv %dirout2%/_ResultFlow.csv -savevtk %dirout2%/Boxes.vtk
if not "%ERRORLEVEL%" == "0" goto fail


:success
echo All done
goto end

:fail
echo Execution aborted.

:end
pause
