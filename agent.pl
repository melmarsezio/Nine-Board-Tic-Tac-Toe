%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  agent.pl
%  Nine-Board Tic-Tac-Toe Agent
%  COMP3411/9414/9814 Artificial Intelligence
%  Alan Blair, CSE, UNSW

other(x,o).
other(o,x).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  mark(+P,+M,+SubBoard0,-SubBoard1)
%  mark move M for player P on SubBoard0 to produce SubBoard1
%
mark(P,1,[e|T],[P|T]).
mark(P,2,[A,e|T],[A,P|T]).
mark(P,3,[A,B,e|T],[A,B,P|T]).
mark(P,4,[A,B,C,e|T],[A,B,C,P|T]).
mark(P,5,[A,B,C,D,e|T],[A,B,C,D,P|T]).
mark(P,6,[A,B,C,D,E,e|T],[A,B,C,D,E,P|T]).
mark(P,7,[A,B,C,D,E,F,e|T],[A,B,C,D,E,F,P|T]).
mark(P,8,[A,B,C,D,E,F,G,e,I],[A,B,C,D,E,F,G,P,I]).
mark(P,9,[A,B,C,D,E,F,G,H,e],[A,B,C,D,E,F,G,H,P]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  play(+P,+L,+M,+Board0,-Board1)
%  mark move M for player P on board L of Board0 to produce Board1
%
play(_P,0,Board,Board).
play(P,1,M,[B|T],[B1|T]) :- mark(P,M,B,B1).
play(P,2,M,[C,B|T],[C,B1|T]) :- mark(P,M,B,B1).
play(P,3,M,[C,D,B|T],[C,D,B1|T]) :- mark(P,M,B,B1).
play(P,4,M,[C,D,E,B|T],[C,D,E,B1|T]) :- mark(P,M,B,B1).
play(P,5,M,[C,D,E,F,B|T],[C,D,E,F,B1|T]) :- mark(P,M,B,B1).
play(P,6,M,[C,D,E,F,G,B|T],[C,D,E,F,G,B1|T]) :- mark(P,M,B,B1).
play(P,7,M,[C,D,E,F,G,H,B|T],[C,D,E,F,G,H,B1|T]) :- mark(P,M,B,B1).
play(P,8,M,[C,D,E,F,G,H,I,B,K],[C,D,E,F,G,H,I,B1,K]) :- mark(P,M,B,B1).
play(P,9,M,[C,D,E,F,G,H,I,J,B],[C,D,E,F,G,H,I,J,B1]) :- mark(P,M,B,B1).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  empty(-M,+SubBoard)
%  check that cell M of SubBoard is empty
%
empty(1,[e|_]).
empty(2,[_,e|_]).
empty(3,[_,_,e|_]).
empty(4,[_,_,_,e|_]).
empty(5,[_,_,_,_,e|_]).
empty(6,[_,_,_,_,_,e|_]).
empty(7,[_,_,_,_,_,_,e|_]).
empty(8,[_,_,_,_,_,_,_,e,_]).
empty(9,[_,_,_,_,_,_,_,_,e]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  legal(+L,-M,+Board)
%  true if cell M of board L is legal
%
legal(1,M,[B|_]) :- empty(M,B).
legal(2,M,[_,B|_]) :- empty(M,B).
legal(3,M,[_,_,B|_]) :- empty(M,B).
legal(4,M,[_,_,_,B|_]) :- empty(M,B).
legal(5,M,[_,_,_,_,B|_]) :- empty(M,B).
legal(6,M,[_,_,_,_,_,B|_]) :- empty(M,B).
legal(7,M,[_,_,_,_,_,_,B|_]) :- empty(M,B).
legal(8,M,[_,_,_,_,_,_,_,B,_]) :- empty(M,B).
legal(9,M,[_,_,_,_,_,_,_,_,B]) :- empty(M,B).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  subwin(+P,SubBoard)
%  true if player P has achieved 3-in-a-row
%
subwin(P,[P,P,P|_]).
subwin(P,[_,_,_,P,P,P|_]).
subwin(P,[_,_,_,_,_,_,P,P,P]).
subwin(P,[P,_,_,P,_,_,P,_,_]).
subwin(P,[_,P,_,_,P,_,_,P,_]).
subwin(P,[_,_,P,_,_,P,_,_,P]).
subwin(P,[P,_,_,_,P,_,_,_,P]).
subwin(P,[_,_,P,_,P,_,P,_,_]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  winning(+P,+L,+Board)
%  true if player P has achieved 3-in-a-row on board L
%
winning(P,1,[B|_]) :- subwin(P,B).
winning(P,2,[_,B|_]) :- subwin(P,B).
winning(P,3,[_,_,B|_]) :- subwin(P,B).
winning(P,4,[_,_,_,B|_]) :- subwin(P,B).
winning(P,5,[_,_,_,_,B|_]) :- subwin(P,B).
winning(P,6,[_,_,_,_,_,B|_]) :- subwin(P,B).
winning(P,7,[_,_,_,_,_,_,B|_]) :- subwin(P,B).
winning(P,8,[_,_,_,_,_,_,_,B,_]) :- subwin(P,B).
winning(P,9,[_,_,_,_,_,_,_,_,B]) :- subwin(P,B).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  open socket and establish TCP read/write streams
%
connect(Port) :-
   tcp_socket(Socket),
   gethostname(Host),
   tcp_connect(Socket,Host:Port),
   tcp_open_socket(Socket,INs,OUTs),
   assert(connectedReadStream(INs)),
   assert(connectedWriteStream(OUTs)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  read next command and execute it
%
ttt :-
   connectedReadStream(IStream),
   read(IStream,Command),
   Command.

init :- ttt.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  start(+P)
%  start a new game for player P
%
start(P) :-
   retractall(board(_ )),
   retractall(player(_ )),
   retractall(prev_move(_ )),
   assert(board(
   [[e,e,e,e,e,e,e,e,e],[e,e,e,e,e,e,e,e,e],[e,e,e,e,e,e,e,e,e],
    [e,e,e,e,e,e,e,e,e],[e,e,e,e,e,e,e,e,e],[e,e,e,e,e,e,e,e,e],
    [e,e,e,e,e,e,e,e,e],[e,e,e,e,e,e,e,e,e],[e,e,e,e,e,e,e,e,e]])),
   assert(player(P)),
   ttt.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  second_move(+K,+L)
%  assume first move is board K, cell L
%  choose second move and write it
%
second_move(K,L) :-
   retract(board(Board0)),
   player(P), other(P,Q),
   play(Q,K,L,Board0,Board1),
   print_board(Board1),
   search(P,L,Board1,M),
   play(P,L,M,Board1,Board2),
   print_board(Board2),
   assert(board(Board2)),
   assert(prev_move(M)),
   write_output(M),
   ttt.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  third_Move(+J,+K,+L)
%  assume first move is board K, cell L,
%           second move is board L, cell M
%  choose third move and write it
%
third_move(J,K,L) :-
   retract(board(Board0)),
   player(P),
   play(P,J,K,Board0,Board1),
   print_board(Board1),
   other(P,Q),
   play(Q,K,L,Board1,Board2),
   print_board(Board2),
   search(P,L,Board2,M),
   play(P,L,M,Board2,Board3),
   print_board(Board3),
   assert(board(Board3)),
   assert(prev_move(M)),
   write_output(M),
   ttt.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  next_move(+L)
%  assume opponent move is L
%  choose (our) next move and write it
%
next_move(L) :-
   retract(prev_move(K)),
   retract(board(Board0)),
   player(P), other(P,Q),
   play(Q,K,L,Board0,Board1),
   print_board(Board1),
   search(P,L,Board1,M),
   play(P,L,M,Board1,Board2),
   print_board(Board2),
   assert(board(Board2)),
   assert(prev_move(M)),
   write_output(M),
   ttt.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  search(+P,+L,+Board,-M)
%  choose Move M for player P on board L
%
% search(_P,L,Board,Move):-
%   findall(M,legal(L,M,Board),List),
%   random_member(List,Move).

search(P,L,Board,Move):-
    Depth is 5,
    alpha_beta(P,L,Depth,Board,-2000,2000,Move,_Value).

% search(P,L,Board,Move):-
%   mcts(P,L,Board,Move).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  alpha_beta(+P,+D,+Board,+Alpha,+Beta,-Move,-Value)
%  perform alpha-beta search to depth D for player P,
%  assuming P is about to move on Board. Return Value
%  of current Board position, and best Move for P.

% if other player has won, Value is -1000
alpha_beta(P,L,_D,Board,_Alpha,_Beta,0,-1000) :-
   other(P,Q),
   winning(Q,L,Board), ! .

% if depth limit exceeded, use heuristic estimate
alpha_beta(P,_L,0,Board,_Alpha,_Beta,0,Value) :-
   value(P,Board,Value), ! .

% evaluate and choose all legal moves in this position
alpha_beta(P,L,D,Board,Alpha,Beta,Move,Value) :-
   D > 0,
   findall(M,legal(L,M,Board),Moves),
   Moves \= [], !,
   Alpha1 is -Beta,
   Beta1 is -Alpha,
   D1 is D-1,
   eval_choose(P,L,Moves,Board,D1,Alpha1,Beta1,0,Move,Value).

% if no available moves, it must be a draw
alpha_beta(_P,_L,_D,_Board,_Alpha,_Beta,0,0).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  eval_choose(+P,+Moves,+Board,+D,+Alpha,+Beta,+BestMove
%              -ChosenMove,-Value)
%  Evaluate list of Moves and determine Value of position
%  as well as ChosenMove for this Board position
% (taking account of current BestMove for this position)

% if no more Moves, BestMove becomes ChosenMove and Value is Alpha
eval_choose(_P,_L,[],_Board,_D,Alpha,_Beta,BestMove,BestMove,Alpha).

% evaluate Moves, find Value of Board Position, and ChosenMove for P
eval_choose(P,L,[M|Moves],Board,D,Alpha,Beta,BestMove,ChosenMove,Value) :-
   play(P,L,M,Board,Board1),
   other(P,Q),
   alpha_beta(Q,M,D,Board1,Alpha,Beta,_Move1,Value1),
   V is -Value1,
   cutoff(P,Moves,Board,D,Alpha,Beta,BestMove,M,V,ChosenMove,Value).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  cutoff(+P,+Moves,+Board,+D,+Alpha,+Beta,+BestMove,+M,+V,
%              -ChosenMove,-Value)
%  Compare move M (with value V) to Alpha and Beta,
%  and compute Value and ChosenMove appropriately.

% cut off the search, ChosenMove is M and Value is V
cutoff(_P,_Moves,_Board,_D,_Alpha,Beta,_Move0,M,V,M,V) :-
   V >= Beta.

% Alpha increases to V, BestMove is M, continue search
cutoff(P,Moves,Board,D,Alpha,Beta,_BestMove,M,V,ChosenMove,Value) :-
   Alpha < V, V < Beta,
   eval_choose(P,_L,Moves,Board,D,V,Beta,M,ChosenMove,Value).

% keep searching, with same Alpha, Beta, BestMove
cutoff(P,Moves,Board,D,Alpha,Beta,BestMove,_M,V,ChosenMove,Value) :-
   V =< Alpha,
   eval_choose(P,_L,Moves,Board,D,Alpha,Beta,BestMove,ChosenMove,Value).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
value(_P,[],0).

value(P,[B|T],Value):-
    other(P,Q),
    evaluate(P,Q,B,Current_Value),
    value(P,T, Value1),
    Value is Value1 + Current_Value.

evaluate(P,Q,[A,B,C,D,E,F,G,H,I],Current_Value):-
    heuristic(P,[A,D,G],Value1),
    heuristic(Q,[A,D,G],Value2),
    heuristic(P,[B,E,H],Value3),
    heuristic(Q,[B,E,H],Value4),
    heuristic(P,[C,F,I],Value5),
    heuristic(Q,[C,F,I],Value6),
    heuristic(P,[A,B,C],Value7),
    heuristic(Q,[A,B,C],Value8),
    heuristic(P,[D,E,F],Value9),
    heuristic(Q,[D,E,F],Value10),
    heuristic(P,[G,H,I],Value11),
    heuristic(Q,[G,H,I],Value12),
    heuristic(P,[A,E,I],Value13),
    heuristic(Q,[A,E,I],Value14),
    heuristic(P,[C,E,G],Value15),
    heuristic(Q,[C,E,G],Value16),
    Current_Value is Value1 - Value2 + Value3 - Value4 + Value5 - Value6 + Value7 - Value8 + Value9 - Value10 + Value11 - Value12 + Value13 - Value14 + Value15 - Value16.

heuristic(P,[P,P,P],10000).
heuristic(P,[P,P,e],300).
heuristic(P,[P,e,P],300).
heuristic(P,[e,P,P],300).
heuristic(P,[e,e,P],10).
heuristic(P,[e,P,e],10).
heuristic(P,[P,e,e],10).
heuristic(_P,[_,_,_],0).





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Monte Carlo tree search
%  mcts(+P,+L,+Board,+Move).
%  perform random moves on the specific nodes and collects
%  total win rate.

mcts(P,L,Board,Move):-
   killer_move(P,L,Board,Move).

mcts(P,L,Board,Move):-
   findall(M,legal(L,M,Board),List),
   NbOfSimulation is 300,
   expand(P,L,Board,List,Move,_WinRate,NbOfSimulation).

killer_move(P,1,[B|_],Move) :- subkiller(P,B,Move).
killer_move(P,2,[_,B|_],Move) :- subkiller(P,B,Move).
killer_move(P,3,[_,_,B|_],Move) :- subkiller(P,B,Move).
killer_move(P,4,[_,_,_,B|_],Move) :- subkiller(P,B,Move).
killer_move(P,5,[_,_,_,_,B|_],Move) :- subkiller(P,B,Move).
killer_move(P,6,[_,_,_,_,_,B|_],Move) :- subkiller(P,B,Move).
killer_move(P,7,[_,_,_,_,_,_,B|_],Move) :- subkiller(P,B,Move).
killer_move(P,8,[_,_,_,_,_,_,_,B,_],Move) :- subkiller(P,B,Move).
killer_move(P,9,[_,_,_,_,_,_,_,_,B],Move) :- subkiller(P,B,Move).

subkiller(P,[e,P,P|_],1).
subkiller(P,[P,e,P|_],2).
subkiller(P,[P,P,e|_],3).

subkiller(P,[_,_,_,e,P,P|_],4).
subkiller(P,[_,_,_,P,e,P|_],5).
subkiller(P,[_,_,_,P,P,e|_],6).

subkiller(P,[_,_,_,_,_,_,e,P,P],7).
subkiller(P,[_,_,_,_,_,_,P,e,P],8).
subkiller(P,[_,_,_,_,_,_,P,P,e],9).

subkiller(P,[e,_,_,P,_,_,P,_,_],1).
subkiller(P,[P,_,_,e,_,_,P,_,_],4).
subkiller(P,[P,_,_,P,_,_,e,_,_],7).

subkiller(P,[_,e,_,_,P,_,_,P,_],2).
subkiller(P,[_,P,_,_,e,_,_,P,_],5).
subkiller(P,[_,P,_,_,P,_,_,e,_],8).

subkiller(P,[_,_,e,_,_,P,_,_,P],3).
subkiller(P,[_,_,P,_,_,e,_,_,P],6).
subkiller(P,[_,_,P,_,_,P,_,_,e],9).

subkiller(P,[e,_,_,_,P,_,_,_,P],1).
subkiller(P,[P,_,_,_,e,_,_,_,P],5).
subkiller(P,[P,_,_,_,P,_,_,_,e],9).

subkiller(P,[_,_,e,_,P,_,P,_,_],3).
subkiller(P,[_,_,P,_,e,_,P,_,_],5).
subkiller(P,[_,_,P,_,P,_,e,_,_],7).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  expand
expand(P,L,Board,[Move],Move,WinRate,NbOfSimulation):-
   simulate(P,L,Move,Board,WinRate,NbOfSimulation).

expand(P,L,Board,[First|Moves],ChoosenMove,ChoosenWinRate,NbOfSimulation):-
   expand(P,L,Board,Moves,Choice,WinRate1,NbOfSimulation),
   simulate(P,L,First,Board,WinRate,NbOfSimulation),
   choose(First,WinRate,Choice,WinRate1,ChoosenMove,ChoosenWinRate).

choose(First,WinRate,_Choice,WinRate1,ChoosenMove,ChoosenWinRate):-
   WinRate > WinRate1,
   ChoosenMove is First,
   ChoosenWinRate is WinRate.

choose(_First,WinRate,Choice,WinRate1,ChoosenMove,ChoosenWinRate):-
   WinRate =< WinRate1,
   ChoosenMove is Choice,
   ChoosenWinRate is WinRate1.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  simulate()
simulate(_P,_L,_First,_Board,0,0).

simulate(P,L,First,Board,WinRate,NbOfSimulation):-
   first_step(P,L,First,Board,Result),
   NbOfSimulation1 is NbOfSimulation-1,
   simulate(P,L,First,Board,WinRate1,NbOfSimulation1),
   WinRate is Result+WinRate1.

% make first step on choosen cell
first_step(P,L,First,Board,1):-
   play(P,L,First,Board,Board1),
   winning(P,First,Board1).

first_step(P,L,First,Board,Result):-
   other(P,Q),
   play(P,L,First,Board,Board1),
   play_til_end(Q,First,Board1,Result).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% play til end
% Winning
play_til_end(P,L,Board0,1):-
   findall(M1,legal(L,M1,Board0),List),
   random_member(List,Move),
   play(P,L,Move,Board0,Board1),
   winning(P,L,Board1),
   P = o.

% Losing
play_til_end(P,L,Board0,-1):-
   findall(M1,legal(L,M1,Board0),List),
   random_member(List,Move),
   play(P,L,Move,Board0,Board1),
   winning(P,L,Board1),
   P = x.

% Draw
play_til_end(P,L,Board0,0):-
   findall(M1,legal(L,M1,Board0),List),
   random_member(List,Move),
   play(P,L,Move,Board0,Board1),
   findall(M2,legal(L,M2,Board1),List1),
   List1 = [].

play_til_end(P,L,Board0,Result):-
   other(P,Q),
   findall(M1,legal(L,M1,Board0),List),
   random_member(List,Move),
   play(P,L,Move,Board0,Board1),
   play_til_end(Q,Move,Board1,Result).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  random_member(+List,-Item)
%  choose a random Item in the List
%
random_member(List,Item) :-
    length(List, Num),
    N is random(Num),
    nth0(N, List, Item).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  write_output(+M)
%  transmit the chosen move (M)
%
write_output(M) :-
   connectedWriteStream(OStream),
   write(OStream,M),
   nl(OStream), flush_output(OStream).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  print_board()
%
print_board([A,B,C,D,E,F,G,H,I]) :-
   print3boards(A,B,C),
   write('------+-------+------'),nl,
   print3boards(D,E,F),
   write('------+-------+------'),nl,
   print3boards(G,H,I),nl.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  print_board()
%
print3boards([A1,A2,A3,A4,A5,A6,A7,A8,A9],
             [B1,B2,B3,B4,B5,B6,B7,B8,B9],
             [C1,C2,C3,C4,C5,C6,C7,C8,C9]) :-
   print_line(A1,A2,A3,B1,B2,B3,C1,C2,C3),
   print_line(A4,A5,A6,B4,B5,B6,C4,C5,C6),
   print_line(A7,A8,A9,B7,B8,B9,C7,C8,C9).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  print_line()
%
print_line(A,B,C,D,E,F,G,H,I) :-
   write(A),write(' '),write(B),write(' '),write(C),write(' | '),
   write(D),write(' '),write(E),write(' '),write(F),write(' | '),
   write(G),write(' '),write(H),write(' '),write(I),nl.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  last_move(+L)
%
last_move(L) :-
   retract(prev_move(K)),
   retract(board(Board0)),
   player(P), other(P,Q),
   play(Q,K,L,Board0,Board1),
   print_board(Board1),
   ttt.

win(_)  :- write('win'), nl,ttt.
loss(_) :- write('loss'),nl,ttt.
draw(_) :- write('draw'),nl,ttt.

end :- halt.
