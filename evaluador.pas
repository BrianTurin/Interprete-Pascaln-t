unit evaluador;
interface

uses
  crt, math, analizador_sintactico, tipos,sysutils;
const
  MaxVar = 200;
  MaxReal = 200;
  MaxArreglo = 100;
type
//Las variables pueden ser reales o vectores
    Ttipo = (T_Real,T_Vector);

//Cada componente del estado es capaz de almacenar un real o valores de vector
  TElemEstado=record
    lexemaId:string;
    ValReal:real;
    Tipo:TTipo;
    ValArray:array[1..MaxArreglo] of real;
    CantArray:byte;
  end;

//Vector de Estados
  TEstado=record
    elementos:array [1..maxVar] of TElemEstado;
    cant:word;
  end;

//Procedimientos y funciones auxiliares
Procedure InicializarEst(VAR Estado:TEstado);
Procedure agregar_variable(VAR Estado:TEstado;VAR id:string;VAR tipo:TTipo;VAR Tamanio:real);
Function valor_real(valorCadena: string):real;
Function valor_vector_pos(VAR Estado:TEstado; id:string; Tamanio:word):real;
Procedure cambiar_valor(VAR Estado:TEstado; id: string; valor: real; pos_vector:word);

//Evaluadores
Procedure evaluador_Lenguaje(VAR Arbol:TApuntNodo; VAR Estado:TEstado);
Procedure evaluador_Leng2(VAR Arbol:TApuntNodo; VAR Estado:TEstado);
Procedure evaluador_Titulo(VAR Arbol:TApuntNodo; VAR Estado:TEstado);
Procedure evaluador_Leng3(VAR Arbol:TApuntNodo; VAR Estado:TEstado);
Procedure evaluador_Defs(VAR Arbol:TApuntNodo; VAR Estado:TEstado);
Procedure evaluador_Defs2(VAR Arbol:TApuntNodo; VAR Estado:TEstado; id:string);
Procedure evaluador_Defs3(VAR Arbol:TApuntNodo; VAR Estado:TEstado);
Procedure evaluador_Cuerpo(VAR Arbol:TApuntNodo; VAR Estado:TEstado);
Procedure evaluador_Cuerpo2(VAR Arbol:TApuntNodo; VAR Estado:TEstado);
Procedure evaluador_Sentencia(VAR Arbol:TApuntNodo; VAR Estado:TEstado);
Procedure evaluador_opArit(VAR Arbol:TApuntNodo; VAR Estado:TEstado;VAR Resultado:real);
Procedure evaluador_opAlg2(VAR Arbol:TApuntNodo; VAR Estado:TEstado;VAR Operando1:real);
Procedure evaluador_simOpAlg(VAR Arbol:TApuntNodo; VAR Estado:TEstado;VAR Operando1:real;VAR Resultado:real);
Procedure evaluador_opAlg3(VAR Arbol:TApuntNodo; VAR Estado:TEstado;VAR Operando3:real);
Procedure evaluador_Vector(VAR Arbol:TApuntNodo; VAR Estado:TEstado;id:string;VAR Tamanio:real);
Procedure evaluador_Potencia(VAR Arbol:TApuntNodo; VAR Estado:TEstado;VAR Resultado:real);
Procedure evaluador_Num_pot(VAR Arbol:TApuntNodo; VAR Estado:TEstado;VAR Exponente:real;VAR Base: real);
Procedure evaluador_Condicion(VAR Arbol:TApuntNodo; VAR Estado:TEstado);
Procedure evaluador_Valor2(VAR Arbol:TApuntNodo; VAR Estado:TEstado;VAR Verdad:boolean);
Procedure evaluador_simOpLogico(VAR Arbol:TApuntNodo; VAR Estado:TEstado;VAR Verdad:boolean;VAR Verdad2:boolean);
Procedure evaluador_opLogico2(VAR Arbol:TApuntNodo; VAR Estado:TEstado;VAR Verdad3:boolean);
Procedure evaluador_simOpLogico2(VAR Arbol:TApuntNodo; VAR Estado:TEstado;VAR Verdad3:boolean; VAR Verdad4:boolean);
Procedure evaluador_opLogico3(VAR Arbol:TApuntNodo; VAR Estado:TEstado;VAR Verdad5:boolean);
Procedure evaluador_Otro(VAR Arbol:TApuntNodo; VAR Estado:TEstado);
Procedure evaluador_Ciclo(VAR Arbol:TApuntNodo; VAR Estado:TEstado);
Procedure evaluador_Leer(VAR Arbol:TApuntNodo; VAR Estado:TEstado);
Procedure evaluador_Mostrar (VAR Arbol:TApuntNodo; VAR Estado:TEstado);
Procedure evaluador_Muestra(VAR Arbol:TApuntNodo; VAR Estado:TEstado);
Procedure evaluador_simMuestra (VAR Arbol:TApuntNodo; VAR Estado:TEstado);
Procedure evaluador_simMuestra2 (VAR Arbol:TApuntNodo; VAR Estado:TEstado);
Procedure evaluador_Asignacion(VAR Arbol:TApuntNodo; VAR Estado:TEstado);
Procedure evaluador_Asignacion2(VAR Arbol:TApuntNodo; VAR Estado:TEstado; id:string);
Procedure evaluador_Asignacion3(VAR Arbol:TApuntNodo; VAR Estado:TEstado; VAR Valor:real);
Procedure evaluador_contVector (VAR Arbol:TApuntNodo; VAR Estado:TEstado);
Procedure evaluador_contVector2 (VAR Arbol:TApuntNodo; VAR Estado:TEstado);
implementation

//Inicializa el vector de Estado
procedure InicializarEst(VAR Estado:TEstado);
begin
  Estado.cant:=0;
end;

//Agrega una variable en el vector de Estado
Procedure agregar_variable(VAR Estado:TEstado;VAR id:string;VAR tipo:TTipo;VAR Tamanio:real);
VAR
   I:byte;
   aux: word;
begin
  aux := floor(Tamanio);
  Estado.cant := Estado.cant + 1;
  Estado.elementos[Estado.cant].lexemaId:=id;
  Estado.elementos[Estado.cant].Tipo:=tipo;
  If tipo = T_Vector then
  begin
   Estado.elementos[Estado.cant].CantArray:=aux;
   For I:=1 to aux do
   begin
     Estado.elementos[Estado.cant].ValArray[I]:=0;
   end
  end
  else
  begin
    If tipo = T_Real then
    begin
      Estado.elementos[Estado.cant].ValReal:=0;
      Estado.elementos[Estado.cant].CantArray:=0;
    end;
  end;
end;

//Transforma un valor en cadena a un valor como número real
Function valor_real(valorCadena: string):real;
VAR
   aux: integer;
   valorFinal: real;
begin
  valorFinal := 0;
  val(valorCadena,valorFinal,aux);
  If aux <> 0 then
  begin
       writeln('UN LEXEMA INCORRECTO SE INTENTO TRANSFORMAR');
       writeln('EL LEXEMA ES: ',valorCadena);
  end
  else
  begin
    valor_real:= valorFinal;
  end;
end;

Function valor_vector_pos(VAR Estado:TEstado; id:string; Tamanio:word):real;
VAR
   I: word;
begin
   For I:=1 to Estado.cant do
   begin
     If Estado.elementos[I].lexemaId = id then
     begin
          If Estado.elementos[I].Tipo = T_Real then
          begin
               valor_vector_pos := Estado.elementos[I].ValReal;
          end
          else
          begin
               valor_vector_pos := Estado.elementos[I].ValArray[Tamanio];
          end;
     end;
   end;
end;

//Actualiza el valor de una variable
Procedure cambiar_valor(VAR Estado:TEstado; id: string; valor: real; pos_vector:word);
VAR
   I:word;
begin
  For I:=1 to Estado.cant do
  begin
    If Estado.elementos[I].LexemaId = id then
    begin
         If Estado.elementos[I].Tipo = T_Real then
         begin
              Estado.elementos[I].ValReal := valor;
         end
         else
         begin
              Estado.elementos[I].ValArray[pos_vector]:= valor;
         end;
    end;
  end;
end;

//<Lenguaje> ::= “Programita” <Leng2>
Procedure evaluador_Lenguaje(VAR Arbol:TApuntNodo; VAR Estado:TEstado);
begin
    evaluador_Leng2(Arbol^.hijos.elem[2], Estado);
End;

//<Leng2> ::= <Titulo> <Leng3>
Procedure evaluador_Leng2(VAR Arbol:TApuntNodo; VAR Estado:TEstado);
begin
    evaluador_Titulo(Arbol^.hijos.elem[1],Estado);
    evaluador_Leng3(Arbol^.hijos.elem[2],Estado);
end;

//<Titulo> ::= ε | “seLlama” “cadena” “;”
Procedure evaluador_Titulo(VAR Arbol:TApuntNodo; VAR Estado:TEstado);
begin
end;

//<Leng3> ::= “definicion” <Defs> “;” “{“ <Cuerpo> “}” |  “{“ <Cuerpo> “}”
Procedure evaluador_Leng3(VAR Arbol:TApuntNodo; VAR Estado:TEstado);
begin
    If Arbol^.hijos.elem[1]^.Simbolo = Tdefinicion then
    begin
      evaluador_Defs(Arbol^.hijos.elem[2],Estado);
      evaluador_Cuerpo(Arbol^.hijos.elem[5],Estado);
    end
    else
    begin
      If Arbol^.hijos.elem[1]^.Simbolo = TllaveA then
      begin
         evaluador_Cuerpo(Arbol^.hijos.elem[2],Estado);
      end;
    end;
end;

//<Defs> ::= “id” <Defs2>
Procedure evaluador_Defs(VAR Arbol:TApuntNodo; VAR Estado:TEstado);
begin
  If Arbol^.hijos.cant > 0 then
    evaluador_Defs2(Arbol^.hijos.elem[2], Estado,Arbol^.hijos.elem[1]^.Lexema) //La ultima variable (lexema) es el id
    //agregar_variable(VAR Estado,Arbol.hijos[1].lexema,tipo)
end;

//<Defs2> ::=  “vector” "[" <OpArit> "]" <Defs3> | “,” <Defs> | ε

Procedure evaluador_Defs2(VAR Arbol:TApuntNodo; VAR Estado:TEstado; id:string);
VAR
  tipo: TTipo;
  Tamanio: real;
begin
  If arbol^.hijos.cant > 0 then
  begin
    If Arbol^.hijos.elem[1]^.Simbolo = Tvector then
    begin
      tipo := T_vector;
      evaluador_opArit(Arbol^.hijos.elem[3],Estado,Tamanio);
      agregar_variable(Estado,id,tipo,Tamanio);
      evaluador_Defs3(Arbol^.hijos.elem[5],Estado);
    end
    else
    begin
      If Arbol^.hijos.elem[1]^.Simbolo = Tcoma then
      begin
         tipo := T_Real;
         agregar_variable(Estado,id,tipo,Tamanio);
	 evaluador_Defs(Arbol^.hijos.elem[2],Estado);
      end;
    end;
  end
  else
  begin
    tipo := T_Real;
    agregar_variable(Estado,id,tipo,Tamanio);
  end;
end;

{Procedure evaluador_Defs2(VAR Arbol:TApuntNodo; VAR Estado:TEstado; id:string);
VAR
  tipo: TTipo;
  Tamanio: real;
begin
  If arbol^.hijos.cant > 0 then
  begin
    If Arbol^.hijos.elem[1]^.Simbolo = Tvector then
    begin
      evaluador_Vector(Arbol^.hijos.elem[2],Estado,id,Tamanio);
      tipo := T_vector;
      agregar_variable(Estado,id,tipo,Tamanio);
      evaluador_Defs3(Arbol^.hijos.elem[3],Estado);
    end
    else
    begin
      If Arbol^.hijos.elem[1]^.Simbolo = Tcoma then
      begin
         tipo := T_Real;
         agregar_variable(Estado,id,tipo,Tamanio);
	 evaluador_Defs(Arbol^.hijos.elem[2],Estado);
      end;
    end;
  end
  else
  begin
    tipo := T_Real;
    agregar_variable(Estado,id,tipo,Tamanio);
  end;
end;  }

//<Defs3> ::=   “,” <Defs>  | ε
Procedure  evaluador_Defs3(VAR Arbol:TApuntNodo; VAR Estado:TEstado);
begin
   If Arbol^.hijos.cant > 0 then//If Arbol^.hijos.elem[1]^.Simbolo = Tcoma then
      evaluador_Defs(Arbol^.hijos.elem[2],Estado);
end;


//<Cuerpo> ::= <Sentencia> <Cuerpo2>
Procedure evaluador_Cuerpo(VAR Arbol:TApuntNodo; VAR Estado:TEstado);
begin
       evaluador_Sentencia(Arbol^.hijos.elem[1],Estado);
       evaluador_Cuerpo2(Arbol^.hijos.elem[2],Estado);
end;

//<Cuerpo2> ::= “;” <Cuerpo> | ε
Procedure evaluador_Cuerpo2(VAR Arbol:TApuntNodo; VAR Estado:TEstado);
begin
 If arbol^.hijos.cant > 0 then //If Arbol^.hijos.elem[1]^.Simbolo=TpYc then
    evaluador_Cuerpo(Arbol^.hijos.elem[2],Estado);
end;

//<Sentencia> ::= <Condicion> | <Ciclo> | <Leer> | <Asignacion> | <Mostrar>
Procedure evaluador_Sentencia(VAR Arbol:TApuntNodo; VAR Estado:TEstado);
begin
   Case Arbol^.hijos.elem[1]^.Simbolo of
   VCondicion:evaluador_Condicion(Arbol^.hijos.elem[1],Estado);
   VCiclo:evaluador_Ciclo(Arbol^.hijos.elem[1],Estado);
   VLeer:evaluador_Leer(Arbol^.hijos.elem[1],Estado);
   VAsignacion:evaluador_Asignacion(Arbol^.hijos.elem[1],Estado);
   VMostrar:evaluador_Mostrar(Arbol^.hijos.elem[1],Estado);
   end;
end;

//<opArit> ::= <opAlg2> <simOpAlg>
Procedure evaluador_opArit(VAR Arbol:TApuntNodo; VAR Estado:TEstado;VAR Resultado:real);
VAR
  Operando1: real;
begin;
   evaluador_opAlg2(Arbol^.hijos.elem[1],Estado,Operando1);
   evaluador_simOpAlg(Arbol^.hijos.elem[2],Estado,Operando1,Resultado);
end;

//<simOpAlg> ::= “+” <opAlg2> <simOpAlg> | “-” <opAlg2> <simOpAlg> | ε
Procedure evaluador_simOpAlg(VAR Arbol:TApuntNodo; VAR Estado:TEstado;VAR Operando1:real;VAR Resultado:real);
VAR
  Operando2: real;
begin
   If arbol^.hijos.cant > 0 then //If (Arbol^.hijos.elem[1]^.Simbolo=Tmas) or (Arbol^.hijos.elem[1]^.Simbolo=Tmenos) then
   begin
        If Arbol^.hijos.elem[1]^.Simbolo=Tmas then
        begin
             evaluador_opAlg2(Arbol^.hijos.elem[2],Estado,Operando2);
             Operando1 := Operando1 + Operando2;
           //  writeln();
             evaluador_simOpAlg(Arbol^.hijos.elem[3],Estado,Operando1,Resultado);
        end
        else
        begin
             evaluador_opAlg2(Arbol^.hijos.elem[2],Estado,Operando2);
             Operando1 := Operando1 - Operando2;
             evaluador_simOpAlg(Arbol^.hijos.elem[3],Estado,Operando1,Resultado);
        end;
   end
   else
       Resultado := Operando1;
end;

//<simOpAlg2> ::=  “*” <opAlg3> <simOpAlg2> | “/” <opAlg3> <simOpAlg2> | ε
Procedure evaluador_simOpAlg2(VAR Arbol:TApuntNodo; VAR Estado:TEstado; VAR Operando2: real; VAR Operando1: real);
VAR
  Operando3: real;
begin
   If arbol^.hijos.cant > 0 then //If (Arbol^.hijos.elem[1]^.Simbolo=Tpor) or (Arbol^.hijos.elem[1]^.Simbolo=Tdivision) then
   begin
        If Arbol^.hijos.elem[1]^.Simbolo=Tpor then
        begin
             evaluador_opAlg3(Arbol^.hijos.elem[2],Estado,Operando3);
             Operando2 := Operando2 * Operando3;
             evaluador_simOpAlg2(Arbol^.hijos.elem[3],Estado,Operando2,Operando1);
        end
        else
        begin
             evaluador_opAlg3(Arbol^.hijos.elem[2],Estado,Operando3);
             If Operando3 = 0 then
             begin
                  writeln('USTED INTENTA DIVIDIR POR 0. EL EVALUADOR FALLA');
                  readkey;
             end
             else
             begin
             Operando2 := Operando2 / Operando3;
             evaluador_simOpAlg2(Arbol^.hijos.elem[3],Estado,Operando2,Operando1);
             end;
        end;
   end
   else
   begin
     Operando1 := Operando2;
   end;
end;

//<opAlg2> ::= <opAlg3> <simOpAlg2>
Procedure evaluador_opAlg2(VAR Arbol:TApuntNodo; VAR Estado:TEstado;VAR Operando1:real);
VAR
  Operando2: real;
begin
   evaluador_opAlg3(Arbol^.hijos.elem[1],Estado,Operando2);
   evaluador_simOpAlg2(Arbol^.hijos.elem[2],Estado,Operando2,Operando1);
end;

//<opAlg3> ::= “id” <Vector> | “-” <opAlg3> | “ConsReal” | <Potencia> | “(“ <opArit> “)”
Procedure evaluador_opAlg3(VAR Arbol:TApuntNodo; VAR Estado:TEstado;VAR Operando3:real);
begin
   Case Arbol^.hijos.elem[1]^.Simbolo of
      Tid:evaluador_Vector(Arbol^.hijos.elem[2],Estado,Arbol^.hijos.elem[1]^.lexema,Operando3);
      Tmenos:
      begin
        evaluador_opAlg3(Arbol^.hijos.elem[2],Estado,Operando3);
        Operando3 := (-1) * Operando3;
      end;
      TConsReal: Operando3 := valor_real(Arbol^.hijos.elem[1]^.lexema);
      VPotencia:evaluador_Potencia(Arbol^.hijos.elem[1],Estado,Operando3);
      TparenA:evaluador_opArit(Arbol^.hijos.elem[2],Estado,Operando3);
   end;
end;

//<Vector> ::= “[“ <opArit> “]” | E
Procedure evaluador_Vector(VAR Arbol:TApuntNodo; VAR Estado:TEstado;id:string;VAR Tamanio:real);
VAR
  aux: real;
  aux2: word;
begin
   If Arbol^.hijos.cant > 0 then //Arbol^.hijos.elem[1]^.Simbolo = TcorA then
   begin
        evaluador_opArit(Arbol^.hijos.elem[2],Estado,aux);
        aux2 := floor(aux);
        Tamanio := valor_vector_pos(Estado,id,aux2);
   end
   else
   begin
        aux2 :=0;
        Tamanio := valor_vector_pos(Estado,id,aux2);
   end;
end;

//<Potencia> ::= “potencia” “(“ <Num_pot> “)” | “raiz” “(“ <Num_pot> “)”
Procedure evaluador_Potencia(VAR Arbol:TApuntNodo; VAR Estado:TEstado;VAR Resultado:real);
VAR
  Exponente,Base: real;
begin
   If Arbol^.hijos.elem[1]^.Simbolo = Tpotencia then
   begin
        evaluador_Num_pot(Arbol^.hijos.elem[3],Estado,Exponente,Base);
        Resultado := Base**Exponente;
        //Resultado := power(Base,Exponente);
   end
   else
       If Arbol^.hijos.elem[1]^.Simbolo = Traiz then
       begin
            evaluador_Num_pot(Arbol^.hijos.elem[3],Estado,Exponente,Base);
            If (Exponente=0) and (Base = 0) then
            begin
                 writeln('USTED INTENTA ELEVAR 0 A 0. EL EVALUADOR FALLA');
                 readkey;
            end
            else
            begin
                 If (Exponente<>0) and (Base = 0) then
                 begin
                      Resultado := 0;
                 end
                 else                                         //Cálculo de Raíz Enésima
                 begin                                        //Según https://www.youtube.com/watch?v=VaopqVaLHTQ
                      If Exponente <>0 then
                      begin
                           Resultado := exp((1/Exponente)*ln(Base));
                      end
                      else
                      begin
                           writeln('USTED INTENTA CALCULAR LA RAIZ CON EXPONENTE 0. EL EVALUADOR FALLA');
                           readkey;
                      end;
                 end;
            end;
       end;
end;

//<Num_pot> ::= <opArit> “,” <opArit>
Procedure evaluador_Num_pot(VAR Arbol:TApuntNodo; VAR Estado:TEstado;VAR Exponente:real;VAR Base: real);
begin
   evaluador_opArit(arbol^.hijos.elem[1],Estado,Base);
   evaluador_opArit(arbol^.hijos.elem[3],Estado,Exponente);
end;

//<Condicion> ::= “Si” <Valor2> “{” <Cuerpo> “}” <Otro>
Procedure evaluador_Condicion(VAR Arbol:TApuntNodo; VAR Estado:TEstado);
VAR
   Verdad: boolean;
begin
   evaluador_Valor2(Arbol^.hijos.elem[2],Estado,Verdad);
   If Verdad = true then
   begin
        evaluador_Cuerpo(Arbol^.hijos.elem[4],Estado);
   end
   else
       evaluador_Otro(Arbol^.hijos.elem[6],Estado);
end;

//<Valor2> ::= <opLogico2> <simOpLogico>
Procedure evaluador_Valor2(VAR Arbol:TApuntNodo; VAR Estado:TEstado;VAR Verdad:boolean);
VAR
   Verdad2: boolean;
begin
   evaluador_opLogico2(Arbol^.hijos.elem[1],Estado,Verdad2);
   evaluador_simOpLogico(Arbol^.hijos.elem[2],Estado,Verdad2,Verdad);
end;

//<simOpLogico> ::= “:” <opLogico2><simOpLogico> | ε
Procedure evaluador_simOpLogico(VAR Arbol:TApuntNodo; VAR Estado:TEstado;VAR Verdad:boolean;VAR Verdad2:boolean);
VAR
   Verdad3: boolean;
begin
   If arbol^.hijos.cant > 0 then //Arbol^.hijos.elem[1]^.Simbolo = TdosPuntos then
   begin
        evaluador_opLogico2(Arbol^.hijos.elem[2],Estado,Verdad3);
        Verdad2 := Verdad2 or Verdad3;
        evaluador_simOpLogico(Arbol^.hijos.elem[3],Estado,Verdad,Verdad2);
   end
   else
   begin
        Verdad2 := Verdad;
   end;
end;

//<opLogico2> ::= <opLogico3> <simOpLogico2>
Procedure evaluador_opLogico2(VAR Arbol:TApuntNodo; VAR Estado:TEstado;VAR Verdad3:boolean);
VAR
   Verdad4: boolean;
begin
   evaluador_opLogico3(Arbol^.hijos.elem[1],Estado,Verdad4);
   evaluador_simOpLogico2(Arbol^.hijos.elem[2],Estado,Verdad4,Verdad3);
end;

//<simOpLogico2> ::= “@” <opLogico3> <simOpLogico2> | ε
Procedure evaluador_simOpLogico2(VAR Arbol:TApuntNodo; VAR Estado:TEstado;VAR Verdad3:boolean; VAR Verdad4:boolean);
VAR
   Verdad5: boolean;
begin
   If arbol^.hijos.cant > 0 then //Arbol^.hijos.elem[1]^.Simbolo = Tarroba then
   begin
        evaluador_opLogico3(Arbol^.hijos.elem[2],Estado,Verdad5);
        Verdad3 := Verdad3 and Verdad5;
        evaluador_simOpLogico2(Arbol^.hijos.elem[3],Estado,Verdad3,Verdad4);
   end
   else
   begin
        Verdad4 := Verdad3;
   end;
end;

//<opLogico3> ::= <opArit> “unRelacional”  <opArit> | “{“ <valor2> “}” | “~” <opLogico3>
Procedure evaluador_opLogico3(VAR Arbol:TApuntNodo; VAR Estado:TEstado;VAR Verdad5:boolean);
VAR
   Resultado1: real;
   Resultado2: real;
begin
   If Arbol^.hijos.elem[1]^.Simbolo = VopArit then
   begin
        evaluador_opArit(Arbol^.hijos.elem[1],Estado,Resultado1);
        evaluador_opArit(Arbol^.hijos.elem[3],Estado,Resultado2);
        Case Arbol^.hijos.elem[2]^.Lexema of
        '==':Verdad5 := Resultado1 = Resultado2;
        '<>':Verdad5 := Resultado1 <> Resultado2;
        '>':Verdad5 := Resultado1 > Resultado2;
        '>=':Verdad5 := Resultado1 >= Resultado2;
        '<':Verdad5 := Resultado1 < Resultado2;
        '<=':Verdad5 := Resultado1 <= Resultado2;
        end;
   end
   else
   begin
        If Arbol^.hijos.elem[1]^.Simbolo = TllaveA then
        begin
             evaluador_Valor2(Arbol^.hijos.elem[2],Estado,Verdad5);
        end
        else
            If Arbol^.hijos.elem[1]^.Simbolo = Tvirgulilla then
            begin
                 evaluador_opLogico3(Arbol^.hijos.elem[2],Estado,Verdad5);
                 Verdad5 := (not Verdad5);
            end;
   end;
end;

//<Otro> ::= “sino” “{” <Cuerpo> “}”  | ε

Procedure evaluador_Otro(VAR Arbol:TApuntNodo; VAR Estado:TEstado);
begin
   If arbol^.hijos.cant > 0 then //Arbol^.hijos.elem[1]^.Simbolo = Tsino then
   begin
        evaluador_Cuerpo(Arbol^.hijos.elem[3],Estado);
   end;
end;

//<Ciclo> ::= “mientras” <Valor2> “{” <Cuerpo> “}”
Procedure evaluador_Ciclo(VAR Arbol:TApuntNodo; VAR Estado:TEstado);
VAR
   Verdad:boolean;
begin
   evaluador_Valor2(Arbol^.hijos.elem[2],Estado,Verdad);
   while Verdad do
   begin
        evaluador_Cuerpo(Arbol^.hijos.elem[4],Estado);
        evaluador_Valor2(Arbol^.hijos.elem[2],Estado,Verdad);
   end;
end;

//<Leer> ::= “leer” “(“ “cadena” “,” “id” “)”
Procedure evaluador_Leer(VAR Arbol:TApuntNodo; VAR Estado:TEstado);
VAR
   aux:real;
begin
   writeln(Arbol^.hijos.elem[3]^.Lexema);
   readln(aux);
   cambiar_valor(Estado,Arbol^.hijos.elem[5]^.Lexema,aux,0);
end;

//<Mostrar> ::= “imprime””(” <Muestra> “)”
Procedure evaluador_Mostrar (VAR Arbol:TApuntNodo; VAR Estado:TEstado);
begin
  evaluador_Muestra(Arbol^.hijos.elem[3],Estado);
end;

//<Muestra> ::= <opArit> <simMustra> | “cadena” <simMuestra>
Procedure evaluador_Muestra(VAR Arbol:TApuntNodo; VAR Estado:TEstado);
VAR
   aux:real;
begin
  If Arbol^.hijos.elem[1]^.Simbolo = VopArit then
  begin
       evaluador_opArit(Arbol^.hijos.elem[1],Estado,aux);
       writeln(aux:15:3);
       evaluador_simMuestra(Arbol^.hijos.elem[2],Estado);
  end
  else
      If Arbol^.hijos.elem[1]^.Simbolo = Tcadena then
      begin
           writeln(Arbol^.hijos.elem[1]^.Lexema);
           evaluador_simMuestra(Arbol^.hijos.elem[2],Estado);
      end;
end;

//<simMuestra> ::= ”,”<simMuestra2> | ε
Procedure evaluador_simMuestra (VAR Arbol:TApuntNodo; VAR Estado:TEstado);
begin
  If arbol^.hijos.cant > 0 then   //If Arbol^.hijos.elem[1]^.Simbolo = Tcoma then
     evaluador_simMuestra2(Arbol^.hijos.elem[2],Estado);
end;

//<simMuestra2> ::= <opArit> <simMuestra> | “cadena” <simMuestra>
Procedure evaluador_simMuestra2 (VAR Arbol:TApuntNodo; VAR Estado:TEstado);
VAR
   aux:real;
begin
     If Arbol^.hijos.elem[1]^.Simbolo = VopArit then
     begin
          evaluador_opArit(Arbol^.hijos.elem[1],Estado,aux);
          writeln(aux:15:3);
          evaluador_simMuestra(Arbol^.hijos.elem[2],Estado);
     end
     else
         If Arbol^.hijos.elem[1]^.Simbolo = Tcadena then
         begin
              writeln(Arbol^.hijos.elem[1]^.Lexema);
              evaluador_simMuestra(Arbol^.hijos.elem[2],Estado);
         end;
end;

//<Asignacion> ::= “id”<Asignacion2>
Procedure evaluador_Asignacion(VAR Arbol:TApuntNodo; VAR Estado:TEstado);
begin
     evaluador_Asignacion2(Arbol^.hijos.elem[2],Estado,Arbol^.hijos.elem[1]^.Lexema);
end;

//<Asignacion2> ::= "[ "<Vector> "]" “=” <Asignacion3> | “=” <Asignacion3>
Procedure evaluador_Asignacion2(VAR Arbol:TApuntNodo; VAR Estado:TEstado; id:string);
VAR
   aux_vector:real;
   aux_valor:real;
   aux: word;
begin
    case arbol^.hijos.elem[1]^.simbolo Of
        TcorA :
        begin
          evaluador_opArit(arbol^.hijos.elem[2], Estado, aux_vector);
          evaluador_Asignacion3(arbol^.hijos.elem[5], estado, aux_valor);
          aux := floor(aux_vector);
          cambiar_valor(Estado,id,aux_valor,aux);
        end;
        Tasignacion :
        begin
          evaluador_asignacion3(arbol^.hijos.elem[2],Estado,aux_valor);
          cambiar_valor(Estado,id,aux_valor,0);
        end;
    end;
end;

//<Asignacion3> ::= <opArit> | “[“ <contVector> “]”
Procedure evaluador_Asignacion3(VAR Arbol:TApuntNodo; VAR Estado:TEstado; VAR Valor:real);
begin
  If Arbol^.hijos.elem[1]^.Simbolo = VopArit then
  begin
       evaluador_opArit(Arbol^.hijos.elem[1],Estado,Valor);
  end
  else
      If Arbol^.hijos.elem[1]^.Simbolo = TcorA then
         evaluador_contVector(Arbol^.hijos.elem[2],Estado);
end;

//<contVector> ::= <opArit> <contVector2
Procedure evaluador_contVector (VAR Arbol:TApuntNodo; VAR Estado:TEstado);
VAR
   valor_aux:real;
begin
   evaluador_opArit(Arbol^.hijos.elem[1],Estado,valor_aux);
   evaluador_contVector2(Arbol^.hijos.elem[2],Estado);
end;

//<contVector2> ::=  “,” <contVector> | ε
Procedure evaluador_contVector2 (VAR Arbol:TApuntNodo; VAR Estado:TEstado);
begin
  If Arbol^.hijos.elem[1]^.Simbolo = Tcoma then
     evaluador_contVector(Arbol^.hijos.elem[2],Estado);
end;

end.
