/*****************************************************************
 * Author:        Christian Vadalà                               *
 * Organization:  Work out Web                                   *
 * Created:       03.06.2014                                     *
 * Home Page:     https://github.com/work-out-web/tableauSolver  *
 *****************************************************************/
% ESEMPI
% ?- solve([(p & -q) v diamond q] ).
% ?- solve([box diamond p, diamond -p  ] ).
%

% SIMBOLI SUPPORTATI
% AND => (A & B)
% OR  => (A v B)
% NOT => (-A)
% BOX => (box A) 
% DIAMOND => (diamond A)
% NEXT => (next A)

% ESEMPIO DI TABLEAU GENERATO (NOTA: VIENE ANCHE GENERATO UN RISULTATO GRAFICAMENTE RAPPRESENTABILE)
%  9:[p,-q] {[p& -q,p& -q v diamond q]}* 
%  2:[p& -q] {[p& -q v diamond q]}* 
%  4:[q] {[diamond q,p& -q v diamond q]}* 
%  7:[q] {[diamond q]}* 
%  8:[next diamond q] {[diamond q]}* 
%  6:[diamond q] {[]}* 
%  5:[next diamond q] {[diamond q,p& -q v diamond q]}* 
%  3:[diamond q] {[p& -q v diamond q]}* 
%  1:[p& -q v diamond q] {[]}* 
%  2 -> 9
%  8 -> 6
%  6 -> 8
%  6 -> 7
%  5 -> 6
%  3 -> 5
%  3 -> 4
%  1 -> 3
%  1 -> 2

% INTERPRETAZIONE RISULTATO
% Nella prima parte del risultato sono presenti tutti i vertici del tableau. Il formato utilizzato per visualizzare questi dati è il seguente idNodo : ListaFormule {ListaFormuleMarcate}*.

% Nella seconda parte sono invece presenti tutti gli archi. Il formato utilizzato è il seguente idNodoUscente -> idNodoEntrante

%  La terza parte è invece una rappresentazione del grafo in formato DOT, graficamente visualizzabile tramite diverse librerie.
%  Un possibile tool online per visualizzare il grafo è questo: http://graphviz-dev.appspot.com
 


/*
FUNTORI 
  node(ListaFormule, ListaFormuleMarcate) = rappresenta un nodo del tableau
  tableau(ListaNodi, ListaArchi, ProssimoId) = rappresenta un tableau

  ListaNodi è una lista costituita da terne (Id, Nodo, Done), dove Id rappresenta l'identificativo del nodo, Nodo contiente il funtore node e Done un booleano che indica se il nodo è stato espanso

  ListaArchi è una lista costituita dalla coppia (IdIn, IdOut) e rappresenta gli archi  
*/


/*********************************************/
/* dichiarazione priorità operatori          */
/*********************************************/

:- op(400, xfy, [&]).
:- op(450, xfy, [v]).
:- op(300, fy, [box]).
:- op(300, fy, [diamond]).
:- op(300, fy, [next]).

/*********************************************/
/* solve(+FormulasList)                      */
/*********************************************/
% alias di solveTableau

solve(ListOfFormulas) :-
	solveTableau(ListOfFormulas).

/****************************************************/
/* solveTableau(+FormulasList)                      */
/****************************************************/
% risolve il tableau mostrando a schermo il risultato

solveTableau(ListOfFormulas):-
	solveTableauWrapper(ListOfFormulas, TableauResult),
	printTableau(TableauResult),
	printTableauInDotFormat(TableauResult).

/****************************************************/
/* solveTableauWrapper(+FormulasList, TableauResult)*/
/****************************************************/
% inizializza la struttura dati e risolve il tableau
solveTableauWrapper(ListOfFormulas, TableauResult):-
	completeTableau(tableau([(1, node(ListOfFormulas, []), false)], [], 2), TableauResult).

/****************************************************/
/* printTableau(tableau(Nodes, Edges, NextId))      */
/****************************************************/
% stampa una rappresentazione prolog del tableau
   
printTableau(tableau(Nodes, Edges, _)):-
	printNodes(Nodes),
	printEdges(Edges).
	
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
/* isStatus(?Node)                                   */
/*****************************************************/
% verifica se il nodo passato è uno stato

isStatus(node(F, _)) :-
	\+ member(_ & _, F),
	\+ member(_ v _, F),
	\+ member(box _, F),
	\+ member(diamond _, F),
	\+ (member(A, F), member(-A, F)).
	
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
% verifica se due liste hanno gli stessi elementi
% NOTA: prolog considera uguali due liste solo se gli elementi si trovano nel medesimo ordine

equalList(L1, L2):-
	subset(L1, L2),
	subset(L2, L1).

/*****************************************************/
/* removeDuplicatesList(?List, ?ListResult)           */
/*****************************************************/
% rimuove duplicati da una lista 

removeDuplicatesList([], []).
removeDuplicatesList([X|Rest], Result) :-
	member(X, Rest), !,
	removeDuplicatesList(Rest, Result).

removeDuplicatesList([X|Rest], [X|SubResult]) :-
	removeDuplicatesList(Rest, SubResult).	


/*****************************************************/
/* solveNode(Id, Node, Tableau, TableauResult)       */
/*****************************************************/
% prende il nodo passatogli e lo analizza aggiungendo eventuali nuovi nodi al tableau

% LETTERALE NEGATO
solveNode(_, node(F, _), Tableau, Tableau):-
	member( A, F),
	member(-A, F), !.

% AND
solveNode(Id, node(F, FM), Tableau, TableauResult):-
	member(Formula, F),
	Formula = A & B, !, 
	delete(F, Formula, NewF),
	removeDuplicatesList([A,B|NewF], SolvedNewF),
	removeDuplicatesList([Formula|FM], NewFM),
	addNode(Tableau, node(SolvedNewF, NewFM), Id, TableauResult).

% OR
solveNode(Id, node(F, FM), Tableau, TableauResult):-
	member(Formula, F),
	Formula = A v B, !, 
	delete(F, Formula, NewF),
	removeDuplicatesList([A|NewF], SolvedNewFA),
	removeDuplicatesList([B|NewF], SolvedNewFB),
	removeDuplicatesList([Formula|FM], NewFM),
	addNode(Tableau, node(SolvedNewFA, NewFM), Id, TableauPartialResult),
	addNode(TableauPartialResult, node(SolvedNewFB, NewFM), Id, TableauResult).

% BOX
solveNode(Id, node(F, FM), Tableau, TableauResult):-
	member(Formula, F),
	Formula = box A, !, 
	delete(F, Formula, NewF),
	removeDuplicatesList([A, next box A|NewF], SolvedNewF),
	removeDuplicatesList([Formula|FM], NewFM),
	addNode(Tableau, node(SolvedNewF, NewFM), Id, TableauResult).

% DIAMOND
solveNode(Id, node(F, FM), Tableau, TableauResult):-
	member(Formula, F),
	Formula = diamond A, !, 
	delete(F, Formula, NewF),
	removeDuplicatesList([A|NewF], SolvedNewFA),
	removeDuplicatesList([next diamond A|NewF], SolvedNewFRest),
	removeDuplicatesList([Formula|FM], NewFM),
	addNode(Tableau, node(SolvedNewFA, NewFM), Id, TableauPartialResult),
	addNode(TableauPartialResult, node(SolvedNewFRest, NewFM), Id, TableauResult).


% NEXT
solveNode(Id, node(F, _), Tableau, TableauResult):-
    \+ member(_ & _, F),
    \+ member(_ v _, F),
    \+ member(box _, F),
    \+ member(diamond _, F),
    nextStatus(F, NewF),
    addNode(Tableau, node(NewF, []), Id, TableauResult).







/**********************************************************/
/* printTableauInDotFormat(tableau(Nodes, Edges, NextId)) */
/*********************************************************/
% stampa una rappresentazione del tableau in formato Dot
   
printTableauInDotFormat(tableau(Nodes, Edges, _)):-
	writeln('---------------------------------------------------------------'),
	writeln('- copia ed incolla su    http://graphviz-dev.appspot.com      -'),
	writeln('- il seguente codice per visualizzare un disegno del tableau  -'),
	writeln('---------------------------------------------------------------'),		
	writeln('digraph g{'),
	printNodesInDotFormat(Nodes),
	printEdges(Edges),
	writeln('}'),
	writeln('---------------------------------------------------------------').

/****************************************************/
/* printNodesInDotFormat(L)                         */
/****************************************************/
% stampa una lista di terne di nodi in formato Dot

printNodesInDotFormat([]).

% root
printNodesInDotFormat([(Id, node(F, FM), _)|Rest]):-
	Id = 1, !,
	write(Id),
	write(' [label="'),
	write(Id),
	write(': '),
	printFormulasInDotFormat(F),
	write(' \\n '),
	printMarkedFormulasInDotFormat(FM),
	writeln('" shape="box" fillcolor="cornflowerblue" style="filled,rounded"];'),
	printNodesInDotFormat(Rest).

%true
printNodesInDotFormat([(Id, node([], FM), _)|Rest]):- !,
	write(Id),
	write(' [label="'),
	write(Id),
	write(': true '),
	write(' \\n '),
	printMarkedFormulasInDotFormat(FM),
	writeln('" shape="box" fillcolor="orange" style="filled"];'),
	printNodesInDotFormat(Rest).

% status
printNodesInDotFormat([(Id, node(F, FM), _)|Rest]):-
	isStatus(node(F, FM)), !,
	write(Id),
	write(' [label="'),
	write(Id),
	write(': '),
	printFormulasInDotFormat(F),
	write(' \\n '),
	printMarkedFormulasInDotFormat(FM),
	writeln('" shape="box" fillcolor="orange" style="filled"];'),
	printNodesInDotFormat(Rest).

printNodesInDotFormat([(Id, node(F, FM), _)|Rest]):-
	write(Id),
	write(' [label="'),
	write(Id),
	write(': '),
	printFormulasInDotFormat(F),
	write(' \\n '),
	printMarkedFormulasInDotFormat(FM),
	writeln('" shape="box" fillcolor="lightgray" style="filled,rounded"];'),
	printNodesInDotFormat(Rest).

/****************************************************/
/* printFormulasInDotFormat(L)                      */
/****************************************************/
%stampa un elenco di formule in successione

printFormulasInDotFormat([]).
printFormulasInDotFormat([F]):- !,
	write(F).
printFormulasInDotFormat([F|Rest]):-
	write(F),
	write(', '),
	printFormulasInDotFormat(Rest).


/****************************************************/
/* printMarkedFormulasInDotFormat(L)                */
/****************************************************/
%stampa un elenco di formule in successione

printMarkedFormulasInDotFormat([]).
printMarkedFormulasInDotFormat([F]):- !,
	write('('),
	write(F),
	write(')* ').

printMarkedFormulasInDotFormat([F|Rest]):-
	write('('),
	write(F),
	write(')*, '),
	printMarkedFormulasInDotFormat(Rest).