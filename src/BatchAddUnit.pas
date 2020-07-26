unit BatchAddUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.FileCtrl,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls;

type
  TBatchAddForm = class(TForm)
    GroupBox_Directory: TGroupBox;
    Label_Path: TLabel;
    Edit_Path: TEdit;
    Button_Ensure: TButton;
    ProgressBar1: TProgressBar;
    Label_Done: TLabel;
    Label_Total: TLabel;
    Label_ProcessSep: TLabel;
    Button1: TButton;
    procedure Button_EnsureClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  BatchAddForm: TBatchAddForm;

implementation

uses UtilUnit, uMainUnit;

{$R *.dfm}

procedure TBatchAddForm.Button1Click(Sender: TObject);
var
  astrPath: tarray<string>;
begin
  if SelectDirectory('请选择路径', astrPath, [sdNoDereferenceLinks]) then
  begin
    Edit_Path.Text := astrPath[0];
  end;
end;

procedure TBatchAddForm.Button_EnsureClick(Sender: TObject);
var
  filelist, temp: TStringList;
  path: string;
  i: Integer;
begin
  if Edit_Path.Text = '' then
  begin
    ShowMessage('Please input a valid path');
  end
  else
    path := Edit_Path.Text;
  temp := TStringList.Create;
  filelist := UtilUnit.EnumAllFiles(path, temp, True);
  Label_Total.Caption := IntToStr(filelist.Count);
  ProgressBar1.Max := filelist.Count;
  for i := 0 to filelist.Count - 1 do
  begin
    UtilUnit.InsertFileInfo(uMainForm.FDQuery_1, filelist[i]);
    Label_Done.Caption := IntToStr(i + 1);
    ProgressBar1.Position := i + 1;
  end;
end;

end.
