{                                COUNTERS

Auteur : Bacterius.

Utilisez les fonctions suivantes pour ins�rer un ou plusieurs compteurs dans votre application.

Ce qu'il faut bien comprendre dans ce compteur, c'est qu'il poss�de deux �tats implicites :
  - l'�tat "comptant", o� il contient les valeurs de d�part de l'horloge, qui sont inutilisables.
  - l'�tat "compt�", o� il contient les valeurs exactes de temps entre le d�part et la fin.

Les diff�rentes fonctions font basculer un compteur dans un de ces �tats, voici ces �tats :
InitializeCounter : Passe en comptant.
ResetCounter      : Passe en comptant.
ChangePrecision   : Passe en comptant.
QueryCounter      : Passe en compt�.
ReleaseCounter    : N/A.

Ainsi, vous ne pourrez utiliser les valeurs du compteur que apr�s un appel � QueryCounter.
Attention : QueryCounter ne modifie PAS la valeur du compteur, il renvoie la diff�rence de temps
entre l'appel � ResetCounter et entre l'appel � QueryCounter.

L'ordre normal des appels aux fonctions serait alors :

1. InitializeCounter
2. QueryCounter      | Effectuer le 2. et le 3. autant de fois que n�cessaire.
3. ResetCounter      | Eventuellement glisser un SwitchMode � la place du 3.
4. ReleaseCounter


Remarques :

� Le compteur calcule ses temps sur les temps de l'horloge haute pr�cision, les temps
sont donc en virgule flottante (comme 454.56 ms, 72837.12 �s ...). En revanche, si vous
ne poss�dez pas d'horloge haute pr�cision, toutes les pr�cisions au-dessus de 1000 donneront 0
et pour la pr�cision 1000 et inf�rieur (milliseconde et inf�rieur), QueryCounter
renverra un nombre entier. Pour savoir si vous poss�dez cette horloge, v�rifiez que
QueryPerformanceCounter renvoie True (ou bien v�rifiez que HighResFound de cette
unit� est bien � True, puisqu'elle se base sur le r�sultat de QueryPerformanceCounter).

� Vous pouvez utiliser un type PCounter ou bien un type Pointer pour utiliser le compteur.
Il est plus s�r d'utiliser un type Pointer car cela emp�chera des modifications non d�sir�es
de la valeur ou de la pr�cision du compteur, et vous devrez utiliser GetCounterPrecision pour
r�cup�rer la pr�cision du compteur. Si vous utilisez PCounter, vous pouvez directement acc�der
aux champs du compteur, mais ne les modifiez pas directement, utilisez les fonctions pr�vues �
cet effet.

� Vous pouvez maintenant utiliser la classe TCounter si vous pr�f�rez manipuler des objets.

}

unit Counters;

interface

uses Windows, SysUtils;

const                           { Des constantes pour savoir ce que le compteur g�re }
  SECONDS      = 1;             { Le compteur g�re les secondes      }
  MILLISECONDS = 1000;          { Le compteur g�re les millisecondes }
  MICROSECONDS = 1000000;       { Le compteur g�re les microsecondes }
  NANOSECONDS  = 1000000000;    { Le compteur g�re les nanosecondes  }

type
  _COUNTER = record { Un compteur - le type objet ne sera pas utilis� }
   Precision: Longword;  { La pr�cision du compteur (1 : secondes, 1000 : ms, 1000000 : �s }
   Value: Extended;      { La valeur actuelle du compteur en millisecondes ou en microsecondes }
  end;

  PCounter = ^_COUNTER;  { Un pointeur sur un compteur : sera utilis� dans les fonctions }

{ InitializeCounter va cr�er un compteur, et appeller ensuite ChangePrecision (qui appelle ResetCounter) }
function InitializeCounter(Precision: Longword): PCounter;
{ ResetCounter va red�finir les valeurs du compteur � l'horloge actuelle }
function ResetCounter(Counter: PCounter): Boolean;
{ ChangePrecision permet de changer le mode d'un compteur, puis appeller ResetCounter }
function ChangePrecision(Counter: PCounter; NewPrec: Longword): Boolean;
{ QueryCounter va mettre � jour les valeurs du compteur }
function QueryCounter(Counter: PCounter): Extended;
{ Renvoie la pr�cision du compteur - utile si l'on utilise un type Pointer pour le compteur }
function GetCounterPrecision(Counter: PCounter): Longword;
{ ReleaseCounter va lib�rer un compteur cr�� avec InitializeCounter }
function ReleaseCounter(Counter: PCounter): Boolean;

type
 TCounter = class                                            { Classe TCounter }
 private
  FCounter: PCounter;                                        { Champ objet pour le compteur }
  function GetValue: Extended;                               { R�cup�ration de la valeur du compteur }
  function GetPrecision: Longword;                           { R�cup�ration de la prec. du compteur }
  procedure SetPrecision(Value: Longword);                   { D�finition de la prec. du compteur }
 public
  constructor Create(Precision: Longword); reintroduce;      { Cr�ation de TCounter }
  destructor Destroy; override;                              { Destruction de TCounter }
  procedure Reset;                                           { Remise � 0 du compteur }
  property Value: Extended    read GetValue;                 { Propri�t� Value        }
  property Precision: Longword read GetPrecision write SetPrecision; { Propri�t� Precision }
 end;

Var
 HighResFound: Boolean;
 Tmp: PInt64;

implementation

function GetTckCount(Precision: Longword): Extended; { R�cup�re le temps de l'horloge }
Var
 Freq, Bgn: Int64;                 
begin
 if not HighResFound then
  begin
   { En dessous de millisecondes non disponible }
   Result := 0;
   if Precision <= 1000 then Result := GetTickCount div Abs(Precision - 999);
   Exit;                          { On s'en va }
  end;

 QueryPerformanceFrequency(Freq); { On r�cup�re la fr�quence de l'horloge }
 QueryPerformanceCounter(Bgn);    { On r�cup�re le temps actuel           }
 Result := Bgn * Precision / Freq;  { On le formate pour obtenir le temps en microsecondes }
end;

{ InitializeCounter cr�e un compteur, puis appelle ResetCounter avec le mode sp�cifi� }
function InitializeCounter(Precision: Longword): PCounter;
begin
 New(Result);                        { Cr�ation du pointeur vers le compteur }
 ChangePrecision(Result, Precision); { Appelle SwitchMode pour d�finir la pr�cision du compteur }
end;

{ ResetCounter va basculer le compteur en mode comptant }
function ResetCounter(Counter: PCounter): Boolean;
begin
 Result := Assigned(Counter);    { On v�rifie que le compteur soit bien initialis� }

 if Result then                  { Si il l'est ... }
  with Counter^ do
   Value := GetTckCount(Precision); { On remet la valeur de l'horloge }
end;

{ ChangePrecision va modifier le mode d'un compteur et appeller ResetCounter ensuite }
function ChangePrecision(Counter: PCounter; NewPrec: Longword): Boolean;
begin
 Result := False;

 if Assigned(Counter) then      { On v�rifie que le compteur soit initialis� }
  begin
   if NewPrec = Counter.Precision then Exit; { Si on ne change pas de pr�cision, on s'en va direct }
   Counter.Precision := NewPrec;            { On modifie le mode }
   Result := ResetCounter(Counter);          { Puis on appelle ResetCounter }
  end;
end;

{ QueryCounter va faire basculer le compteur en mode compt�. Vous pourrez alors utiliser ses
  valeurs selon l'unit� de temps choisie (ms ou �s ). }
function QueryCounter(Counter: PCounter): Extended;
begin
 Result := 0;                                      { Valeur � 0, en cas de probl�me }

 if Assigned(Counter) then                         { Si le compteur est bien initialis� ... }
  with Counter^ do
   Result := GetTckCount(Precision) - Value;       { On calcule le temps �coul� }                                           { ... depuis l'appel � ResetCounter }
end;

{ Renvoie la pr�cision du compteur - utile si l'on utilise un type Pointer pour le compteur }
function GetCounterPrecision(Counter: PCounter): Longword;
begin
 Result := High(Longword);                         { R�sultat non valable pour commencer }
 if Assigned(Counter) then Result := Counter.Precision; { On r�cup�re le mode du compteur }
end;

{ ReleaseCounter va lib�rer un compteur cr�� avec InitializeCounter}
function ReleaseCounter(Counter: PCounter): Boolean;
begin
 Result := Assigned(Counter);          { On v�rifie que le compteur soit bien initialis� }
 if Result then Dispose(Counter);      { Le cas �ch�ant, on le lib�re }
end;







{-------------------------------- TCOUNTER ------------------------------------}

constructor TCounter.Create(Precision: Longword); { Cr�ation du TCounter }
begin
 inherited Create;                                { On cr�e l'objet }
 FCounter := InitializeCounter(Precision);        { On initialise le compteur }
end;

destructor TCounter.Destroy;                      { Destruction du TCounter }
begin
 ReleaseCounter(FCounter);                        { On lib�re le compteur }
 inherited Destroy;                               { On d�truit l'objet }
end;

procedure TCounter.Reset;                         { Remise � 0 du compteur }
begin
 ResetCounter(FCounter);                          { On remet � 0           }
end;

function TCounter.GetValue: Extended;             { R�cup�ration de la valeur du compteur }
begin
 Result := QueryCounter(FCounter);                { On r�cup�re avec QueryCounter }
end;

function TCounter.GetPrecision: Longword;         { R�cup�ration du mode du compteur }
begin
 Result := GetCounterPrecision(FCounter);         { On r�cup�re avec GetCounterPrecision }
end;

procedure TCounter.SetPrecision(Value: Longword); { D�finition du mode du compteur }
begin
 ChangePrecision(FCounter, Value);
 { On change avec ChangePrecision. Pas besoin de v�rifier si l'on met une precision diff�rente, la
 fonction s'en occupe ! }
end;





initialization
  New(Tmp);
  HighResFound := QueryPerformanceCounter(Tmp^);
  Dispose(Tmp);
  { Si QueryPerformanceCounter renvoie True, vous pourrez utiliser toutes les fonctions du compteur.
    Sinon, vous ne pourrez pas utiliser les tr�s petites pr�cisions et vous aurez une pr�cision
    moindre sur les millisecondes.
    Mais rassurez-vous, de nos jours tous les PC ont des horloges haute pr�cision ! :p       }

end.
