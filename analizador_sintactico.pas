unit analizador_sintactico;
interface
uses
  crt,analizador_lexico,tipos;

Const
  MaxProd = 6;

Type
  TProduccion = Record
    elem: array[1..MaxProd] of TipoSG;
    cant: 0..MaxProd;
  end;

  //Definicion de TAS
  TipoVariable =  VLenguaje..VcontVector2;
  TipoTerminyPesos = TProgramita..Pesos;
  TTAS = array [TipoVariable, TiPoTerminyPesos] of ^TProduccion;

  //Arbol de Derivacion
  TAPuntNodo = ^TNodoArbol;
  THijos = record
    elem: array[1..MaxProd] of TAPuntNodo;
    cant: 0..MaxProd;
  end;

  TNodoArbol = Record
    Simbolo: TipoSG;
    lexema: string;
    hijos: THijos;
  end;
  //Definicion de Pila
  TElemPila = record
    Simbolo: TipoSG;
    NodoArbol: TAPuntNodo;
  end;

  TPunteroPila= ^TNodoPila;

  TPila = record
    Tope: TPunteroPila;
    Tam: word;
  end;

  TNodoPila = record
    Info: TElemPila;
    Sig: TPunteroPila;
  end;

 Procedure IniciarTAS(Var TAS:TTAS);
 Procedure CrearPila (VAR P:TPila);
 Procedure Apilar (VAR P:TPila; X:TElemPila);
 Procedure Desapilar (VAR P:TPila; VAR X:TElemPila);
 Procedure APilarTodos(VAR celda:TProduccion; VAR Padre:TAPuntNodo; VAR P:TPila);
 Procedure Analizador_Predictivo(rutaFuente:string;VAR arbol:TAPuntNodo; VAR error:boolean);

Implementation
  //Coloca todos los elementos de la matriz en nil,llegar a un elemento en nil significa un movimiento no válido
Procedure IniciarTAS(Var TAS:TTAS);
VAR
 I,J: TipoSG;
Begin
    For I:=VLenguaje to VcontVector2 do
        For J:=Tprogramita to Pesos do
            TAS[I, J] := nil;
End;
 // Procedimientos sobre pilas
Procedure CrearPila(VAR P:TPila);
begin
  P.Tam:=0;
  P.Tope:=nil;
end;

Procedure Apilar (VAR P:TPila; X:TElemPila);
VAR
  dir: TPunteroPila;
begin
  new(dir);
  dir^.Info:=X;
  dir^.Sig:=P.Tope;
  P.Tope:=dir;
  inc(P.Tam);
end;


Procedure Desapilar (VAR P:TPila; VAR X:TElemPila);
VAR
  dir:TPunteroPila;
begin
  X:=P.Tope^.Info;
  dir:=P.Tope;
  P.Tope:=P.Tope^.Sig;
  dispose(dir);
  dec(P.Tam);
end;
   //Recorre toda la producción y la apila
Procedure APilarTodos(VAR celda:TProduccion; VAR Padre:TAPuntNodo; VAR P:TPila);
VAR
  I:0..MaxProd;
  EPila: TElemPila;
begin
  For I:=celda.cant downto 1 do
  begin
   EPila.simbolo:=Celda.elem[I];
   EPila.NodoArbol:=Padre^.hijos.elem[I];
   aPilar(P,EPila);
  end;
end;

Procedure cargarTAS(VAR TAS:TTAS);
begin
  // Lenguaje -> "Programita" <Leng2>
  new(TAS[VLenguaje, Tprogramita]);
  TAS[VLenguaje, Tprogramita]^.elem[1] := Tprogramita;
  TAS[VLenguaje, Tprogramita]^.elem[2] := VLeng2;
  TAS[VLenguaje, Tprogramita]^.cant :=2;

  //<Leng2> -> <Titulo> <Leng3>
  new(TAS[VLeng2, Tdefinicion]);
  TAS[VLeng2, Tdefinicion]^.elem[1] := VTitulo;
  TAS[VLeng2, Tdefinicion]^.elem[2] := VLeng3;
  TAS[VLeng2, Tdefinicion]^.cant :=2;

  //<Leng2> -> <Titulo> <Leng3>
  new(TAS[VLeng2, TseLlama]);
  TAS[VLeng2, TseLlama]^.elem[1] := VTitulo;
  TAS[VLeng2, TseLlama]^.elem[2] := VLeng3;
  TAS[VLeng2, TseLlama]^.cant :=2;

  //<Leng2> -> <Titulo> <Leng3>
  new(TAS[VLeng2, TllaveA]);
  TAS[VLeng2, TllaveA]^.elem[1] := VTitulo;
  TAS[VLeng2, TllaveA]^.elem[2] := VLeng3;
  TAS[VLeng2, TllaveA]^.cant :=2;

  //<Leng3> -> “definicion” <Defs> “;” "{"<Cuerpo>"}"
  new(TAS[VLeng3,Tdefinicion]);
  TAS[VLeng3,Tdefinicion]^.elem[1]:=Tdefinicion;
  TAS[VLeng3,Tdefinicion]^.elem[2]:=VDefs;
  TAS[VLeng3,Tdefinicion]^.elem[3]:=TpYc;
  TAS[VLeng3,Tdefinicion]^.elem[4]:=TllaveA;
  TAS[VLeng3,Tdefinicion]^.elem[5]:=VCuerpo;
  TAS[VLeng3,Tdefinicion]^.elem[6]:=TllaveC;
  TAS[VLeng3,Tdefinicion]^.cant:=6;

  //<Leng3> -> "{"<Cuerpo>"}"
  new(TAS[VLeng3,TllaveA]);
  TAS[VLeng3,TllaveA]^.elem[1]:=TllaveA;
  TAS[VLeng3,TllaveA]^.elem[2]:=VCuerpo;
  TAS[VLeng3,TllaveA]^.elem[3]:=TllaveC;
  TAS[VLeng3,TllaveA]^.cant:=3;

  //<Titulo> -> Epsilon
  new(TAS[VTitulo,Tdefinicion]);
  TAS[VTitulo,Tdefinicion]^.cant:=0;

  //<Titulo> -> "seLlama" "cadena" ";"
  new(TAS[VTitulo,TseLlama]);
  TAS[VTitulo,TseLlama]^.elem[1]:=TseLlama;
  TAS[VTitulo,TseLlama]^.elem[2]:=Tcadena;
  TAS[VTitulo,TseLlama]^.elem[3]:=TpYc;
  TAS[VTitulo,TseLlama]^.cant:=3;

  //<Titulo> -> Epsilon
  new(TAS[VTitulo,TcorA]);
  TAS[VTitulo,TcorA]^.cant:=0;

  //<Titulo> -> Pesos
  new(TAS[VTitulo,Pesos]);
  TAS[VTitulo,Pesos]^.cant:=0;

  //<Defs> -> "id" <Defs2>
  new(TAS[VDefs,Tid]);
  TAS[VDefs,Tid]^.elem[1]:=Tid;
  TAS[VDefs,Tid]^.elem[2]:=VDefs2;
  TAS[VDefs,Tid]^.cant:=2;

  //<Defs2> -> Epsilon
  new(TAS[VDefs2,TpYc]);
  TAS[VDefs2,TpYc]^.cant:=0;

  //<Defs2> -> “,” <Defs>
  new(TAS[VDefs2,Tcoma]);
  TAS[VDefs2,Tcoma]^.elem[1]:=Tcoma;
  TAS[VDefs2,Tcoma]^.elem[2]:=VDefs;
  TAS[VDefs2,Tcoma]^.cant:=2;

  //<Defs2> -> “Vector” "[" <OpArit> "]" <Defs3>
  new(TAS[VDefs2,Tvector]);
  TAS[VDefs2,Tvector]^.elem[1]:=Tvector;
  TAS[VDefs2,Tvector]^.elem[2]:=TcorA;
  TAS[VDefs2,Tvector]^.elem[3]:=VopArit;
  TAS[VDefs2,Tvector]^.elem[4]:=TcorC;
  TAS[VDefs2,Tvector]^.elem[5]:=VDefs3;
  TAS[VDefs2,Tvector]^.cant:=5;

  //<Defs2> -> Pesos
  new(TAS[VDefs2,Pesos]);
  TAS[VDefs2,Pesos]^.cant:=0;

  //<Defs3> -> Epsilon
  new(TAS[VDefs3,TpYc]);
  TAS[VDefs3,TpYc]^.cant:=0;

  //<Defs3> -> “,” <Defs>
  new(TAS[VDefs3,Tcoma]);
  TAS[VDefs3,Tcoma]^.elem[1]:=Tcoma;
  TAS[VDefs3,Tcoma]^.elem[2]:=VDefs;
  TAS[VDefs3,Tcoma]^.cant:=2;

  //<VCuerpo> -> <Sentencia> <Cuerpo2>
  new(TAS[VCuerpo,Tid]);
  TAS[VCuerpo,Tid]^.elem[1]:=VSentencia;
  TAS[VCuerpo,Tid]^.elem[2]:=VCuerpo2;
  TAS[VCuerpo,Tid]^.cant:=2;

  //<VCuerpo> -> <Sentencia> <Cuerpo2>
  new(TAS[VCuerpo,Tsi]);
  TAS[VCuerpo,Tsi]^.elem[1]:=VSentencia;
  TAS[VCuerpo,Tsi]^.elem[2]:=VCuerpo2;
  TAS[VCuerpo,Tsi]^.cant:=2;

  //<VCuerpo> -> <Sentencia> <Cuerpo2>
  new(TAS[VCuerpo,Tleer]);
  TAS[VCuerpo,Tleer]^.elem[1]:=VSentencia;
  TAS[VCuerpo,Tleer]^.elem[2]:=VCuerpo2;
  TAS[VCuerpo,Tleer]^.cant:=2;

  //<VCuerpo> -> <Sentencia> <Cuerpo2>
  new(TAS[VCuerpo,Timprime]);
  TAS[VCuerpo,Timprime]^.elem[1]:=VSentencia;
  TAS[VCuerpo,Timprime]^.elem[2]:=VCuerpo2;
  TAS[VCuerpo,Timprime]^.cant:=2;

  //<VCuerpo> -> <Sentencia> <Cuerpo2>
  new(TAS[VCuerpo,Tmientras]);
  TAS[VCuerpo,Tmientras]^.elem[1]:=VSentencia;
  TAS[VCuerpo,Tmientras]^.elem[2]:=VCuerpo2;
  TAS[VCuerpo,Tmientras]^.cant:=2;

  //<VCuerpo2> -> ";" <Cuerpo>
  new(TAS[VCuerpo2,TpYc]);
  TAS[VCuerpo2,TpYc]^.elem[1]:=TpYc;
  TAS[VCuerpo2,TpYc]^.elem[2]:=VCuerpo;
  TAS[VCuerpo2,TpYc]^.cant:=2;

  //<VCuerpo2> -> Epsilon        //////////
  new(TAS[VCuerpo2,TllaveC]);
  TAS[VCuerpo2,TllaveC]^.cant:=0;

  //<VCuerpo2> -> Pesos
  new(TAS[VCuerpo2,Pesos]);
  TAS[VCuerpo2,Pesos]^.cant:=0;

  //<VSentencia> -> <Asignacion>
  new(TAS[VSentencia,Tid]);
  TAS[VSentencia,Tid]^.elem[1]:=VAsignacion;
  TAS[VSentencia,Tid]^.cant:=1;

  //<VSentencia> -> <Condicion>
  new(TAS[VSentencia,Tsi]);
  TAS[VSentencia,Tsi]^.elem[1]:=VCondicion;
  TAS[VSentencia,Tsi]^.cant:=1;

  //<VSentencia> -> <Leer>
  new(TAS[VSentencia,Tleer]);
  TAS[VSentencia,Tleer]^.elem[1]:=VLeer;
  TAS[VSentencia,Tleer]^.cant:=1;

  //<VSentencia> -> <Mostrar>
  new(TAS[VSentencia,Timprime]);
  TAS[VSentencia,Timprime]^.elem[1]:=VMostrar;
  TAS[VSentencia,Timprime]^.cant:=1;

  //<VSentencia> -> <Ciclo>
  new(TAS[VSentencia,Tmientras]);
  TAS[VSentencia,Tmientras]^.elem[1]:=VCiclo;
  TAS[VSentencia,Tmientras]^.cant:=1;

  //<VAsignacion> -> “id”<Asignacion2>
  new(TAS[VAsignacion,Tid]);
  TAS[VAsignacion,Tid]^.elem[1]:=Tid;
  TAS[VAsignacion,Tid]^.elem[2]:=VAsignacion2;
  TAS[VAsignacion,Tid]^.cant:=2;

  //<Asignacion2> -> "[" <opArit> "]" "=" <Asignacion3>
  new(TAS[VAsignacion2,TcorA]);
  TAS[VAsignacion2,TcorA]^.elem[1]:=TcorA;
  TAS[VAsignacion2,TcorA]^.elem[2]:=VopArit;
  TAS[VAsignacion2,TcorA]^.elem[3]:=TcorC;
  TAS[VAsignacion2,TcorA]^.elem[4]:=Tasignacion;
  TAS[VAsignacion2,TcorA]^.elem[5]:=VAsignacion3;
  TAS[VAsignacion2,TcorA]^.cant:=5;

  //<Asignacion2> -> “=” <Asignacion3>
  new(TAS[VAsignacion2,Tasignacion]);
  TAS[VAsignacion2,Tasignacion]^.elem[1]:=Tasignacion;
  TAS[VAsignacion2,Tasignacion]^.elem[2]:=VAsignacion3;
  TAS[VAsignacion2,Tasignacion]^.cant:=2;

  //<Asignacion3> -> <opArit>
  new(TAS[VAsignacion3,Tid]);
  TAS[VAsignacion3,Tid]^.elem[1]:=VopArit;
  TAS[VAsignacion3,Tid]^.cant:=1;

  //<Asignacion3> -> “[“<contVector> “]”
  new(TAS[VAsignacion3,TcorA]);
  TAS[VAsignacion3,TcorA]^.elem[1]:=TcorA;
  TAS[VAsignacion3,TcorA]^.elem[2]:=VcontVector;
  TAS[VAsignacion3,TcorA]^.elem[3]:=TcorC;
  TAS[VAsignacion3,TcorA]^.cant:=3;

  //<Asignacion3> -> <opArit>
  new(TAS[VAsignacion3,Tmenos]);
  TAS[VAsignacion3,Tmenos]^.elem[1]:=VopArit;
  TAS[VAsignacion3,Tmenos]^.cant:=1;

   //<Asignacion3> -> <opArit>
  new(TAS[VAsignacion3,TConsReal]);
  TAS[VAsignacion3,TConsReal]^.elem[1]:=VopArit;
  TAS[VAsignacion3,TConsReal]^.cant:=1;

  //<Asignacion3> -> <opArit>
  new(TAS[VAsignacion3,Tpotencia]);
  TAS[VAsignacion3,Tpotencia]^.elem[1]:=VopArit;
  TAS[VAsignacion3,Tpotencia]^.cant:=1;

  //<Asignacion3> -> <opArit>
  new(TAS[VAsignacion3,Traiz]);
  TAS[VAsignacion3,Traiz]^.elem[1]:=VopArit;
  TAS[VAsignacion3,Traiz]^.cant:=1;

  //<Asignacion3> -> <opArit>
  new(TAS[VAsignacion3,TparenA]);
  TAS[VAsignacion3,TparenA]^.elem[1]:=VopArit;
  TAS[VAsignacion3,TparenA]^.cant:=1;

  //<contVector> -> <OpArit> <contVector2>
  new(TAS[VcontVector,Tid]);
  TAS[VcontVector,Tid]^.elem[1]:=VopArit;
  TAS[VcontVector,Tid]^.elem[2]:=VcontVector2;
  TAS[VcontVector,Tid]^.cant:=2;

  //<contVector> -> <OpArit> <contVector2>
  new(TAS[VcontVector,Tmenos]);
  TAS[VcontVector,Tmenos]^.elem[1]:=VopArit;
  TAS[VcontVector,Tmenos]^.elem[2]:=VcontVector2;
  TAS[VcontVector,Tmenos]^.cant:=2;

  //<contVector> -> <OpArit> <contVector2>
  new(TAS[VcontVector,TConsReal]);
  TAS[VcontVector,TConsReal]^.elem[1]:=VopArit;
  TAS[VcontVector,TConsReal]^.elem[2]:=VcontVector2;
  TAS[VcontVector,TConsReal]^.cant:=2;

  //<contVector> -> <OpArit> <contVector2>
  new(TAS[VcontVector,Tpotencia]);
  TAS[VcontVector,Tpotencia]^.elem[1]:=VopArit;
  TAS[VcontVector,Tpotencia]^.elem[2]:=VcontVector2;
  TAS[VcontVector,Tpotencia]^.cant:=2;

  //<contVector> -> <OpArit> <contVector2>
  new(TAS[VcontVector,Traiz]);
  TAS[VcontVector,Traiz]^.elem[1]:=VopArit;
  TAS[VcontVector,Traiz]^.elem[2]:=VcontVector2;
  TAS[VcontVector,Traiz]^.cant:=2;

  //<contVector> -> <OpArit> <contVector2>
  new(TAS[VcontVector,TcorA]);
  TAS[VcontVector,TcorA]^.elem[1]:=VopArit;
  TAS[VcontVector,TcorA]^.elem[2]:=VcontVector2;
  TAS[VcontVector,TcorA]^.cant:=2;

  //<contVector2> -> Epsilon
  new(TAS[VcontVector2,TpYc]);
  TAS[VcontVector2,TpYc]^.cant:=0;

  //<contVector2> -> “,” <contVector>
  new(TAS[VcontVector2,Tcoma]);
  TAS[VcontVector2,Tcoma]^.elem[1]:=Tcoma;
  TAS[VcontVector2,Tcoma]^.elem[2]:=VcontVector;
  TAS[VcontVector2,Tcoma]^.cant:=2;

  //<contVector2> -> Epsilon
  new(TAS[VcontVector2,TllaveC]);
  TAS[VcontVector2,TllaveC]^.cant:=0;

  //<contVector2> -> Epsilon
  new(TAS[VcontVector2,TcorC]);
  TAS[VcontVector2,TcorC]^.cant:=0;

  //<contVector2> -> Pesos
  new(TAS[VcontVector2,Pesos]);
  TAS[VcontVector2,Pesos]^.cant:=0;

  //<opArit> -> <opAlg2> <simOpAlg>
  new(TAS[VopArit,Tid]);
  TAS[VopArit,Tid]^.elem[1]:=VopAlg2;
  TAS[VopArit,Tid]^.elem[2]:=VsimOpAlg;
  TAS[VopArit,Tid]^.cant:=2;

  //<opArit> -> <opAlg2> <simOpAlg>
  new(TAS[VopArit,Tmenos]);
  TAS[VopArit,Tmenos]^.elem[1]:=VopAlg2;
  TAS[VopArit,Tmenos]^.elem[2]:=VsimOpAlg;
  TAS[VopArit,Tmenos]^.cant:=2;

  //<opArit> -> <opAlg2> <simOpAlg>
  new(TAS[VopArit,TConsReal]);
  TAS[VopArit,TConsReal]^.elem[1]:=VopAlg2;
  TAS[VopArit,TConsReal]^.elem[2]:=VsimOpAlg;
  TAS[VopArit,TConsReal]^.cant:=2;

   //<opArit> -> <opAlg2> <simOpAlg>
  new(TAS[VopArit,Tpotencia]);
  TAS[VopArit,Tpotencia]^.elem[1]:=VopAlg2;
  TAS[VopArit,Tpotencia]^.elem[2]:=VsimOpAlg;
  TAS[VopArit,Tpotencia]^.cant:=2;

  //<opArit> -> <opAlg2> <simOpAlg>
  new(TAS[VopArit,Traiz]);
  TAS[VopArit,Traiz]^.elem[1]:=VopAlg2;
  TAS[VopArit,Traiz]^.elem[2]:=VsimOpAlg;
  TAS[VopArit,Traiz]^.cant:=2;

  //<opArit> -> <opAlg2> <simOpAlg>
  new(TAS[VopArit,TcorA]);
  TAS[VopArit,TcorA]^.elem[1]:=VopAlg2;
  TAS[VopArit,TcorA]^.elem[2]:=VsimOpAlg;
  TAS[VopArit,TcorA]^.cant:=2;

  //<VsimOpAlg> -> Epsilon
  new(TAS[VsimOpAlg,TpYc]);
  TAS[VsimOpAlg,TpYc]^.cant:=0;

  //<VsimOpAlg> -> Epsilon
  new(TAS[VsimOpAlg,Tcoma]);
  TAS[VsimOpAlg,Tcoma]^.cant:=0;

  //<VsimOpAlg> -> Epsilon
  new(TAS[VsimOpAlg,TllaveA]);
  TAS[VsimOpAlg,TllaveA]^.cant:=0;

  //<VsimOpAlg> -> Epsilon
  new(TAS[VsimOpAlg,TllaveC]);
  TAS[VsimOpAlg,TllaveC]^.cant:=0;

  //<VsimOpAlg> -> Epsilon
  new(TAS[VsimOpAlg,TcorC]);
  TAS[VsimOpAlg,TcorC]^.cant:=0;

  //<VsimOpAlg> -> “+”<opAlg2> <simOpAlg>
  new(TAS[VsimOpAlg,Tmas]);
  TAS[VsimOpAlg,Tmas]^.elem[1]:=Tmas;
  TAS[VsimOpAlg,Tmas]^.elem[2]:=VopAlg2;
  TAS[VsimOpAlg,Tmas]^.elem[3]:=VsimOpAlg;
  TAS[VsimOpAlg,Tmas]^.cant:=3;

  //<VsimOpAlg> -> “-”<opAlg2> <simOpAlg>
  new(TAS[VsimOpAlg,Tmenos]);
  TAS[VsimOpAlg,Tmenos]^.elem[1]:=Tmenos;
  TAS[VsimOpAlg,Tmenos]^.elem[2]:=VopAlg2;
  TAS[VsimOpAlg,Tmenos]^.elem[3]:=VsimOpAlg;
  TAS[VsimOpAlg,Tmenos]^.cant:=3;

  //<VsimOpAlg> -> Epsilon
  new(TAS[VsimOpAlg,TparenC]);
  TAS[VsimOpAlg,TparenC]^.cant:=0;

  //<VsimOpAlg> -> Epsilon
  new(TAS[VsimOpAlg,TdosPuntos]);
  TAS[VsimOpAlg,TdosPuntos]^.cant:=0;

  //<VsimOpAlg> -> Epsilon
  new(TAS[VsimOpAlg,Tarroba]);
  TAS[VsimOpAlg,Tarroba]^.cant:=0;

  //<VsimOpAlg> -> Epsilon
  new(TAS[VsimOpAlg,TunRelacional]);
  TAS[VsimOpAlg,TunRelacional]^.cant:=0;

  //<VsimOpAlg> -> Epsilon
  new(TAS[VsimOpAlg,TunRelacional]);
  TAS[VsimOpAlg,TunRelacional]^.cant:=0;

  //<VsimOpAlg> -> Pesos
  new(TAS[VsimOpAlg,Pesos]);
  TAS[VsimOpAlg,Pesos]^.cant:=0;

  //<opAlg2> -> <opAlg3> <simOpAlg2>
  new(TAS[VopAlg2,Tid]);
  TAS[VopAlg2,Tid]^.elem[1]:=VopAlg3;
  TAS[VopAlg2,Tid]^.elem[2]:=VsimOpAlg2;
  TAS[VopAlg2,Tid]^.cant:=2;

   //<opAlg2> -> <opAlg3> <simOpAlg2>
  new(TAS[VopAlg2,Tmenos]);
  TAS[VopAlg2,Tmenos]^.elem[1]:=VopAlg3;
  TAS[VopAlg2,Tmenos]^.elem[2]:=VsimOpAlg2;
  TAS[VopAlg2,Tmenos]^.cant:=2;

  //<opAlg2> -> <opAlg3> <simOpAlg2>
  new(TAS[VopAlg2,TConsReal]);
  TAS[VopAlg2,TConsReal]^.elem[1]:=VopAlg3;
  TAS[VopAlg2,TConsReal]^.elem[2]:=VsimOpAlg2;
  TAS[VopAlg2,TConsReal]^.cant:=2;

  //<opAlg2> -> <opAlg3> <simOpAlg2>
  new(TAS[VopAlg2,Tpotencia]);
  TAS[VopAlg2,Tpotencia]^.elem[1]:=VopAlg3;
  TAS[VopAlg2,Tpotencia]^.elem[2]:=VsimOpAlg2;
  TAS[VopAlg2,Tpotencia]^.cant:=2;

   //<opAlg2> -> <opAlg3> <simOpAlg2>
  new(TAS[VopAlg2,Traiz]);
  TAS[VopAlg2,Traiz]^.elem[1]:=VopAlg3;
  TAS[VopAlg2,Traiz]^.elem[2]:=VsimOpAlg2;
  TAS[VopAlg2,Traiz]^.cant:=2;

  //<opAlg2> -> <opAlg3> <simOpAlg2>
  new(TAS[VopAlg2,TparenA]);
  TAS[VopAlg2,TparenA]^.elem[1]:=VopAlg3;
  TAS[VopAlg2,TparenA]^.elem[2]:=VsimOpAlg2;
  TAS[VopAlg2,TparenA]^.cant:=2;

  //<simOpAlg2> -> Epsilon
  new(TAS[VsimOpAlg2,TpYc]);
  TAS[VsimOpAlg2,TpYc]^.cant:=0;

  //<simOpAlg2> -> Epsilon
  new(TAS[VsimOpAlg2,Tcoma]);
  TAS[VsimOpAlg2,Tcoma]^.cant:=0;

  //<simOpAlg2> -> Epsilon
  new(TAS[VsimOpAlg2,TllaveA]);
  TAS[VsimOpAlg2,TllaveA]^.cant:=0;

  //<simOpAlg2> -> Epsilon
  new(TAS[VsimOpAlg2,TllaveC]);
  TAS[VsimOpAlg2,TllaveC]^.cant:=0;

  //<simOpAlg2> -> Epsilon
  new(TAS[VsimOpAlg2,TcorC]);
  TAS[VsimOpAlg2,TcorC]^.cant:=0;

  //<simOpAlg2> -> Epsilon
  new(TAS[VsimOpAlg2,Tmas]);
  TAS[VsimOpAlg2,Tmas]^.cant:=0;

  //<simOpAlg2> -> Epsilon
  new(TAS[VsimOpAlg2,Tmenos]);
  TAS[VsimOpAlg2,Tmenos]^.cant:=0;

  //<simOpAlg2> -> "*" <opAlg3><simOpAlg2>
  new(TAS[VsimOpAlg2,Tpor]);
  TAS[VsimOpAlg2,Tpor]^.elem[1]:=Tpor;
  TAS[VsimOpAlg2,Tpor]^.elem[2]:=VopAlg3;
  TAS[VsimOpAlg2,Tpor]^.elem[3]:=VsimOpAlg2;
  TAS[VsimOpAlg2,Tpor]^.cant:=3;

  //<simOpAlg2> -> "/" <opAlg3><simOpAlg2>
  new(TAS[VsimOpAlg2,Tdivision]);
  TAS[VsimOpAlg2,Tdivision]^.elem[1]:=Tdivision;
  TAS[VsimOpAlg2,Tdivision]^.elem[2]:=VopAlg3;
  TAS[VsimOpAlg2,Tdivision]^.elem[3]:=VsimOpAlg2;
  TAS[VsimOpAlg2,Tdivision]^.cant:=3;

  //<simOpAlg2> -> Epsilon
  new(TAS[VsimOpAlg2,TparenC]);
  TAS[VsimOpAlg2,TparenC]^.cant:=0;

  //<simOpAlg2> -> Epsilon
  new(TAS[VsimOpAlg2,TdosPuntos]);
  TAS[VsimOpAlg2,TdosPuntos]^.cant:=0;

  //<simOpAlg2> -> Epsilon
  new(TAS[VsimOpAlg2,Tarroba]);
  TAS[VsimOpAlg2,Tarroba]^.cant:=0;

  //<simOpAlg2> -> Epsilon
  new(TAS[VsimOpAlg2,TunRelacional]);
  TAS[VsimOpAlg2,TunRelacional]^.cant:=0;

  //<simOpAlg2> -> Pesos
  new(TAS[VsimOpAlg2,Pesos]);
  TAS[VsimOpAlg2,Pesos]^.cant:=0;

  //<opAlg3> -> "id"<Vector>
  new(TAS[VopAlg3,Tid]);
  TAS[VopAlg3,Tid]^.elem[1]:=Tid;
  TAS[VopAlg3,Tid]^.elem[2]:=VVector;
  TAS[VopAlg3,Tid]^.cant:=2;

  //<opAlg3> -> “-”<opAlg3>
  new(TAS[VopAlg3,Tmenos]);
  TAS[VopAlg3,Tmenos]^.elem[1]:=Tmenos;
  TAS[VopAlg3,Tmenos]^.elem[2]:=VopAlg3;
  TAS[VopAlg3,Tmenos]^.cant:=2;

  //<opAlg3> -> ConsReal
  new(TAS[VopALg3,TConsReal]);
  TAS[VopALg3,TConsReal]^.elem[1]:=TConsReal;
  TAS[VopALg3,TConsReal]^.cant:=1;

  //<opAlg3> -> <Potencia>
  new(TAS[VopALg3,Tpotencia]);
  TAS[VopALg3,Tpotencia]^.elem[1]:=VPotencia;
  TAS[VopALg3,Tpotencia]^.cant:=1;

  //<opAlg3> -> <Potencia>
  new(TAS[VopALg3,Traiz]);
  TAS[VopALg3,Traiz]^.elem[1]:=VPotencia;
  TAS[VopALg3,Traiz]^.cant:=1;

  //<opAlg3> -> "(" <opArit> ")"
  new(TAS[VopAlg3,TparenA]);
  TAS[VopAlg3,TparenA]^.elem[1]:=TparenA;
  TAS[VopAlg3,TparenA]^.elem[2]:=VopArit;
  TAS[VopAlg3,TparenA]^.elem[3]:=TparenC;
  TAS[VopAlg3,TparenA]^.cant:=3;

  //<Vector> -> Epsilon
  new(TAS[VVector,TpYc]);
  TAS[VVector,TpYc]^.cant:=0;

  //<Vector> -> Epsilon
  new(TAS[VVector,Tcoma]);
  TAS[VVector,Tcoma]^.cant:=0;

  //<Vector> -> Epsilon
  new(TAS[VVector,TllaveA]);
  TAS[VVector,TllaveA]^.cant:=0;

  //<Vector> -> Epsilon
  new(TAS[VVector,TllaveC]);
  TAS[VVector,TllaveC]^.cant:=0;

  //<Vector> -> "[" <opArit> "]"
  new(TAS[VVector,TcorA]);
  TAS[VVector,TcorA]^.elem[1]:=TcorA;
  TAS[VVector,TcorA]^.elem[2]:=VopArit;
  TAS[VVector,TcorA]^.elem[3]:=TcorC;
  TAS[VVector,TcorA]^.cant:=3;

  //<Vector> -> Epsilon
  new(TAS[VVector,TcorC]);
  TAS[VVector,TcorC]^.cant:=0;

  //<Vector> -> Epsilon
  new(TAS[VVector,Tmas]);
  TAS[VVector,Tmas]^.cant:=0;

  //<Vector> -> Epsilon
  new(TAS[VVector,Tmenos]);
  TAS[VVector,Tmenos]^.cant:=0;

  //<Vector> -> Epsilon
  new(TAS[VVector,Tpor]);
  TAS[VVector,Tpor]^.cant:=0;

  //<Vector> -> Epsilon
  new(TAS[VVector,Tdivision]);
  TAS[VVector,Tdivision]^.cant:=0;

  //<Vector> -> Epsilon
  new(TAS[VVector,TparenC]);
  TAS[VVector,TparenC]^.cant:=0;

  //<Vector> -> Epsilon
  new(TAS[VVector,TdosPuntos]);
  TAS[VVector,TdosPuntos]^.cant:=0;

  //<Vector> -> Epsilon
  new(TAS[VVector,Tarroba]);
  TAS[VVector,Tarroba]^.cant:=0;

  //<Vector> -> Epsilon
  new(TAS[VVector,TunRelacional]);
  TAS[VVector,TunRelacional]^.cant:=0;

  //<Vector> -> Pesos
  new(TAS[VVector,Pesos]);
  TAS[VVector,Pesos]^.cant:=0;

  //<Potencia> -> "potencia" "(" "<Num_pot>" ")"
  new(TAS[VPotencia,Tpotencia]);
  TAS[VPotencia,Tpotencia]^.elem[1]:=Tpotencia;
  TAS[VPotencia,Tpotencia]^.elem[2]:=TparenA;
  TAS[VPotencia,Tpotencia]^.elem[3]:=VNum_pot;
  TAS[VPotencia,Tpotencia]^.elem[4]:=TParenC;
  TAS[VPotencia,Tpotencia]^.cant:=4;

  //<Potencia> -> "raiz" "(" "<Num_pot>" ")"
  new(TAS[VPotencia,Traiz]);
  TAS[VPotencia,Traiz]^.elem[1]:=Traiz;
  TAS[VPotencia,Traiz]^.elem[2]:=TparenA;
  TAS[VPotencia,Traiz]^.elem[3]:=VNum_pot;
  TAS[VPotencia,Traiz]^.elem[4]:=TParenC;
  TAS[VPotencia,Traiz]^.cant:=4;

  //<Num_pot> -> <opArit> "," <opArit>
  new(TAS[VNum_pot,Tid]);
  TAS[VNum_pot,Tid]^.elem[1]:=VopArit;
  TAS[VNum_pot,Tid]^.elem[2]:=Tcoma;
  TAS[VNum_pot,Tid]^.elem[3]:=VopArit;
  TAS[VNum_pot,Tid]^.cant:=3;

  //<Num_pot> -> <opArit> "," <opArit>
  new(TAS[VNum_pot,Tcoma]);
  TAS[VNum_pot,Tcoma]^.elem[1]:=VopArit;
  TAS[VNum_pot,Tcoma]^.elem[2]:=Tcoma;
  TAS[VNum_pot,Tcoma]^.elem[3]:=VopArit;
  TAS[VNum_pot,Tcoma]^.cant:=3;

  //<Num_pot> -> <opArit> "," <opArit>
  new(TAS[VNum_pot,Tmenos]);
  TAS[VNum_pot,Tmenos]^.elem[1]:=VopArit;
  TAS[VNum_pot,Tmenos]^.elem[2]:=Tcoma;
  TAS[VNum_pot,Tmenos]^.elem[3]:=VopArit;
  TAS[VNum_pot,Tmenos]^.cant:=3;

  //<Num_pot> -> <opArit> "," <opArit>
  new(TAS[VNum_pot,TConsReal]);
  TAS[VNum_pot,TConsReal]^.elem[1]:=VopArit;
  TAS[VNum_pot,TConsReal]^.elem[2]:=Tcoma;
  TAS[VNum_pot,TConsReal]^.elem[3]:=VopArit;
  TAS[VNum_pot,TConsReal]^.cant:=3;

  //<Num_pot> -> <opArit> "," <opArit>
  new(TAS[VNum_pot,Tpotencia]);
  TAS[VNum_pot,Tpotencia]^.elem[1]:=VopArit;
  TAS[VNum_pot,Tpotencia]^.elem[2]:=Tcoma;
  TAS[VNum_pot,Tpotencia]^.elem[3]:=VopArit;
  TAS[VNum_pot,Tpotencia]^.cant:=3;

  //<Num_pot> -> <opArit> "," <opArit>
  new(TAS[VNum_pot,Traiz]);
  TAS[VNum_pot,Traiz]^.elem[1]:=VopArit;
  TAS[VNum_pot,Traiz]^.elem[2]:=Tcoma;
  TAS[VNum_pot,Traiz]^.elem[3]:=VopArit;
  TAS[VNum_pot,Traiz]^.cant:=3;

  //<Num_pot> -> <opArit> "," <opArit>
  new(TAS[VNum_pot,TparenA]);
  TAS[VNum_pot,TparenA]^.elem[1]:=VopArit;
  TAS[VNum_pot,TparenA]^.elem[2]:=Tcoma;
  TAS[VNum_pot,TparenA]^.elem[3]:=VopArit;
  TAS[VNum_pot,TparenA]^.cant:=3;

  //<Condicion> -> "si" <Valor2> "{"<Cuerpo>"}" <Otro>
  new(TAS[VCondicion,Tsi]);
  TAS[VCondicion,Tsi]^.elem[1]:=Tsi;
  TAS[VCondicion,Tsi]^.elem[2]:=VValor2;
  TAS[VCondicion,Tsi]^.elem[3]:=TllaveA;
  TAS[VCondicion,Tsi]^.elem[4]:=VCuerpo;
  TAS[VCondicion,Tsi]^.elem[5]:=TllaveC;
  TAS[VCondicion,Tsi]^.elem[6]:=VOtro;
  TAS[VCondicion,Tsi]^.cant:=6;

  //<VOtro> -> Epsilon
  new(TAS[VOtro,TpYc]);
  TAS[VOtro,TpYc]^.cant:=0;

  //<VOtro> -> Epsilon
  new(TAS[VOtro,TllaveC]);
  TAS[VOtro,TllaveC]^.cant:=0;

  //<VOtro> -> “sino” "{"<Cuerpo>"}"
  new(TAS[VOtro,Tsino]);
  TAS[VOtro,Tsino]^.elem[1]:=Tsino;
  TAS[VOtro,Tsino]^.elem[2]:=TllaveA;
  TAS[VOtro,Tsino]^.elem[3]:=VCuerpo;
  TAS[VOtro,Tsino]^.elem[4]:=TllaveC;
  TAS[VOtro,Tsino]^.cant:=4;

  //<VOtro> -> Pesos
  new(TAS[VOtro,Pesos]);
  TAS[VOtro,Pesos]^.cant:=0;

  //<Valor2> -> <opLogico2> <simOpLogico>
  new(TAS[VValor2,Tid]);
  TAS[VValor2,Tid]^.elem[1]:=VopLogico2;
  TAS[VValor2,Tid]^.elem[2]:=VsimOpLogico;
  TAS[VValor2,Tid]^.cant:=2;

  //<Valor2> -> <opLogico2> <simOpLogico>
  new(TAS[VValor2,TllaveA]);
  TAS[VValor2,TllaveA]^.elem[1]:=VopLogico2;
  TAS[VValor2,TllaveA]^.elem[2]:=VsimOpLogico;
  TAS[VValor2,TllaveA]^.cant:=2;

  //<Valor2> -> <opLogico2> <simOpLogico>
  new(TAS[VValor2,Tmenos]);
  TAS[VValor2,Tmenos]^.elem[1]:=VopLogico2;
  TAS[VValor2,Tmenos]^.elem[2]:=VsimOpLogico;
  TAS[VValor2,Tmenos]^.cant:=2;

  //<Valor2> -> <opLogico2> <simOpLogico>
  new(TAS[VValor2,TConsReal]);
  TAS[VValor2,TConsReal]^.elem[1]:=VopLogico2;
  TAS[VValor2,TConsReal]^.elem[2]:=VsimOpLogico;
  TAS[VValor2,TConsReal]^.cant:=2;

  //<Valor2> -> <opLogico2> <simOpLogico>
  new(TAS[VValor2,Tpotencia]);
  TAS[VValor2,Tpotencia]^.elem[1]:=VopLogico2;
  TAS[VValor2,Tpotencia]^.elem[2]:=VsimOpLogico;
  TAS[VValor2,Tpotencia]^.cant:=2;

  //<Valor2> -> <opLogico2> <simOpLogico>
  new(TAS[VValor2,Traiz]);
  TAS[VValor2,Traiz]^.elem[1]:=VopLogico2;
  TAS[VValor2,Traiz]^.elem[2]:=VsimOpLogico;
  TAS[VValor2,Traiz]^.cant:=2;

  //<Valor2> -> <opLogico2> <simOpLogico>
  new(TAS[VValor2,TcorA]);
  TAS[VValor2,TcorA]^.elem[1]:=VopLogico2;
  TAS[VValor2,TcorA]^.elem[2]:=VsimOpLogico;
  TAS[VValor2,TcorA]^.cant:=2;

  //<Valor2> -> <opLogico2> <simOpLogico>
  new(TAS[VValor2,Tvirgulilla]);
  TAS[VValor2,Tvirgulilla]^.elem[1]:=VopLogico2;
  TAS[VValor2,Tvirgulilla]^.elem[2]:=VsimOpLogico;
  TAS[VValor2,Tvirgulilla]^.cant:=2;

  //<simOpLogico> -> Epsilon
  new(TAS[VsimOpLogico,TllaveA]);
  TAS[VsimOpLogico,TllaveA]^.cant:=0;

  //<simOpLogico> -> Epsilon
  new(TAS[VsimOpLogico,TllaveC]);
  TAS[VsimOpLogico,TllaveC]^.cant:=0;

  //<simOpLogico> -> “:” <opLogico2><simOpLogico>
  new(TAS[VsimOpLogico,TdosPuntos]);
  TAS[VsimOpLogico,TdosPuntos]^.elem[1]:=TdosPuntos;
  TAS[VsimOpLogico,TdosPuntos]^.elem[2]:=VopLogico2;
  TAS[VsimOpLogico,TdosPuntos]^.elem[3]:=VsimOpLogico;
  TAS[VsimOpLogico,TdosPuntos]^.cant:=3;

  //<opLogico2> -> <opLogico3><simOpLogico2>
  new(TAS[VopLogico2,Tid]);
  TAS[VopLogico2,Tid]^.elem[1]:=VopLogico3;
  TAS[VopLogico2,Tid]^.elem[2]:=VsimOpLogico2;
  TAS[VopLogico2,Tid]^.cant:=2;

  //<opLogico2> -> <opLogico3><simOpLogico2>
  new(TAS[VopLogico2,TllaveA]);
  TAS[VopLogico2,TllaveA]^.elem[1]:=VopLogico3;
  TAS[VopLogico2,TllaveA]^.elem[2]:=VsimOpLogico2;
  TAS[VopLogico2,TllaveA]^.cant:=2;

  //<opLogico2> -> <opLogico3><simOpLogico2>
  new(TAS[VopLogico2,Tmenos]);
  TAS[VopLogico2,Tmenos]^.elem[1]:=VopLogico3;
  TAS[VopLogico2,Tmenos]^.elem[2]:=VsimOpLogico2;
  TAS[VopLogico2,Tmenos]^.cant:=2;

  //<opLogico2> -> <opLogico3><simOpLogico2>
  new(TAS[VopLogico2,TConsReal]);
  TAS[VopLogico2,TConsReal]^.elem[1]:=VopLogico3;
  TAS[VopLogico2,TConsReal]^.elem[2]:=VsimOpLogico2;
  TAS[VopLogico2,TConsReal]^.cant:=2;

  //<opLogico2> -> <opLogico3><simOpLogico2>
  new(TAS[VopLogico2,Tpotencia]);
  TAS[VopLogico2,Tpotencia]^.elem[1]:=VopLogico3;
  TAS[VopLogico2,Tpotencia]^.elem[2]:=VsimOpLogico2;
  TAS[VopLogico2,Tpotencia]^.cant:=2;

  //<opLogico2> -> <opLogico3><simOpLogico2>
  new(TAS[VopLogico2,Traiz]);
  TAS[VopLogico2,Traiz]^.elem[1]:=VopLogico3;
  TAS[VopLogico2,Traiz]^.elem[2]:=VsimOpLogico2;
  TAS[VopLogico2,Traiz]^.cant:=2;

  //<opLogico2> -> <opLogico3><simOpLogico2>
  new(TAS[VopLogico2,TparenA]);
  TAS[VopLogico2,TparenA]^.elem[1]:=VopLogico3;
  TAS[VopLogico2,TparenA]^.elem[2]:=VsimOpLogico2;
  TAS[VopLogico2,TparenA]^.cant:=2;

  //<opLogico2> -> <opLogico3><simOpLogico2>
  new(TAS[VopLogico2,Tvirgulilla]);
  TAS[VopLogico2,Tvirgulilla]^.elem[1]:=VopLogico3;
  TAS[VopLogico2,Tvirgulilla]^.elem[2]:=VsimOpLogico2;
  TAS[VopLogico2,Tvirgulilla]^.cant:=2;

  //<simOpLogico2> -> Epsilon
  new(TAS[VsimOpLogico2,TllaveA]);
  TAS[VsimOpLogico2,TllaveA]^.cant:=0;

  //<simOpLogico2> -> Epsilon
  new(TAS[VsimOpLogico2,TllaveC]);
  TAS[VsimOpLogico2,TllaveC]^.cant:=0;

  //<simOpLogico2> -> Epsilon
  new(TAS[VsimOpLogico2,TdosPuntos]);
  TAS[VsimOpLogico2,TdosPuntos]^.cant:=0;

  //<simOpLogico2> -> "@" <opLogico3><simOpLogico2>
  new(TAS[VsimOpLogico2,Tarroba]);
  TAS[VsimOpLogico2,Tarroba]^.elem[1]:=Tarroba;
  TAS[VsimOpLogico2,Tarroba]^.elem[2]:=VopLogico3;
  TAS[VsimOpLogico2,Tarroba]^.elem[3]:=VsimOpLogico2;
  TAS[VsimOpLogico2,Tarroba]^.cant:=3;

  //<opLogico3> -> <opArit> “unRelacional” <opArit>
  new(TAS[VopLogico3,Tid]);
  TAS[VopLogico3,Tid]^.elem[1]:=VopArit;
  TAS[VopLogico3,Tid]^.elem[2]:=TunRelacional;
  TAS[VopLogico3,Tid]^.elem[3]:=VopArit;
  TAS[VopLogico3,Tid]^.cant:=3;

  //<opLogico3> -> "{" <Valor2> "}"
  new(TAS[VopLogico3,TllaveA]);
  TAS[VopLogico3,TllaveA]^.elem[1]:=TllaveA;
  TAS[VopLogico3,TllaveA]^.elem[2]:=VValor2;
  TAS[VopLogico3,TllaveA]^.elem[3]:=TllaveC;
  TAS[VopLogico3,TllaveA]^.cant:=3;

  //<opLogico3> -> <opArit> “unRelacional” <opArit>
  new(TAS[VopLogico3,Tmenos]);
  TAS[VopLogico3,Tmenos]^.elem[1]:=VopArit;
  TAS[VopLogico3,Tmenos]^.elem[2]:=TunRelacional;
  TAS[VopLogico3,Tmenos]^.elem[3]:=VopArit;
  TAS[VopLogico3,Tmenos]^.cant:=3;

  //<opLogico3> -> <opArit> “unRelacional” <opArit>
  new(TAS[VopLogico3,TConsReal]);
  TAS[VopLogico3,TConsReal]^.elem[1]:=VopArit;
  TAS[VopLogico3,TConsReal]^.elem[2]:=TunRelacional;
  TAS[VopLogico3,TConsReal]^.elem[3]:=VopArit;
  TAS[VopLogico3,TConsReal]^.cant:=3;

  //<opLogico3> -> <opArit> “unRelacional” <opArit>
  new(TAS[VopLogico3,Tpotencia]);
  TAS[VopLogico3,Tpotencia]^.elem[1]:=VopArit;
  TAS[VopLogico3,Tpotencia]^.elem[2]:=TunRelacional;
  TAS[VopLogico3,Tpotencia]^.elem[3]:=VopArit;
  TAS[VopLogico3,Tpotencia]^.cant:=3;

  //<opLogico3> -> <opArit> “unRelacional” <opArit>
  new(TAS[VopLogico3,Traiz]);
  TAS[VopLogico3,Traiz]^.elem[1]:=VopArit;
  TAS[VopLogico3,Traiz]^.elem[2]:=TunRelacional;
  TAS[VopLogico3,Traiz]^.elem[3]:=VopArit;
  TAS[VopLogico3,Traiz]^.cant:=3;

  //<opLogico3> -> <opArit> “unRelacional” <opArit>
  new(TAS[VopLogico3,TparenA]);
  TAS[VopLogico3,TparenA]^.elem[1]:=VopArit;
  TAS[VopLogico3,TparenA]^.elem[2]:=TunRelacional;
  TAS[VopLogico3,TparenA]^.elem[3]:=VopArit;
  TAS[VopLogico3,TparenA]^.cant:=3;

  //<opLogico3> -> “~” <opLogico3>
  new(TAS[VopLogico3,Tvirgulilla]);
  TAS[VopLogico3,Tvirgulilla]^.elem[1]:=Tvirgulilla;
  TAS[VopLogico3,Tvirgulilla]^.elem[2]:=VopLogico3;
  TAS[VopLogico3,Tvirgulilla]^.cant:=2;

  //<Leer> -> "leer" "(" “cadena” “,” “id” ")"
  new(TAS[VLeer,Tleer]);
  TAS[VLeer,Tleer]^.elem[1]:=Tleer;
  TAS[VLeer,Tleer]^.elem[2]:=TparenA;
  TAS[VLeer,Tleer]^.elem[3]:=Tcadena;
  TAS[VLeer,Tleer]^.elem[4]:=Tcoma;
  TAS[VLeer,Tleer]^.elem[5]:=Tid;
  TAS[VLeer,Tleer]^.elem[6]:=TparenC;
  TAS[VLeer,Tleer]^.cant:=6;

  //<Mostrar> -> "imprime" "(" <Muestra> ")"
  new(TAS[VMostrar,Timprime]);
  TAS[VMostrar,Timprime]^.elem[1]:=Timprime;
  TAS[VMostrar,Timprime]^.elem[2]:=TparenA;
  TAS[VMostrar,Timprime]^.elem[3]:=VMuestra;
  TAS[VMostrar,Timprime]^.elem[4]:=TparenC;
  TAS[VMostrar,Timprime]^.cant:=4;

  //<Muestra> -> <OpArit><simMuestra>
  new(TAS[VMuestra,Tid]);
  TAS[VMuestra,Tid]^.elem[1]:=VopArit;
  TAS[VMuestra,Tid]^.elem[2]:=VsimMuestra;
  TAS[VMuestra,Tid]^.cant:=2;

  //<Muestra> -> "cadena"<simMuestra>
  new(TAS[VMuestra,Tcadena]);
  TAS[VMuestra,Tcadena]^.elem[1]:=Tcadena;
  TAS[VMuestra,Tcadena]^.elem[2]:=VsimMuestra;
  TAS[VMuestra,Tcadena]^.cant:=2;

  //<Muestra> -> <OpArit><simMuestra>
  new(TAS[VMuestra,Tmenos]);
  TAS[VMuestra,Tmenos]^.elem[1]:=VopArit;
  TAS[VMuestra,Tmenos]^.elem[2]:=VsimMuestra;
  TAS[VMuestra,Tmenos]^.cant:=2;

  //<Muestra> -> <OpArit><simMuestra>
  new(TAS[VMuestra,TConsReal]);
  TAS[VMuestra,TConsReal]^.elem[1]:=VopArit;
  TAS[VMuestra,TConsReal]^.elem[2]:=VsimMuestra;
  TAS[VMuestra,TConsReal]^.cant:=2;

  //<Muestra> -> <OpArit><simMuestra>
  new(TAS[VMuestra,Tpotencia]);
  TAS[VMuestra,Tpotencia]^.elem[1]:=VopArit;
  TAS[VMuestra,Tpotencia]^.elem[2]:=VsimMuestra;
  TAS[VMuestra,Tpotencia]^.cant:=2;

  //<Muestra> -> <OpArit><simMuestra>
  new(TAS[VMuestra,Traiz]);
  TAS[VMuestra,Traiz]^.elem[1]:=VopArit;
  TAS[VMuestra,Traiz]^.elem[2]:=VsimMuestra;
  TAS[VMuestra,Traiz]^.cant:=2;

  //<Muestra> -> <OpArit><simMuestra>
  new(TAS[VMuestra,TparenA]);
  TAS[VMuestra,TparenA]^.elem[1]:=VopArit;
  TAS[VMuestra,TparenA]^.elem[2]:=VsimMuestra;
  TAS[VMuestra,TparenA]^.cant:=2;

  //<simMuestra> -> ”,”<simMuestra2>
  new(TAS[VsimMuestra,Tcoma]);
  TAS[VsimMuestra,Tcoma]^.elem[1]:=Tcoma;
  TAS[VsimMuestra,Tcoma]^.elem[2]:=VsimMuestra2;
  TAS[VsimMuestra,Tcoma]^.cant:=2;

  //<simMuestra> -> Epsilon
  new(TAS[VsimMuestra,TparenC]);
  TAS[VsimMuestra,TparenC]^.cant:=0;

  //<simMuestra2> -> <OpArit><simMuestra>
  new(TAS[VsimMuestra2,Tid]);
  TAS[VsimMuestra2,Tid]^.elem[1]:=VopArit;
  TAS[VsimMuestra2,Tid]^.elem[2]:=VsimMuestra;
  TAS[VsimMuestra2,Tid]^.cant:=2;

  //<simMuestra2> -> "cadena"<simMuestra>
  new(TAS[VsimMuestra2,Tcadena]);
  TAS[VsimMuestra2,Tcadena]^.elem[1]:=Tcadena;
  TAS[VsimMuestra2,Tcadena]^.elem[2]:=VsimMuestra;
  TAS[VsimMuestra2,Tcadena]^.cant:=2;

  //<simMuestra2> -> <OpArit><simMuestra>
  new(TAS[VsimMuestra2,Tmenos]);
  TAS[VsimMuestra2,Tmenos]^.elem[1]:=VopArit;
  TAS[VsimMuestra2,Tmenos]^.elem[2]:=VsimMuestra;
  TAS[VsimMuestra2,Tmenos]^.cant:=2;

  //<simMuestra2> -> <OpArit><simMuestra>
  new(TAS[VsimMuestra2,TConsReal]);
  TAS[VsimMuestra2,TConsReal]^.elem[1]:=VopArit;
  TAS[VsimMuestra2,TConsReal]^.elem[2]:=VsimMuestra;
  TAS[VsimMuestra2,TConsReal]^.cant:=2;

  //<simMuestra2> -> <OpArit><simMuestra>
  new(TAS[VsimMuestra2,Tpotencia]);
  TAS[VsimMuestra2,Tpotencia]^.elem[1]:=VopArit;
  TAS[VsimMuestra2,Tpotencia]^.elem[2]:=VsimMuestra;
  TAS[VsimMuestra2,Tpotencia]^.cant:=2;

  //<simMuestra2> -> <OpArit><simMuestra>
  new(TAS[VsimMuestra2,Traiz]);
  TAS[VsimMuestra2,Traiz]^.elem[1]:=VopArit;
  TAS[VsimMuestra2,Traiz]^.elem[2]:=VsimMuestra;
  TAS[VsimMuestra2,Traiz]^.cant:=2;

  //<simMuestra2> -> <OpArit><simMuestra>
  new(TAS[VsimMuestra2,TparenA]);
  TAS[VsimMuestra2,TparenA]^.elem[1]:=VopArit;
  TAS[VsimMuestra2,TparenA]^.elem[2]:=VsimMuestra;
  TAS[VsimMuestra2,TparenA]^.cant:=2;

  //<Ciclo> -> "mientras" <Valor2> "{" "<Cuerpo>" "}"
  new(TAS[VCiclo,Tmientras]);
  TAS[VCiclo,Tmientras]^.elem[1]:=Tmientras;
  TAS[VCiclo,Tmientras]^.elem[2]:=VValor2;
  TAS[VCiclo,Tmientras]^.elem[3]:=TllaveA;
  TAS[VCiclo,Tmientras]^.elem[4]:=VCuerpo;
  TAS[VCiclo,Tmientras]^.elem[5]:=TllaveC;
  TAS[VCiclo,Tmientras]^.cant:=5;
end;

Procedure Crear_Nodo(SG:TipoSG; VAR aPuntador:TAPuntNodo);
begin
  new(aPuntador);
  aPuntador^.simbolo:=SG;
  aPuntador^.lexema:='';
  aPuntador^.hijos.cant:=0;
end;

Procedure Agregar_Hijo(VAR raiz:TAPuntNodo; VAR hijo:TAPuntNodo);
begin
  If raiz^.hijos.cant<MaxProd then
  begin
    inc(raiz^.hijos.cant);
    raiz^.hijos.elem[raiz^.hijos.cant]:=hijo;
  end;
end;
      //Analizador Descendente Predictivo: Crea la TAS y analiza la sintaxis para devolver si es válida o no
Procedure Abrir_Archivo (VAR Fuente:FileOfChar; Ruta: string);
begin
  assign(Fuente,Ruta);
  {$i-}
  reset(fuente);
  {$i+}
  if IOresult<>0 then
  begin
    writeln('ERROR AL CARGAR ARCHIVO');
    readkey;
  end;
end;

Procedure Analizador_Predictivo(RutaFuente:string;VAR Arbol:TAPuntNodo;VAR Error:boolean);
VAR
  TAS: TTas;
  Pila:TPila;
  Control: longint;
  TS: TablaDeSimbolos;
  EPila: TElemPila;
  car:char;
  Estado: (EnProceso,ErrorLexico,ErrorSintactico,Exito);
  CompLex: TipoSG;
  Fuente: FileOfChar;
  Lexema: string;
  I: 0..MaxProd;
  Auxiliar,VLenguaje: TipoSG;
  Aux2: TApuntNodo;
begin
  Abrir_Archivo(Fuente,RutaFuente);
  read(fuente,car);
  InicializarTS(TS);  //Inicializa TS
  ComPletarTS(TS);     //Carga TS
  IniciarTAS(TAS);   //Inicializa TAS con Nil
  CargarTAS(TAS);      //Completa TAS con gramática
  CrearPila(Pila);      //Crea/Inicializa la pila
  Crear_Nodo(VLenguaje,Arbol);  //Crea el primer nodo
  EPila.simbolo:=Pesos;       //Apila Pesos al fondo de la pila
  EPila.NodoArbol:=nil;
  APilar(Pila,EPila);
  EPila.Simbolo:=VLenguaje;
  EPila.NodoArbol:=Arbol;
  APilar(Pila,EPila);
  Control:=0;               //Inicializa el control
  ObtenerSiguienteComPLex(Fuente,Control,ComPLex,Lexema,TS);     //Comienza a analizar
  Estado:=EnProceso;                                           //Inicializa la variable de estado
  while (Estado=EnProceso) do
   begin
     DesaPilar(Pila,EPila);
     If EPila.simbolo in [TProgramita..TcorC] then             //Desapila un Terminal
     begin
       If EPila.simbolo=ComPLex then
       begin
         writeln(lexema);
         EPila.NodoArbol^.lexema:=lexema;                                 //Agrega al árbol y obtiene siguiente
         ObtenerSiguienteComPlex(Fuente,Control,ComPLex,Lexema,TS);       //Caso exitoso
       end
       else
       begin
         Estado:=errorSintactico;                                      //Muestra y pone estado en caso de error
         writeln('EL PROGRAMA TIENE: ',ComPLex, ' PERO DEBIA SER: ',EPila.simbolo);
         writeln(control);
         Error:=true;
       end;
     end;
     If EPila.simbolo in [VLenguaje..VcontVector2] then          //Desapila una Variable
     begin
       If TAS[EPila.simbolo,ComPLex]=nil then
       begin
        estado:=errorSintactico;                                     //Muestra y pone estado en caso de error
        writeln('EL PROGRAMA TIENE: ',ComPLex, ' PERO DEBIA SER: ',EPila.simbolo);
        writeln(control);
        Error:=true;
       end
       else
       begin                                                //En caso de éxito, deriva la variable y va creando el árbol
         For I:=1 to TAS[EPila.simbolo,ComPLex]^.cant do
         begin
            writeln(TAS[EPila.simbolo,ComPLex]^.elem[I]);
            Auxiliar:=TAS[EPila.simbolo,ComPLex]^.elem[I];     //Utiliza un auxiliar para obtener cada derivación
            Crear_Nodo(Auxiliar,aux2);                   //Crea el nodo con la derivación
            Agregar_Hijo(EPila.NodoArbol,aux2);               //Agrega el hijo de la derivación
         end;
        APilarTodos(TAS[EPila.simbolo,ComPLex]^,EPila.NodoArbol,Pila);     //Apila toda la derivación
     end;
     end
     else
     begin
     If (ComPLex=Pesos) and (EPila.simbolo=Pesos) then         //Si se alcanza pesos es porque no hay errores sintáctivos
       begin
         Estado:=Exito;                                      //Se coloca estado de éxito
         Error:=false;                                       //El error se coloca como inexistente
       end;
     end;
   end;
Close(Fuente);                                              //Se cierra el archivo
end;
end.
