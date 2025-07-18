unit interfaz;

interface
{$codepage UTF8}
uses crt, analizador_lexico, analizador_sintactico,evaluador,tipos;

const
    rutaFuente = 'C:\Users\Usuario\Desktop\UNIVERSIDAD\Segundo Nivel\PRIMER CUATRIMESTRE\SINTAXIS Y SEMANTICA DE LOS LENGUAJES\TP FINAL\Fuente.txt';

Procedure menu;

implementation
Procedure menu;

  var
  tic,test_evaluador: byte;
  X: byte;
  Y: byte;
  largo: byte;
  ancho: byte;
  textOffsetX: byte;
  textOffsetY: byte;
  //tecla:char;
  tecla: string;

  arbol: TApuntNodo;
  error: boolean;
{ TS: TablaDeSimbolos;
  Fuente: FileOfChar;
  Control:longint;
  CompLex: TipoSG;
  Lexema: string;
  I:integer;  }
  Estado: TEstado;
  I: word;
begin
  clrscr;
  tic := 2;
  X := 15;
  Y := 3;
  ancho := 70;
  largo := 24;
  textColor(green);

  gotoXY(X, Y);
  for i := 0 to ancho do
    write('─');
  for i := 1 to largo do
  begin
    gotoxy(X, Y + i);
    write('│');
    gotoxy(X + ancho, Y + i);
    write('│');
    delay(tic);
  end;

  gotoxy(X, Y + largo);
  for i := 0 to ancho do
    write('─');


  textOffsetX := X + (ancho div 2) - 28;
  textOffsetY := Y + (largo div 2) -10;

  textColor(white);
  gotoxy(textOffsetX, textOffsetY);
  write('______                   _       _ _    ');TextColor(Red); write('    _______ ');TextColor(White); delay(100);
  gotoxy(textOffsetX, textOffsetY + 1);
  write('| ___ \                 | |     ( ) |   ');TextColor(Red); write('   /    __ \ ');TextColor(White);  delay(100);
  gotoxy(textOffsetX, textOffsetY + 2);
  write('| |_/ /_ _ ___  ___ __ _| |_ __ |/| |_  ');TextColor(Red); write('  / /\ \  \ \');TextColor(White);    delay(100);
  gotoxy(textOffsetX, textOffsetY + 3);
  write('|  __/ _` / __|/ __/ _` | | ''_ \  | __| ');TextColor(Red); write('  | | \ \ | |');TextColor(White);    delay(100);
  gotoxy(textOffsetX, textOffsetY + 4);
  write('| | | (_| \__ \ (_| (_| | | | | | | |_  ');TextColor(Red); write('  \ \__\ \/ /');TextColor(White);      delay(100);
  gotoxy(textOffsetX, textOffsetY + 5);
  write('\_|  \__,_|___/\___\__,_|_|_| |_|  \__| ');TextColor(Red); write('   \_______/ ');TextColor(White);      delay(100);

  gotoxy(textOffsetX, textOffsetY + 10);
  Write('1   .   Evaluar Lenguaje');
  gotoxy(textOffsetX, textOffsetY + 11);
  Write('Otro. Salir');
  //tecla:=readkey;

  gotoxy(textOffsetX,textOffsetY + 12);
  readln(tecla);
  If tecla = '1' then
  begin
    clrscr;
    Analizador_Predictivo(rutaFuente,arbol,Error);
    writeln(Error);
    if Error=false then
      writeln('Felicitaciones, Analizador Sintáctico es valido');
      writeln('Presione una tecla para continuar');
    readkey;
    If not Error then
    begin
    InicializarEst(Estado);
    clrscr;
   { For I:=1 to arbol^.hijos.cant do
    begin
         writeln(arbol^.hijos.elem[I]^.Simbolo);
    end;
     readkey;  }
    evaluador_Lenguaje(arbol,Estado);
    readkey;
    clrscr;
    end
    else
      menu;
   end;
end;
end.

end.
