unit UtilUnit;

interface

uses
  System.SysUtils, System.Math, System.Classes, IdHashMessageDigest, IdGlobal,
  IdHash, System.Hash, Winapi.Windows;

Function RoundingUserDefineDecaimalPart(FloatNum: Double;
  NoOfDecPart: integer): Double;
Function TransBytesToSize(Bytes: integer): String;
Function TransFloatToStr(Avalue: Double; ADigits: integer): String;
Function EnumAllFiles(strPath: string; FileList: TStringList;
  CheckSub: Boolean = False): TStringList;
Function StreamToMD5(s: TFileStream): string;
Function GetFileHashMD5(FileName: String): String;
Function FGetFileTime(sFileName: string; TimeType: integer): TDateTime;

implementation

function TransBytesToSize(Bytes: integer): String;
var
  // temp : Double;
  temp: String;
begin
  if Bytes < 1024 then { 字节 }
  begin
    result := IntToStr(Bytes) + ' Byte';
  end

  else if Bytes < 1024 * 1024 then { KB }
  begin
    // temp :=  RoundingUserDefineDecaimalPart(Bytes / 1024, 2);
    // result := FloatToStr(temp) + ' KB';
    temp := TransFloatToStr(Bytes / 1024, 2);
    result := temp + ' KB';
  end

  else if Bytes < 1024 * 1024 * 1024 then { MB }
  begin
    // temp :=  RoundingUserDefineDecaimalPart(Bytes / (1024 * 1024),2);
    // result := FloatToStr(temp) + ' MB';
    temp := TransFloatToStr(Bytes / (1024 * 1024), 2);
    result := temp + ' MB';
  end

  else { GB }
  begin
    // temp :=  RoundingUserDefineDecaimalPart(Bytes / (1024 * 1024 * 1024), 2);
    // result := FloatToStr(temp) + ' GB';
    temp := TransFloatToStr(Bytes / (1024 * 1024 * 1024), 2);
    result := temp + ' GB';
  end
end;

// FormatFloat('#.##', f)

Function RoundingUserDefineDecaimalPart(FloatNum: Double;
  NoOfDecPart: integer): Double;
{ 同下，不进行四舍五入 }
Var
  ls_FloatNumber: String;
Begin
  ls_FloatNumber := FloatToStr(FloatNum);
  IF Pos('.', ls_FloatNumber) > 0 Then
    result := StrToFloat(copy(ls_FloatNumber, 1, Pos('.', ls_FloatNumber) - 1) +
      '.' + copy(ls_FloatNumber, Pos('.', ls_FloatNumber) + 1, NoOfDecPart))
  Else
    result := FloatNum;
End;

function TransFloatToStr(Avalue: Double; ADigits: integer): String;
{ 对浮点值保留 ADigits 位小数， 四舍五入 }
var
  v: Double;
  p: integer;
  e: String;
begin
  if abs(Avalue) < 1 then
  begin
    result := FloatToStr(Avalue);
    p := Pos('E', result);
    if p > 0 then
    begin
      e := copy(result, p, length(result));
      setlength(result, p - 1);
      v := RoundTo(StrToFloat(result), -ADigits);
      result := FloatToStr(v) + e;
    end
    else
      result := FloatToStr(RoundTo(Avalue, -ADigits));
  end
  else
    result := FloatToStr(RoundTo(Avalue, -ADigits));
end;

{ 功能:枚举指定目录及子目录下的所有文件 }
function EnumAllFiles(strPath: string; FileList: TStringList;
  CheckSub: Boolean = False): TStringList;
var
  sr: TSearchRec;
begin
  result := TStringList.Create;
  if strPath = '' then
    Exit;

  strPath := IncludeTrailingPathDelimiter(strPath);

  if not DirectoryExists(strPath) then
    Exit;

  if FindFirst(strPath + '*.*', System.SysUtils.faAnyFile, sr) = 0 then
  begin
    try
      repeat
        // 非目录的，就是文件
        if (sr.Attr and System.SysUtils.faDirectory = 0) then
        begin
          FileList.Add(strPath + sr.Name);
        end;
      until FindNext(sr) <> 0;
    finally
      System.SysUtils.FindClose(sr);
    end;
  end;

  // 查找子目录。
  if (FindFirst(strPath + '*', System.SysUtils.faDirectory, sr) = 0) and CheckSub
  then
  begin
    try
      repeat
        if (sr.Attr and System.SysUtils.faDirectory <> 0) and (sr.Name <> '.')
          and (sr.Name <> '..') then
        begin
          EnumAllFiles(strPath + sr.Name, FileList, CheckSub);
        end;
      until FindNext(sr) <> 0;
    finally
      FindClose(sr);
    end;
  end;
  result := FileList;
end;

function StreamToMD5(s: TFileStream): string;
var
  MD5Encode: TIdHashMessageDigest5;
begin
  MD5Encode := TIdHashMessageDigest5.Create;
  try
    result := MD5Encode.HashStreamAsHex(s);
  finally
    MD5Encode.Free;
  end;
end;

function GetFileHashMD5(FileName: String): String;
var
  HashMD5: THashMD5;
  BufLen, Readed: integer;
  Stream: TFileStream;
  Buffer: Pointer;

begin
  HashMD5 := THashMD5.Create;
  BufLen := 32 * 1024;
  Buffer := AllocMem(BufLen);
  try
    Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
    try
      while Stream.Position < Stream.size do
      begin
        Readed := Stream.Read(Buffer^, BufLen);
        if Readed > 0 then
        begin
          HashMD5.update(Buffer^, Readed);
        end;
      end;
    finally
      Stream.Free;
    end;
  finally
    FreeMem(Buffer)
  end;

  result := HashMD5.HashAsString.ToUpper;
end;

function FGetFileTime(sFileName: string; TimeType: integer): TDateTime;
var
  ffd: TWin32FindData;
  dft: DWord;
  lft, Time: TFileTime;
  H: THandle;
begin
  H := Winapi.Windows.FindFirstFile(PChar(sFileName), ffd);
  case TimeType of
    0:
      Time := ffd.ftCreationTime;
    1:
      Time := ffd.ftLastWriteTime;
    2:
      Time := ffd.ftLastAccessTime;
  end;
  { 获取文件信息 }
  if (H <> INVALID_HANDLE_VALUE) then
  begin
    { 只查找一个文件，所以关掉 find }
    Winapi.Windows.FindClose(H);
    { 转换 FILETIME 格式成为 localFILETIME 格式 }
    FileTimeToLocalFileTime(Time, lft);
    { 转换 FILETIME 格式成为 DOStime 格式 }
    FileTimeToDosDateTime(lft, LongRec(dft).Hi, LongRec(dft).Lo);
    { 最后，转换 DOStime 格式成为 Delphi 应用的 TdateTime 格式 }
    result := FileDateToDateTime(dft);
  end
  else
    result := 0;
end;

end.
