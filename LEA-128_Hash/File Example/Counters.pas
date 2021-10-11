{                                COUNTERS

Auteur : Bacterius.

Utilisez les fonctions suivantes pour insérer un ou plusieurs compteurs dans votre application.

Ce qu'il faut bien comprendre dans ce compteur, c'est qu'il possède deux états implicites :
  - l'état "comptant", où il contient les valeurs de départ de l'horloge, qui sont inutilisables.
  - l'état "compté", où il contient les valeurs exactes de temps entre le départ et la fin.

Les différentes fonctions font basculer un compteur dans un de ces états, voici ces états :
InitializeCounter : Passe en comptant.
ResetCounter      : Passe en comptant.
ChangePrecision   : Passe en comptant.
QueryCounter      : Passe en compté.
ReleaseCounter    : N/A.

Ainsi, vous ne pourrez utiliser les valeurs du compteur que après un appel à QueryCounter.
Attention : QueryCounter ne modifie PAS la valeur du compteur, il renvoie la différence de temps
entre l'appel à ResetCounter et entre l'appel à QueryCounter.

L'ordre normal des appels aux fonctions serait alors :

1. InitializeCounter
2. QueryCounter      | Effectuer le 2. et le 3. autant de fois que nécessaire.
3. ResetCounter      | Eventuellement glisser un SwitchMode à la place du 3.
4. ReleaseCounter


Remarques :

¤ Le compteur calcule ses temps sur les temps de l'horloge haute précision, les temps
sont donc en virgule flottante (comme 454.56 ms, 72837.12 µs ...). En revanche, si vous
ne possédez pas d'horloge haute précision, toutes les précisions au-dessus de 1000 donneront 0
et pour la précision 1000 et inférieur (milliseconde et inférieur), QueryCounter
renverra un nombre entier. Pour savoir si vous possédez cette horloge, vérifiez que
QueryPerformanceCounter renvoie True (ou bien vérifiez que HighResFound de cette
unité est bien à True, puisqu'elle se base sur le résultat de QueryPerformanceCounter).

¤ Vous pouvez utiliser un type PCounter ou bien un type Pointer pour utiliser le compteur.
Il est plus sûr d'utiliser un type Pointer car cela empêchera des modifications non désirées
de la valeur ou de la précision du compteur, et vous devrez utiliser GetCounterPrecision pour
récupérer la précision du compteur. Si vous utilisez PCounter, vous pouvez directement accéder
aux champs du compteur, mais ne les modifiez pas directement, utilisez les fonctions prévues à
cet effet.

¤ Vous pouvez maintenant utiliser la classe TCounter si vous préférez manipuler des objets.

}

unit Counters;

interface

uses Windows, SysUtils;

const                           { Des constantes pour savoir ce que le compteur gère }
  SECONDS      = 1;             { Le compteur gère les secondes      }
  MILLISECONDS = 1000;          { Le compteur gère les millisecondes }
  MICROSECONDS = 1000000;       { Le compteur gère les microsecondes }
  NANOSECONDS  = 1000000000;    { Le compteur gère les nanosecondes  }

type
  _COUNTER = record { Un compteur - le type objet ne sera pas utilisé }
   Precision: Longword;  { La précision du compteur (1 : secondes, 1000 : ms, 1000000 : µs }
   Value: Extended;      { La valeur actuelle du compteur en millisecondes ou en microsecondes }
  end;

  PCounter = ^_COUNTER;  { Un pointeur sur un compteur : sera utilisé dans les fonctions }

{ InitializeCounter va créer un compteur, et appeller ensuite ChangePrecision (qui appelle ResetCounter) }
function InitializeCounter(Precision: Longword): PCounter;
{ ResetCounter va redéfinir les valeurs du compteur à l'horloge actuelle }
function ResetCounter(Counter: PCounter): Boolean;
{ ChangePrecision permet de changer le mode d'un compteur, puis appeller ResetCounter }
function ChangePrecision(Counter: PCounter; NewPrec: Longword): Boolean;
{ QueryCounter va mettre à jour les valeurs du compteur }
function QueryCounter(Counter: PCounter): Extended;
{ Renvoie la précision du compteur - utile si l'on utilise un type Pointer pour le compteur }
function GetCounterPrecision(Counter: PCounter): Longword;
{ ReleaseCounter va libérer un compteur créé avec InitializeCounter }
function ReleaseCounter(Counter: PCounter): Boolean;

type
 TCounter = class                                            { Classe TCounter }
 private
  FCounter: PCounter;                                        { Champ objet pour le compteur }
  function GetValue: Extended;                               { Récupération de la valeur du compteur }
  function GetPrecision: Longword;                           { Récupération de la prec. du compteur }
  procedure SetPrecision(Value: Longword);                   { Définition de la prec. du compteur }
 public
  constructor Create(Precision: Longword); reintroduce;      { Création de TCounter }
  destructor Destroy; override;                              { Destruction de TCounter }
  procedure Reset;                                           { Remise à 0 du compteur }
  property Value: Extended    read GetValue;                 { Propriété Value        }
  property Precision: Longword read GetPrecision write SetPrecision; { Propriété Precision }
 end;

Var
 HighResFound: Boolean;
 Tmp: PInt64;

implementation

function GetTckCount(Precision: Longword): Extended; { Récupère le temps de l'horloge }
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

 QueryPerformanceFrequency(Freq); { On récupère la fréquence de l'horloge }
 QueryPerformanceCounter(Bgn);    { On récupère le temps actuel           }
 Result := Bgn * Precision / Freq;  { On le formate pour obtenir le temps en microsecondes }
end;

{ InitializeCounter crée un compteur, puis appelle ResetCounter avec le mode spécifié }
function InitializeCounter(Precision: Longword): PCounter;
begin
 New(Result);                        { Création du pointeur vers le compteur }
 ChangePrecision(Result, Precision); { Appelle SwitchMode pour définir la précision du compteur }
end;

{ ResetCounter va basculer le compteur en mode comptant }
function ResetCounter(Counter: PCounter): Boolean;
begin
 Result := Assigned(Counter);    { On vérifie que le compteur soit bien initialisé }

 if Result then                  { Si il l'est ... }
  with Counter^ do
   Value := GetTckCount(Precision); { On remet la valeur de l'horloge }
end;

{ ChangePrecision va modifier le mode d'un compteur et appeller ResetCounter ensuite }
function ChangePrecision(Counter: PCounter; NewPrec: Longword): Boolean;
begin
 Result := False;

 if Assigned(Counter) then      { On vérifie que le compteur soit initialisé }
  begin
   if NewPrec = Counter.Precision then Exit; { Si on ne change pas de précision, on s'en va direct }
   Counter.Precision := NewPrec;            { On modifie le mode }
   Result := ResetCounter(Counter);          { Puis on appelle ResetCounter }
  end;
end;

{ QueryCounter va faire basculer le compteur en mode compté. Vous pourrez alors utiliser ses
  valeurs selon l'unité de temps choisie (ms ou µs ). }
function QueryCounter(Counter: PCounter): Extended;
begin
 Result := 0;                                      { Valeur à 0, en cas de problème }

 if Assigned(Counter) then                         { Si le compteur est bien initialisé ... }
  with Counter^ do
   Result := GetTckCount(Precision) - Value;       { On calcule le temps écoulé }                                           { ... depuis l'appel à ResetCounter }
end;

{ Renvoie la précision du compteur - utile si l'on utilise un type Pointer pour le compteur }
function GetCounterPrecision(Counter: PCounter): Longword;
begin
 Result := High(Longword);                         { Résultat non valable pour commencer }
 if Assigned(Counter) then Result := Counter.Precision; { On récupère le mode du compteur }
end;

{ ReleaseCounter va libérer un compteur créé avec InitializeCounter}
function ReleaseCounter(Counter: PCounter): Boolean;
begin
 Result := Assigned(Counter);          { On vérifie que le compteur soit bien initialisé }
 if Result then Dispose(Counter);      { Le cas échéant, on le libère }
end;







{-------------------------------- TCOUNTER ------------------------------------}

constructor TCounter.Create(Precision: Longword); { Création du TCounter }
begin
 inherited Create;                                { On crée l'objet }
 FCounter := InitializeCounter(Precision);        { On initialise le compteur }
end;

destructor TCounter.Destroy;                      { Destruction du TCounter }
begin
 ReleaseCounter(FCounter);                        { On libère le compteur }
 inherited Destroy;                               { On détruit l'objet }
end;

procedure TCounter.Reset;                         { Remise à 0 du compteur }
begin
 ResetCounter(FCounter);                          { On remet à 0           }
end;

function TCounter.GetValue: Extended;             { Récupération de la valeur du compteur }
begin
 Result := QueryCounter(FCounter);                { On récupère avec QueryCounter }
end;

function TCounter.GetPrecision: Longword;         { Récupération du mode du compteur }
begin
 Result := GetCounterPrecision(FCounter);         { On récupère avec GetCounterPrecision }
end;

procedure TCounter.SetPrecision(Value: Longword); { Définition du mode du compteur }
begin
 ChangePrecision(FCounter, Value);
 { On change avec ChangePrecision. Pas besoin de vérifier si l'on met une precision différente, la
 fonction s'en occupe ! }
end;





initialization
  New(Tmp);
  HighResFound := QueryPerformanceCounter(Tmp^);
  Dispose(Tmp);
  { Si QueryPerformanceCounter renvoie True, vous pourrez utiliser toutes les fonctions du compteur.
    Sinon, vous ne pourrez pas utiliser les très petites précisions et vous aurez une précision
    moindre sur les millisecondes.
    Mais rassurez-vous, de nos jours tous les PC ont des horloges haute précision ! :p       }

end.
