unit uMainUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, Vcl.StdCtrls, Vcl.Grids,
  Vcl.DBGrids, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLite, FireDAC.VCLUI.Wait,
  FireDAC.Comp.UI, Vcl.Menus, System.Actions, Vcl.ActnList, Vcl.ImgList,
  Vcl.ComCtrls, Vcl.ToolWin, IdGlobalProtocols, IdHashMessageDigest,IdGlobal,IdHash,
  FireDAC.Phys.SQLiteDef, System.ImageList;

type
  TMD5 = class(TIdHashMessageDigest5);
  TuMainForm = class(TForm)
    FDConnection_1: TFDConnection;
    FDQuery_1: TFDQuery;
    DBGrid_Data: TDBGrid;
    FDPhysSQLiteDriverLink_1: TFDPhysSQLiteDriverLink;
    DataSource_1: TDataSource;
    FDGUIxWaitCursor_1: TFDGUIxWaitCursor;
    FDCommand_1: TFDCommand;
    OpenDialog_File: TOpenDialog;
    MainMenu_1: TMainMenu;
    MenuButton_File: TMenuItem;
    MenuButton_NewDB: TMenuItem;
    MenuButton_OpenDB: TMenuItem;
    ToolBar_1: TToolBar;
    ToolButton_New: TToolButton;
    ImageList_1: TImageList;
    procedure MenuButton_OpenDBClick(Sender: TObject);
    procedure ToolButton_NewClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FDQuery_1AfterOpen(DataSet: TDataSet);
  private
    procedure GetText(Sender: TField; var Text: String; DisplayText: Boolean);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  uMainForm: TuMainForm;
  function FGetFileTime(sFileName:string; TimeType:Integer):TDateTime;
  function StreamToMD5(s:TFileStream):string;

implementation

{$R *.dfm}


procedure TuMainForm.GetText(Sender: TField; var Text: String;DisplayText: Boolean);
begin
  Text:=Sender.AsString;
end;


procedure TuMainForm.FDQuery_1AfterOpen(DataSet: TDataSet);
begin
  FDQuery_1.FieldByName('Name').OnGetText :=  GetText;
  FDQuery_1.FieldByName('Path').OnGetText :=  GetText;
end;

procedure TuMainForm.FormCreate(Sender: TObject);
begin
  FDConnection_1.DriverName := 'SQLite';
  FDConnection_1.Params.Add('DriverID=SQLite');
  FDConnection_1.Params.Add('Database=data.db');
  FDConnection_1.Connected := True;
  FDQuery_1.Open('Select * from Files');
  FDQuery_1.Connection := FDConnection_1;
  DataSource_1.DataSet := FDQuery_1;
  DBGrid_Data.DataSource := DataSource_1;
end;

procedure TuMainForm.MenuButton_OpenDBClick(Sender: TObject);
const
  dbPath = 'data.db';
begin
  FDConnection_1.DriverName := 'SQLite';
  FDConnection_1.Params.Add('DriverID=SQLite');
  if not FileExists(dbPath) then
    with FDConnection_1 do
    begin
      Params.Add('Database=' + dbPath);
      Connected := True;
    end;

    with FDCommand_1.CommandText do
    begin
      Add('Create table Files(');
      Add('ID integer PRIMARY KEY,');
      Add('Name text,');
      Add('Path text,');
      Add('MD5 string(32),');
      Add('CreationTime datetime,');
      Add('LastWriteTime datetime,');
      Add('LastAccessTime datetime');
      Add(')');
    end;
    FDConnection_1.ExecSQL(FDCommand_1.CommandText.GetText);
  FDQuery_1.Open('Select * from Files');
  FDQuery_1.Connection := FDConnection_1;
  DataSource_1.DataSet := FDQuery_1;
  DBGrid_Data.DataSource := DataSource_1;

end;

procedure TuMainForm.ToolButton_NewClick(Sender: TObject);
var
  path: string;
  CreationTime, LastWriteTime, LastAccessTime: TDateTime;
  filesen:TFileStream;
  filename: string;
  MD5 : string;
  Flag : Integer;
const
  strInsert = 'INSERT INTO Files(Name, Path, MD5, CreationTime, LastWriteTime, LastAccessTime)'+
              ' VALUES(:Name, :Path, :MD5, :CreationTime, :LastWriteTime, :LastAccessTime)';
begin
  if OpenDialog_File.Execute then
  begin
    filename := ExtractFileName(OpenDialog_File.FileName);
    path := OpenDialog_File.FileName;
    CreationTime := FGetFileTime(path,0);
    LastWriteTime := FGetFileTime(path,1);
    LastAccessTime := FGetFileTime(path,2);
    MD5 := '';
    filesen:=TFileStream.Create(OpenDialog_File.FileName,fmopenread or fmshareExclusive);
    MD5:= StreamToMD5(filesen);
    filesen.Free;

    Flag := SizeOf(FDConnection_1.ExecSQL('Select * from Files where MD5=' + MD5));

    if Flag = 0 then
    begin
      with FDQuery_1 do
      begin
        Close;
        SQL.Clear;
        SQL.Add(strInsert);
        ParamByName('Name').AsString:=filename;
        ParamByName('Path').AsString:=path;
        ParamByName('MD5').AsString:=MD5;
        ParamByName('CreationTime').AsDateTime:=CreationTime;
        ParamByName('LastWriteTime').AsDateTime:=LastWriteTime;
        ParamByName('LastAccessTime').AsDateTime:=LastAccessTime;
        ExecSQL;
      end;
    end
    else
    begin
      MessageBoxA(0, '文件 MD5 数据库中已存在！', '提示', MB_OKCANCEL);
    end;
  end;
  FDQuery_1.Open('Select * from Files');
  FDQuery_1.Connection := FDConnection_1;
  DataSource_1.DataSet := FDQuery_1;
  DBGrid_Data.DataSource := DataSource_1;
end;

function FGetFileTime(sFileName:string; TimeType:Integer):TDateTime;
var
  ffd:TWin32FindData;
  dft:DWord;
  lft,Time:TFileTime;
  H:THandle;
begin
  H:= Winapi.Windows.FindFirstFile(PChar(sFileName),ffd);
  case TimeType of
    0:Time:=ffd.ftCreationTime;
    1:Time:=ffd.ftLastWriteTime;
    2:Time:=ffd.ftLastAccessTime;
  end;
  { 获取文件信息 }
  if(H<>INVALID_HANDLE_VALUE)then
  begin
    { 只查找一个文件，所以关掉 find }
    Winapi.Windows.FindClose(H);
    { 转换 FILETIME 格式成为 localFILETIME 格式 }
    FileTimeToLocalFileTime(Time,lft);
    { 转换 FILETIME 格式成为 DOStime 格式 }
    FileTimeToDosDateTime(lft,LongRec(dft).Hi,LongRec(dft).Lo);
    { 最后，转换 DOStime 格式成为 Delphi 应用的 TdateTime 格式 }
    Result:=FileDateToDateTime(dft);
  end
  else
    result:=0;
end;


function StreamToMD5(s:TFileStream):string;
var
  MD5Encode:TMD5;
begin
  MD5Encode:=TMD5.Create;
  try
    result:=md5encode.HashStreamAsHex(s);
  finally
    MD5Encode.Free;
  end;
end;

end.
