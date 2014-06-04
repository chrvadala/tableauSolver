/**
 * Author:    Christian Vadalà
 * Created:   03.06.2014
 * Version:   1.0.0 beta
 * 
 **/




/*

  ESEMPIO DI UTILIZZO
  
?- solveTableau([(p & -q) v diamond (q)] ).
?- solveTableau([box diamond p, diamond -p  ] ).

  La prima parte del risultato ha il seguente formato
  idNodo : Formule {FormuleMarcate}* e rappresenta tutti i nodi del tableau

  La seconda parte del risultato rappresenta gli archi ed ha il seguente formato
  idNodoUscente -> idNodoEntrante

    

  RISPOSTA
  9:[p,-q] {[p& -q,p& -q v diamond q]}* 
  2:[p& -q] {[p& -q v diamond q]}* 
  4:[q] {[diamond q,p& -q v diamond q]}* 
  7:[q] {[diamond q]}* 
  8:[next diamond q] {[diamond q]}* 
  6:[diamond q] {[]}* 
  5:[next diamond q] {[diamond q,p& -q v diamond q]}* 
  3:[diamond q] {[p& -q v diamond q]}* 
  1:[p& -q v diamond q] {[]}* 
  2 -> 9
  8 -> 6
  6 -> 8
  6 -> 7
  5 -> 6
  3 -> 5
  3 -> 4
  1 -> 3
  1 -> 2
*/
 



/*
FUNTORI 
  node(ListaFormule, ListaFormuleMarcate) = rappresenta un nodo del tableau
  tableau(ListaNodi, ListaArchi, ProssimoId) = rappresenta un tableau

  ListaNodi è una lista costituita da terne (Id, Nodo, Done), dove Id rappresenta l'identificativo del nodo, Nodo contiente il funtore node e Done un booleano che indica se il nodo è stato espanso

  ListaArchi è una lista costituita dalla coppia (IdIn, IdOut) e rappresenta gli archi  
*/



:- op(400, xfy, [&]).
:- op(450, xfy, [v]).
:- op(300, fy, [box]).
:- op(300, fy, [diamond]).
:- op(300, fy, [next]).



/****************************************************/
/* solveTableau(+FormulasList)                      */
/****************************************************/
% risolve il tableau mostrando a schermo il risultato

solveTableau(ListOfFormulas):-
	completeTableau(tableau([(1, node(ListOfFormulas, []), false)], [], 2), TableauResult),
	printTableau(TableauResult).

/****************************************************/
/* printTableau(tableau(Nodes, Edges, NextId))      */
/****************************************************/
% stampa una rappresentazione prolog del tableau
   
printTableau(tableau(Nodes, Edges, _)):-
	printNodes(Nodes),
	printEdges(Edges),
	%printNextId(NextId),
	writeln('----------------------------------').

/****************************************************/
/* printNodes(L)                                    */
/****************************************************/
% stampa una lista di terne di nodi

printNodes([]).
printNodes([(Id, node(F, FM), _)|Rest]):-
	write(Id),
	write(':'),
	write(F),
	write(' {'),
	write(FM),
	writeln('}* '),
	%writeln(Done),
	printNodes(Rest).

/****************************************************/
/* printEdges(L)                                    */
/****************************************************/
% stampa una lista di archi

printEdges([]).
printEdges([(In, Out)|Rest]):-
	write(In),
	write(' -> '),
	writeln(Out),
	printEdges(Rest).

/*****************************************************/
/* addNode(Tableau, NewNode, ParentId, TableauResult)*/
/*****************************************************/
% aggiunge un nodo al tableau, se esiste crea solo l'arco se non esiste crea anche il nodo

% caso già esiste
addNode(tableau(Nodes, Edges, NextId), NewNode, ParentId, TableauResult):-
	member((Id, Node, _), Nodes),
	equalNode(Node, NewNode), !,	
	NewEdges = [(ParentId, Id) | Edges],
	TableauResult = tableau(Nodes, NewEdges, NextId).

% caso non esiste
addNode(tableau(Nodes, Edges, NextId), NewNode, ParentId, TableauResult):-
	NewNodes = [(NextId, NewNode, false) | Nodes],
	NewEdges = [(ParentId, NextId) | Edges],
	NewNextId is NextId + 1,
	TableauResult = tableau(NewNodes, NewEdges, NewNextId).

/*****************************************************/
/* completeTableau(Tableau, TableauCompleted)        */
/*****************************************************/
% partendo da un tableau non completo esegue interazioni per step successivi, fino a generare e stampare a schermo un tableau completo
completeTableau(tableau(Nodes, Edges, NextId), TableauCompleted):-
	member((Id, Node, false), Nodes), !, 
	delete(Nodes, (Id, Node, _), NewNodes),
	TableauWithNodeDone = tableau([(Id, Node, true)|NewNodes], Edges, NextId),
	solveNode(Id, Node, TableauWithNodeDone, TableauResult),
	%printTableau(TableauResult),
	completeTableau(TableauResult, TableauCompleted).

completeTableau(Tableau, Tableau):-
	Tableau = tableau(Nodes, _, _),
	\+ member((_, _, false), Nodes).


/*****************************************************/
/* nextStatus(List, List)                            */
/*****************************************************/
% partendo da una lista di formule con soli next A o singoli letterali calcola lo stato successivo

nextStatus([], []).
nextStatus([next A|Rest], [A | Result]):- !,
	nextStatus(Rest, Result).
nextStatus([_|Rest], Result) :-
	nextStatus(Rest, Result).
	
/*****************************************************/
/* equalNode(Node1, Node2)                           */
/*****************************************************/
% verifica se due nodi sono uguali (contengono le stesse formule)

equalNode(node(F1, FM1), node(F2, FM2)):-
	equalList(F1, F2),
	equalList(FM1, FM2).

/*****************************************************/
/* equalList(L1, L2)                                 */
/*****************************************************/
% verifica se due liste hanno gli stessi elementi (NOTA: prolog considera uguali due liste che hanno gli stessi elementi nello stesso ordine)

equalList(L1, L2):-
	listOneEqualToSecond(L1, L2),
	listOneEqualToSecond(L2, L1).

/*****************************************************/
/* listOneEqualToSecond(L1, L2)                      */
/*****************************************************/
% verifica se tutti gli elementi della prima lista si trovano nella seconda

listOneEqualToSecond([], []).
listOneEqualToSecond([X|Rest1], L2) :-
	delete(L2, X, NewL2),
	listOneEqualToSecond(Rest1, NewL2).
	
	
	


/*****************************************************/
/* solveNode(Id, Node, Tableau, TableauResult)       */
/*****************************************************/
% prende il nodo passatogli e lo analizza aggiungendo eventuali nuovi nodi al tableau

% LETTERALE NEGATO
solveNode(_, node(F, _), Tableau, Tableau):-
	member( A, F),
	member(-A, F).

% AND
solveNode(Id, node(F, FM), Tableau, TableauResult):-
	member(Formula, F),
	Formula = A & B, !, 
	delete(F, Formula, NewF),	
	addNode(Tableau, node([A,B|NewF],[Formula|FM]), Id, TableauResult).

% OR
solveNode(Id, node(F, FM), Tableau, TableauResult):-
	member(Formula, F),
	Formula = A v B, !, 
	delete(F, Formula, NewF),	
	addNode(Tableau, node([A|NewF],[Formula|FM]), Id, TableauPartialResult),
	addNode(TableauPartialResult, node([B|NewF],[Formula|FM]), Id, TableauResult).

% BOX
solveNode(Id, node(F, FM), Tableau, TableauResult):-
	member(Formula, F),
	Formula = box A, !, 
	delete(F, Formula, NewF),	
	addNode(Tableau, node([A, next box A|NewF],[Formula|FM]), Id, TableauResult).

% DIAMOND
solveNode(Id, node(F, FM), Tableau, TableauResult):-
	member(Formula, F),
	Formula = diamond A, !, 
	delete(F, Formula, NewF),	
	addNode(Tableau, node([A|NewF],[Formula|FM]), Id, TableauPartialResult),
	addNode(TableauPartialResult, node([next diamond A|NewF],[Formula|FM]), Id, TableauResult).


% NEXT
solveNode(Id, node(F, _), Tableau, TableauResult):-
    \+ member(_ & _, F),
    \+ member(_ v _, F),
    \+ member(box _, F),
    \+ member(diamond _, F),
    member(next _, F),
    nextStatus(F, NewF),
    addNode(Tableau, node(NewF, []), Id, TableauResult).


% SOLO LETTERALI
solveNode(_, node(F, _), Tableau, Tableau):-
	\+ member(_ & _, F),
	\+ member(_ v _, F),
	\+ member(box _, F),
	\+ member(diamond _, F),
	\+ member(next _, F).



