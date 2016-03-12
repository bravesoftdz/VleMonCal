

unit test_main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids, Vcl.ValEdit, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Imaging.pngimage;

type
  Tgsm2gd_main = class(TForm)
    vle: TValueListEditor;
    Panel1: TPanel;
    Panel2: TPanel;
    Button1: TButton;
    Label1: TLabel;
    Image1: TImage;
    Label2: TLabel;
    laVersion: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure vleGetPickList(Sender: TObject; const KeyName: string;
      Values: TStrings);
    procedure vleEditButtonClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gsm2gd_main: Tgsm2gd_main;

implementation

{$R *.dfm}

uses
  uCalendar, uSettings, uWildCards, uGetVersion;

procedure Tgsm2gd_main.Button1Click(Sender: TObject);
var
  K: uSettings.TKey;
begin
  for K := Low( TKey ) to High( TKey ) do
  try
    uSettings.CheckKeyValue( K, vle.Cells[ 1, Integer( K ) ]);
  except on E: Exception do begin
    vle.Col := 1;
    vle.Row := Integer( K );
    vle.SetFocus;
    ShowMessage( E.Message );
    Exit;
  end; end;
  ShowMessage( '�������!' );
end;

procedure Tgsm2gd_main.FormCreate(Sender: TObject);
var
  K: uSettings.TKey;
begin
  laVersion.Caption :=  '������: ' + GetVersionInfoText;
  for K := Low( TKey ) to High( TKey ) do begin
    vle.Keys[ Integer( K ) ] := uSettings.KeyName[ K ];
    with vle.ItemProps[ Integer( K ) ] do begin
      KeyDesc := uSettings.KeyDesc[ K ];
      case K of
        uSettings.WildCards, uSettings.Date:
          EditStyle := esEllipsis;
        uSettings.OneDay : begin
          EditStyle := esPickList;
          ReadOnly := True;
        end
        else
          EditStyle := esSimple;
      end;
    end;
  end;
end;

{ TValueListEditor }

procedure Tgsm2gd_main.vleEditButtonClick(Sender: TObject);
  procedure WildCardsEdit;
  var
    LValue : String;
  begin
    LValue := vle.Cells[ 1, vle.Row ];
    repeat
      if not uWildCards.PopUp( LValue ) then
        Exit;
      try
        uSettings.CheckKeyValue( TKey.WildCards, LValue );
        vle.Cells[ 1, vle.Row ] := LValue;
        Exit;
      except on E: Exception do
        ShowMessage( E.Message );
      end;
    until True;
  end;
begin
  case uSettings.TKey( vle.Row ) of
    uSettings.Date: uCalendar.PopUp( vle );
    uSettings.WildCards: WildCardsEdit;
  end;
end;

procedure Tgsm2gd_main.vleGetPickList(Sender: TObject; const KeyName: string;
  Values: TStrings);
begin
  if SameText( KeyName, uSettings.KeyName[ uSettings.OneDay ] ) then begin
    Values.Add( uSettings.BoolStrs[ False ] );
    Values.Add( uSettings.BoolStrs[ True ] );
  end;
end;

end.