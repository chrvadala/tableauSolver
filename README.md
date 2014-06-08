# tableauSolver

*tableauSolver* è un programma scritto in Prolog che, partendo da un insieme di formule della logica temporale, genera il grafo del tableau corrispondente.

INFO: E' possibile trasformare il risultato testuale del programma in un disegno, semplicemente copiando il risultato restituito in formato DOT sul visualizzatore online di file DOT http://graphviz-dev.appspot.com


## ESEMPI
````
 ?- solve([(p & -q) v diamond q] ).
 ?- solve([box diamond p, diamond -p  ] ).
````

## SIMBOLI SUPPORTATI
 AND => (A & B)
 OR  => (A v B)
 NOT => (-A)
 BOX => (box A) 
 DIAMOND => (diamond A)
 NEXT => (next A)

## ESEMPIO DI TABLEAU GENERATO (NOTA: VIENE ANCHE GENERATO UN RISULTATO GRAFICAMENTE RAPPRESENTABILE)
````
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
````

 INTERPRETAZIONE RISULTATO
 Nella prima parte del risultato sono presenti tutti i vertici del tableau. Il formato utilizzato per visualizzare questi dati è il seguente `idNodo : ListaFormule {ListaFormuleMarcate}*`.

 Nella seconda parte sono invece presenti tutti gli archi. Il formato utilizzato è il seguente `idNodoUscente -> idNodoEntrante`

  La terza parte è invece una rappresentazione del grafo in formato DOT, graficamente visualizzabile tramite diverse librerie.
  Un possibile tool online per visualizzare il grafo è questo: http://graphviz-dev.appspot.com
 



## Esempio di tableau generato graficamente:
````
---------------------------------------------------------------
- copia ed incolla su    http://graphviz-dev.appspot.com      -
- il seguente codice per visualizzare un disegno del tableau  -
---------------------------------------------------------------
digraph g{
9 [label="9: p, -q \n (p& -q)*, (p& -q v diamond q)* " shape="box" fillcolor="lightgray" style="filled,rounded"];
2 [label="2: p& -q \n (p& -q v diamond q)* " shape="box" fillcolor="lightgray" style="filled,rounded"];
4 [label="4: q \n (diamond q)*, (p& -q v diamond q)* " shape="box" fillcolor="lightgray" style="filled,rounded"];
7 [label="7: q \n (diamond q)* " shape="box" fillcolor="lightgray" style="filled,rounded"];
8 [label="8: next diamond q \n (diamond q)* " shape="box" fillcolor="lightgray" style="filled,rounded"];
6 [label="6: diamond q \n " shape="box" fillcolor="lightgray" style="filled,rounded"];
5 [label="5: next diamond q \n (diamond q)*, (p& -q v diamond q)* " shape="box" fillcolor="lightgray" style="filled,rounded"];
3 [label="3: diamond q \n (p& -q v diamond q)* " shape="box" fillcolor="lightgray" style="filled,rounded"];
1 [label="1: p& -q v diamond q \n " shape="box" fillcolor="palegreen" style="filled,rounded"];
2 -> 9
8 -> 6
6 -> 8
6 -> 7
5 -> 6
3 -> 5
3 -> 4
1 -> 3
1 -> 2
}
````

![Esempio di tableau generato graficamente](https://raw.githubusercontent.com/work-out-web/tableauSolver/master/result-example.png)







