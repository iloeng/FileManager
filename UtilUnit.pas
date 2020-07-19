unit UtilUnit;

interface
Function RoundingUserDefineDecaimalPart(FloatNum: Double; NoOfDecPart: integer): Double;
function TransBytesToSize(Bytes: Integer): String;
function TransFloatToStr(Avalue : Double; ADigits : Integer) : String;

implementation

uses
System.SysUtils, System.Math;


function TransBytesToSize(Bytes: Integer): String;
var
//  temp : Double;
  temp : String;
begin
  if Bytes < 1024 then   { 字节 }
  begin
    result := IntToStr(Bytes) + ' Byte';
  end

  else if Bytes < 1024 * 1024 then  { KB }
  begin
//    temp :=  RoundingUserDefineDecaimalPart(Bytes / 1024, 2);
//    result := FloatToStr(temp) + ' KB';
    temp :=  TransFloatToStr(Bytes / 1024, 2);
    result := temp + ' KB';
  end

  else if Bytes < 1024 * 1024 * 1024 then  { MB }
  begin
//    temp :=  RoundingUserDefineDecaimalPart(Bytes / (1024 * 1024),2);
//    result := FloatToStr(temp) + ' MB';
    temp :=  TransFloatToStr(Bytes / (1024 * 1024),2);
    result := temp + ' MB';
  end

  else { GB }
  begin
//    temp :=  RoundingUserDefineDecaimalPart(Bytes / (1024 * 1024 * 1024), 2);
//    result := FloatToStr(temp) + ' GB';
    temp :=  TransFloatToStr(Bytes / (1024 * 1024 * 1024), 2);
    result := temp + ' GB';
  end
end;

//FormatFloat('#.##', f)

Function RoundingUserDefineDecaimalPart(FloatNum: Double; NoOfDecPart: integer): Double;
{ 同下，不进行四舍五入 }
Var
    ls_FloatNumber: String;
Begin
    ls_FloatNumber := FloatToStr(FloatNum);
    IF Pos('.', ls_FloatNumber) > 0 Then
      Result := StrToFloat(copy(ls_FloatNumber, 1, Pos('.', ls_FloatNumber) - 1) + '.' + copy
       (ls_FloatNumber, Pos('.', ls_FloatNumber) + 1, NoOfDecPart))
    Else
      Result := FloatNum;
End;


function TransFloatToStr(Avalue : Double; ADigits : Integer) : String;
{ 对浮点值保留 ADigits 位小数， 四舍五入 }
var
  v : Double;
  p : Integer;
  e : String;
begin
  if abs(Avalue)<1 then
  begin
    result := floatTostr(Avalue);
    p := pos('E', result);
    if p > 0 then
    begin
      e := copy(result, p, length(result));
      setlength(result, p-1);
      v := RoundTo(StrToFloat(result), -Adigits);
      result := FloatToStr(v) + e;
    end
    else
      result := FloatToStr(RoundTo(Avalue, -Adigits));
  end
  else
    result := FloatToStr(RoundTo(Avalue, -Adigits));
end;

end.
