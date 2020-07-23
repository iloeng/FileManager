unit uMainUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, Vcl.StdCtrls, Vcl.Grids,
  Vcl.DBGrids, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLite, FireDAC.VCLUI.Wait,
  FireDAC.Comp.UI, Vcl.Menus, System.Actions, Vcl.ActnList, Vcl.ImgList,
  Vcl.ComCtrls, Vcl.ToolWin, IdGlobalProtocols, FireDAC.Phys.SQLiteDef,
  System.ImageList, System.Math, Winapi.ShellAPI;

type

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
    PopupMenu1: TPopupMenu;
    MenuItem_DelRow: TMenuItem;
    MenuButton_Help: TMenuItem;
    MenuButton_About: TMenuItem;
    ToolButton_BatchNew: TToolButton;
    N2: TMenuItem;
    MenuItem_DelAll: TMenuItem;
    MenuItem_OpenDir: TMenuItem;
    MenuItem_OpenFile: TMenuItem;
    procedure MenuButton_OpenDBClick(Sender: TObject);
    procedure ToolButton_NewClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FDQuery_1AfterOpen(DataSet: TDataSet);
    procedure MenuItem_DelRowClick(Sender: TObject);
    procedure MenuButton_AboutClick(Sender: TObject);
    procedure WMDROPFILES(var Msg: TMessage); message WM_DROPFILES;
    procedure MenuItem_DelAllClick(Sender: TObject);
    procedure MenuItem_OpenFileClick(Sender: TObject);
    procedure MenuItem_OpenDirClick(Sender: TObject);
  private
    procedure GetText(Sender: TField; var Text: String; DisplayText: Boolean);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  uMainForm: TuMainForm;

implementation

uses AboutUnit, UtilUnit;

{$R *.dfm}

procedure TuMainForm.GetText(Sender: TField; var Text: String;
  DisplayText: Boolean);
begin
  Text := Sender.AsString;
end;

procedure TuMainForm.FDQuery_1AfterOpen(DataSet: TDataSet);
begin
  FDQuery_1.FieldByName('Name').OnGetText := GetText;
  FDQuery_1.FieldByName('Path').OnGetText := GetText;
  FDQuery_1.FieldByName('Size').OnGetText := GetText;
end;

procedure TuMainForm.WMDROPFILES(var Msg: TMessage);
var
  FilesCount: Integer; // 文件总数
  i: Integer;
  FileName: array [0 .. 255] of Char;
  path: string;
  CreationTime, LastWriteTime, LastAccessTime: TDateTime;
  filenameStr: string;
  MD5: string;
  bytes: Integer;
  size: string;

const
  strInsert =
    'INSERT INTO Files(Name, Path, Size, Bytes, MD5, CreationTime, LastWriteTime, LastAccessTime)'
    + ' VALUES(:Name, :Path, :Size, :Bytes, :MD5, :CreationTime, :LastWriteTime, :LastAccessTime)';

begin
  // 获取文件总数
  FilesCount := DragQueryFile(Msg.WParam, $FFFFFFFF, nil, 0);
  // Memo1.Lines.Add('文件总数为：' + IntToStr(FilesCount));

  // 获取文件名
  for i := 0 to FilesCount - 1 do
  begin
    DragQueryFile(Msg.WParam, i, FileName, 256);
    filenameStr := ExtractFileName(FileName);
    path := FileName;
    CreationTime := FGetFileTime(path, 0);
    LastWriteTime := FGetFileTime(path, 1);
    LastAccessTime := FGetFileTime(path, 2);
    MD5 := GetFileHashMD5(path);
    bytes := FileSizeByName(path);
    size := TransBytesToSize(bytes);
    with FDQuery_1 do
    begin
      Close;
      SQL.Clear;
      SQL.Add('Select * from Files where MD5="' + MD5 + '"');
      Open;
    end;

    { 查询结果为空，则将信息插入数据库中，不为空，弹出提示信息 }
    if FDQuery_1.IsEmpty then // FDQuery_1.RecordCount = 0
    begin
      with FDQuery_1 do
      begin
        Close;
        SQL.Clear;
        SQL.Add(strInsert);
        ParamByName('Name').AsString := filenameStr;
        ParamByName('Path').AsString := path;
        ParamByName('Size').AsString := size;
        ParamByName('Bytes').AsInteger := bytes;
        ParamByName('MD5').AsString := MD5;
        ParamByName('CreationTime').AsDateTime := CreationTime;
        ParamByName('LastWriteTime').AsDateTime := LastWriteTime;
        ParamByName('LastAccessTime').AsDateTime := LastAccessTime;
        ExecSQL;
        Close;
        Open('Select * from Files');
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
  // 释放
  DragFinish(Msg.WParam);
end;

procedure TuMainForm.FormCreate(Sender: TObject);
begin
  DragAcceptFiles(Handle, True);
  FDConnection_1.DriverName := 'SQLite';
  FDConnection_1.Params.Add('DriverID=SQLite');
  FDConnection_1.Params.Add('Database=data.db');
  FDConnection_1.Connected := True;
  FDQuery_1.Open('Select * from Files');
  FDQuery_1.Connection := FDConnection_1;
  DataSource_1.DataSet := FDQuery_1;
  DBGrid_Data.DataSource := DataSource_1;
end;

procedure TuMainForm.MenuButton_AboutClick(Sender: TObject);
begin
  AboutUnit.AboutBox.Show;
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
    Add('Size text,');
    Add('Bytes interger,');
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

procedure TuMainForm.MenuItem_DelAllClick(Sender: TObject);
var
  flag : Integer;
begin
  flag := MessageBox(0, '确认删除？' + #10#13 + '一旦删除，数据将无法恢复！！！', '警告', MB_OKCANCEL);
  if flag = 1 then
  begin
    FDQuery_1.Close;
    FDQuery_1.SQL.Clear;
    FDQuery_1.SQL.Add('delete from files');
    FDQuery_1.ExecSQL;
    FDQuery_1.Close;
    FDQuery_1.SQL.Clear;
    FDQuery_1.Open('Select * from Files');
  end;
end;

procedure TuMainForm.MenuItem_DelRowClick(Sender: TObject);
var
  id: Integer;
begin
  id := FDQuery_1.FieldByName('ID').AsInteger;
  if FDQuery_1.State in [dsBrowse] then
  begin
    FDQuery_1.Close;
    FDQuery_1.SQL.Clear;
    FDQuery_1.SQL.Add('delete from files where ID=' + IntToStr(id));
    FDQuery_1.ExecSQL;
    FDQuery_1.Close;
    FDQuery_1.SQL.Clear;
    FDQuery_1.Open('Select * from Files');
  end;

end;

procedure TuMainForm.MenuItem_OpenDirClick(Sender: TObject);
var
  dir : string;
begin
  dir := FDQuery_1.FieldByName('Path').AsString;
  if FDQuery_1.State in [dsBrowse] then
    ShellExecute(Handle, 'open', 'Explorer.exe', PWideChar(ExtractFilePath(dir)), nil, 1);
end;

procedure TuMainForm.MenuItem_OpenFileClick(Sender: TObject);
var
  dir : string;
begin
  dir := FDQuery_1.FieldByName('Path').AsString;
  if FDQuery_1.State in [dsBrowse] then
    ShellExecute(Handle, 'open', 'Explorer.exe', PWideChar(dir), nil, 1);
end;

procedure TuMainForm.ToolButton_NewClick(Sender: TObject);
var
  path: string;
  CreationTime, LastWriteTime, LastAccessTime: TDateTime;
  FileName: string;
  MD5: string;
  bytes: Integer;
  size: string;

const
  strInsert =
    'INSERT INTO Files(Name, Path, Size, Bytes, MD5, CreationTime, LastWriteTime, LastAccessTime)'
    + ' VALUES(:Name, :Path, :Size, :Bytes, :MD5, :CreationTime, :LastWriteTime, :LastAccessTime)';
begin
  if OpenDialog_File.Execute then
  begin
    FileName := ExtractFileName(OpenDialog_File.FileName);
    path := OpenDialog_File.FileName;
    CreationTime := FGetFileTime(path, 0);
    LastWriteTime := FGetFileTime(path, 1);
    LastAccessTime := FGetFileTime(path, 2);
    MD5 := GetFileHashMD5(path);
    bytes := FileSizeByName(path);
    size := TransBytesToSize(bytes);

    with FDQuery_1 do
    begin
      Close;
      SQL.Clear;
      SQL.Add('Select * from Files where MD5="' + MD5 + '"');
      Open;
    end;

    { 查询结果为空，则将信息插入数据库中，不为空，弹出提示信息 }
    if FDQuery_1.IsEmpty then // FDQuery_1.RecordCount = 0
    begin
      with FDQuery_1 do
      begin
        Close;
        SQL.Clear;
        SQL.Add(strInsert);
        ParamByName('Name').AsString := FileName;
        ParamByName('Path').AsString := path;
        ParamByName('Size').AsString := size;
        ParamByName('Bytes').AsInteger := bytes;
        ParamByName('MD5').AsString := MD5;
        ParamByName('CreationTime').AsDateTime := CreationTime;
        ParamByName('LastWriteTime').AsDateTime := LastWriteTime;
        ParamByName('LastAccessTime').AsDateTime := LastAccessTime;
        ExecSQL;
        Close;
        Open('Select * from Files');
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

end.
