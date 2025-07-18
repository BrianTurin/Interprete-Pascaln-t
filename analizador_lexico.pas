unit analizador_lexico;
Interface
uses tipos;
const
   MaxSim=200;
   FinArch=#0;
type

FileOfChar= file of char;
  TElemTS= record
   compLex:TipoSG;
   Lexema:string;
  end;
  TablaDeSimbolos= record
    elem:array[1..MaxSim]of TElemTS;
    cant:0..maxsim;
  end;

Procedure InicializarTS(VAR TS:TablaDeSimbolos);
Procedure CompletarTS(VAR TS:TablaDeSimbolos);
Procedure InstalarEnTS(lexema:String; VAR TS:TablaDeSimbolos; VAR CompLex:TipoSG);
Procedure ObtenerSiguienteCompLex(Var Fuente:FileOfChar;VAR Control:Longint; VAR CompLex:TipoSG;VAR Lexema:String;Var TS:TablaDeSimbolos);
Procedure LeerCar(var Fuente:FileOfChar;var Control:Longint; var car:char);
Function EsIdentificador(Var Fuente:FileOfChar;Var Control:Longint;Var Lexema:String):boolean;
Function EsConstanteReal(Var Fuente:FileOfChar;Var Control:Longint;Var Lexema:String): Boolean;
Function EsSimboloEspecial(Var Fuente:FileOfChar;Var Control:Longint;Var Lexema:String;Var CompLex:TipoSG): Boolean;

Implementation

Procedure InicializarTS(Var TS:TablaDeSimbolos);
Begin
    TS.cant := 0;
End;

Procedure CompletarTS(Var TS:TablaDeSimbolos);  //Define la tabla y las palabras reservadas
Begin
    Inc(TS.cant);
    TS.elem[TS.cant].lexema := 'mientras';
    TS.elem[TS.cant].compLex := Tmientras;
    Inc(TS.cant);
    TS.elem[TS.cant].lexema := 'si';
    TS.elem[TS.cant].compLex := Tsi;
    Inc(TS.cant);
    TS.elem[TS.cant].lexema := 'definicion';
    TS.elem[TS.cant].compLex := Tdefinicion;
    Inc(TS.cant);
    TS.elem[TS.cant].lexema := 'programita';
    TS.elem[TS.cant].compLex := Tprogramita;
    Inc(TS.cant);
    TS.elem[TS.cant].lexema := 'seLlama';
    TS.elem[TS.cant].compLex := TseLlama;
    Inc(TS.cant);
    TS.elem[TS.cant].lexema := 'leer';
    TS.elem[TS.cant].compLex := Tleer;
    Inc(TS.cant);
    TS.elem[TS.cant].lexema := 'imprime';
    TS.elem[TS.cant].compLex := Timprime;
    Inc(TS.cant);
    TS.elem[TS.cant].lexema := 'potencia';
    TS.elem[TS.cant].compLex := Tpotencia;
    Inc(TS.cant);
    TS.elem[TS.cant].lexema := 'raiz';
    TS.elem[TS.cant].compLex := Traiz;
    Inc(TS.cant);
    TS.elem[TS.cant].lexema := 'vector';
    TS.elem[TS.cant].compLex := Tvector;
    Inc(TS.cant);
    TS.elem[TS.cant].lexema := 'sino';
    TS.elem[TS.cant].compLex := Tsino;
End;


Procedure InstalarEnTS(lexema:String; VAR TS:TablaDeSimbolos; VAR CompLex:TipoSG);
VAR
    pre_ex:   boolean;
    I:   byte;
Begin
    pre_ex := False;
    For I:=1 To TS.cant Do
        Begin
            If lexema = TS.elem[I].lexema Then
                Begin
                    Complex := TS.elem[I].compLex;
                    pre_ex := True;
                End;
        End;
    If Not pre_ex Then
        Begin
            inc(TS.cant);
            TS.elem[TS.cant].lexema := lexema;
            TS.elem[TS.cant].compLex := Tid;
            CompLex := Tid;
        End;
End;

Procedure LeerCar(var Fuente:FileOfChar;var Control:Longint; var car:char);
begin
  if control< filesize(Fuente) then
    begin
      seek(Fuente,Control);
      read(Fuente,car);
    end
  else
      begin
        car:=FinArch;
      end;
end;

Function EsIdentificador(Var Fuente:FileOfChar;Var Control:Longint;Var Lexema:String):boolean;
const
  q0=0;
  F=[2];
type
  Q=0..3;
  Sigma=(Letra,Digito,Otro);
  TipoDelta=array[Q,Sigma] of Q;

Function CarASimb(x:string):Sigma;
begin
  Case x of
  'a'..'z', 'A'..'Z':CarASimb:=Letra;
    '0'..'9':CarASimb:=Digito;
  else
   CarASimb:=Otro
  End;
End;
VAR
  ContInt: Longint;
  EstadoActual:Q;
  Delta:TipoDelta;
  car: char;
begin
  Delta[0,Letra]:=1;
  Delta[0,Digito]:=3;
  Delta[0,Otro]:=3;
  Delta[1,Letra]:=1;
  Delta[1,Digito]:=1;
  Delta[1,Otro]:=2;
  EstadoActual:=q0;
  ContInt:=Control;
  Lexema:='';
  While EstadoActual in [0,1] do
  begin
   LeerCar(Fuente,ContInt,car);
   EstadoActual:=Delta[EstadoActual,CarASimb(car)];
   ContInt:=ContInt+1;
     If EstadoActual=1 then
       Lexema:=Lexema + car;
  end;
  EsIdentificador:=False;
  If EstadoActual in F then
  begin
    EsIdentificador:=True;
    Control:=ContInt-1;
  end;
end;

Function EsConstanteReal(Var Fuente:FileOfChar;Var Control:Longint;Var Lexema:String): Boolean;
const
  q0=0;
  F=[4];
type
  Q = 0..5;
  Sigma=(Digito,Otro,Punto);         //Sigma=(Letra,Digito,Otro,PoC);
  TipoDelta=array[Q,Sigma] of Q;
Function CarASimb(X:string):Sigma;
begin
  Case x of
  //'a'..'z', 'A'..'Z':CarASimb:=Letra;
  '0'..'9'       :CarASimb:=Digito;
  '.'      :CarASimb:=Punto;
  else
   CarASimb:=Otro
  End;
End;
Var
  ContInt:Longint;
  EstadoActual:Q;
  Delta:TipoDelta;
  car: char;
Begin
  Delta[0,Digito]:=1;
  Delta[0,Otro]:=5;
  Delta[0,Punto]:=5;
  Delta[1,Digito]:=1;
  Delta[1,Otro]:=4;
  Delta[1,Punto]:=2;
  Delta[2,Digito]:=3;
  Delta[2,Otro]:=5;
  Delta[2,Punto]:=5;
  Delta[3,Digito]:=3;
  Delta[3,Otro]:=4;
  Delta[3,Punto]:=4;
  EstadoActual:=q0;
  ContInt:=Control;
  Lexema:='';
  While EstadoActual in [0,1,2,3] do
  begin
    LeerCar(Fuente,ContInt,car);
    EstadoActual:=Delta[EstadoActual,CarASimb(car)];
    ContInt:=ContInt+1;
     If EstadoActual in [0,1,2,3,5] then
     begin
       Lexema:=Lexema+car;
     end;
  end;
  EsConstanteReal:=False;
  If EstadoActual in F then
  begin
   EsConstanteReal:=True;
   Control:=ContInt-1;
  end;
end;

Function EsCadena (Var Fuente:FileOfChar; Var Control:Longint; Var Lexema:string): Boolean;
const
  q0=0;
  F=[2];
type
  Q=0..3;
  Sigma=(Cadena,Otro);
  TipoDelta=array[Q,Sigma] of Q;
Function CarASimb(car:string):sigma;
begin
  case car of
    #39: CarASimb := Cadena;
    else
     CarASimb := Otro;
  end;
end;
VAR
  EstadoActual: Q;
  car:char;
  Delta:TipoDelta;
  ContInt:longint;
begin
  Delta[0,Cadena]:=1;
  Delta[0,Otro]:=3;
  Delta[1,Cadena]:=2;
  Delta[1,Otro]:=1;
  EstadoActual:=q0;
  ContInt:=Control;
  Lexema:='';
  while EstadoActual in [0,1] do
  begin
     LeerCar(Fuente,ContInt,car);
     EstadoActual:=Delta[EstadoActual,CarASimb(car)];
     ContInt:=ContInt+1;
     If car <> #39 then
       Lexema:=Lexema+car;
  end;
  If EstadoActual in F then
  begin
   EsCadena := true;
   Control := ContInt;
  end
  else
   EsCadena := false;
end;

Function EsSimboloEspecial(Var Fuente:FileOfChar;Var Control:Longint;Var Lexema:String;Var CompLex:TipoSG): Boolean;
VAR
  car: char;
begin
  LeerCar(Fuente,Control,car);
  Lexema:=car;
  Control:=Control+1;
  EsSimboloEspecial:=true;
  Case car of
    ';':   CompLex := TpYc;
    ',':   CompLex := Tcoma;
    '(':   CompLex := TparenA;
    ')':   CompLex := TparenC;
    '[':   CompLex := TcorA;
    ']':   CompLex := TcorC;
    '{':   CompLex := TllaveA;
    '}':   CompLex := TllaveC;
    '=':
               Begin
                   CompLex := Tasignacion;
                   LeerCar(Fuente,control,car);
                   If car = '=' Then
                       Begin
                           lexema := '==';
                           Control:=Control+1;
                           Complex := TunRelacional;
                       End;
               End;
    ':':   CompLex := TdosPuntos;
    '@':   CompLex := Tarroba;
    '~':   CompLex := Tvirgulilla;
    '+':   CompLex := Tmas;
    '-':   CompLex := Tmenos;
    '*':   CompLex := Tpor;
    '/':   CompLex := Tdivision;
    '<':
               Begin
                   CompLex := TunRelacional;
                   LeerCar(Fuente,control,car);
                   If car = '=' Then
                       Begin
                           lexema := '<=';
                           Control := Control +1;
                       End
                   Else
                       If car = '>' Then
                           Begin
                               lexema := '<>';
                               Control := Control+1;
                           End
               End;
        '>':
               Begin
                   CompLex := TunRelacional;
                   LeerCar(Fuente,control,car);
                   If car = '=' Then
                       Begin
                           lexema := '>=';
                           Control := Control+1;
                       End;
               End;
        Else
        Control := Control-1;
        EsSimboloEspecial := false
    end;
end;

Procedure ObtenerSiguienteCompLex(Var Fuente:FileOfChar;Var Control:Longint; Var CompLex:TipoSG;Var Lexema:String;Var TS:TablaDeSimbolos);
VAR
  car:char;
begin
  LeerCar(Fuente,Control,car);
  while car in [#1..#32] do
  begin
      Control := Control +1;
      LeerCar(Fuente,Control,car);
  end;
  If car = FinArch then
  begin
    CompLex := Pesos;
  end
  else
  begin
      If EsIdentificador(Fuente,Control,Lexema) then
         InstalarEnTS(Lexema,TS,CompLex)
      else If EsConstanteReal(Fuente,Control,Lexema) then
         CompLex:=TConsReal
      else If EsCadena(Fuente,Control,Lexema) then
         CompLex:=Tcadena
      else If not EsSimboloEspecial(Fuente,Control,Lexema,CompLex) then
         CompLex:=ErrorLexico
      end;
end;
end.


