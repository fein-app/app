[Setup]
AppName=FEiN
AppVersion=1.0
DefaultDirName={pf}\FeinApp
DefaultGroupName=FeinApp
UninstallDisplayIcon={app}\app.exe
OutputDir=.
OutputBaseFilename=FeinAppInstaller
Compression=lzma
SolidCompression=yes

[Files]
Source: "C:\Users\btibo\Documents\repos\app\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: recursesubdirs
Source: "C:\Users\btibo\Documents\repos\app\Icon.ico"; DestDir: "{app}"; Flags: recursesubdirs

[Icons]
Name: "{group}\FEiN"; Filename: "{app}\fein_app.exe"; IconFilename: "{app}\Icon.ico"
Name: "{commondesktop}\FEiN"; Filename: "{app}\fein_app.exe"; IconFilename: "{app}\Icon.ico"

[Run]
Filename: "{app}\fein_app.exe"