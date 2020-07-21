unit BatchAddUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
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
    procedure Button_EnsureClick(Sender: TObject);
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

procedure TBatchAddForm.Button_EnsureClick(Sender: TObject);
var
  filelist, temp : TStringList;
  path : string;

begin
  if Edit_Path.Text = '' then
  begin
    ShowMessage('Please input a valid path');
  end
  else
    path := Edit_Path.Text;
  temp := TStringList.Create;
  filelist := UtilUnit.EnumAllFiles(path, temp, True);
  { todo }
end;

end.
