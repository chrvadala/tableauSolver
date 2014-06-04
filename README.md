tableauSolver
=============


tableauSolver è un programma scritto in Prolog per la creazione di tableau, partendo da un insieme di formule della logica temporale.



Alcuni esempi:

?- solveTableau([(p & -q) v diamond (q)] ).


?- solveTableau([box diamond p, diamond -p  ] ).




Esempio di risultato:

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


  Nella prima parte del risultato sono presenti tutti i vertici del tableau. Il formato utilizzato per visualizzare questi dati è il seguente `idNodo : ListaFormule {ListaFormuleMarcate}*`. Nella seconda parte sono invece presenti tutti gli archi. Il formato utilizzato è il seguente
  `idNodoUscente -> idNodoEntrante`
