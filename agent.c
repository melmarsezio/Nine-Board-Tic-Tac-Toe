/*********************************************************
 *  agent.c
 *  Nine-Board Tic-Tac-Toe Agent
 *  COMP3411/9414/9814 Artificial Intelligence
 *  Alan Blair, CSE, UNSW
 *  and
 *  Chencheng Xie and Ruijun Zhou
 */

/*
 Briefly describe how program works, including any algorithms and data structures employed:
 The search algorithm implemented in this program is alphabeta pruning algorithms, the data structure used is "array", the board, number(Counter), child_nodes, and heuristic_list are stored as array. When agent is asked for next_move, it calls alphabeta search, at each depth, the child nodes (all legal moves) are examined and stored in child_nodes, and recursively calls alphabeta search on each of the moves in child_nodes. When it reaches the depth limits, someone wins or draw situation, alphabeta returns heuristic value. The heuristic value are calculated as the sum of all 9 heuristic values of all 9 boards, 3 marks in a row indicates win and gives total heuristic value of that board 999999, 2 marks in a single straight line gives 30 points, 1 mark in single straight line gives 1 point. About the heuristic value, instead of calculate all 9 boards of heuristic values at depth 0, we calculate all 9 boards of heuristic values at depth 2, and calculate the board we played at depth 1 and depth 0. Replace those two heuristic values with previous 2 of 9 heuristic values to cut down time spent on this (b*b*b to b+b*b). After returning heuristic value to alphabeta function, alpha and beta are updated if returned heuristic value is greater than previous alpha value(previous heuristic value) or less than previous beta value(previous heuristic value). The branch is pruned if alpha >= beta or someone is winning. At certain path, when we have some moves and one of them is winning, we won't be considering other options. Similarly, when opponent have one winning move for them, that move will be carried out.
 
 Explain any design decisions made along the way:
 Firstly, we used monte-carlo on prolog, since the behavior is not as expected, we changed to alpha beta pruning which we are more familiar with. At the very beginning of the programing for alpha-beta pruning, we moved killer moves which are more likely to prune the remaining available legal moves forward, but the result was not good as well. Since the lack of time, we used heuristic function to calculate the heuristic value for each move, further study could be done. During the process of test, we found that our search depth was bounded below 10, so we improve the heuristic calculation method as mentioned in the above paragraph. We previously coded using python and prolog, after testing we found that these two languages were both too slow to reach our expected result (around 6 and 8 search depth repectively, since the search depth is the most important factor to measure how program performance beside heuristic evaluation function); to get better performance, we changed to C language and got our search depth to around 10.
 
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>

#include "common.h"
#include "agent.h"
#include "game.h"

#define MAX_MOVE 81

int board[10][10];      // 0: Opponent, 1: Agent, 2: Empty
int number[3] = {0,0,0};// number acts as a counter for a straight line in a single board
int heuristic = 0;      // the heuristic value of any board
int last_move_heuristic;// the heuristic value of second last move in the alphabeta game tree
int heuristic_list[10]; // the heuristic list to record heuristic values of all 9 boards
int search_depth = 11;  // the search depth of alphabeta algorithm
int child_nodes[12][10];// the array of legal moves in specific search depth
int move[MAX_MOVE+1];
int player;
int m;

/*********************************************************/
/*
   Print usage information and exit
*/
void usage( char argv0[] )
{
  printf("Usage: %s\n",argv0);
  printf("       [-p port]\n"); // tcp port
  printf("       [-h host]\n"); // tcp host
  exit(1);
}

/*********************************************************/
/*
   Parse command-line arguments
*/
void agent_parse_args( int argc, char *argv[] )
{
  int i=1;
  while( i < argc ) {
    if( strcmp( argv[i], "-p" ) == 0 ) {
      if( i+1 >= argc ) {
        usage( argv[0] );
      }
      port = atoi(argv[i+1]);
      i += 2;
    }
    else if( strcmp( argv[i], "-h" ) == 0 ) {
      if( i+1 >= argc ) {
        usage( argv[0] );
      }
      host = argv[i+1];
      i += 2;
    }
    else {
      usage( argv[0] );
    }
  }
}

/*********************************************************/
/*
   Called at the beginning of a series of games
*/
void agent_init()
{
  struct timeval tp;

  // generate a new random seed each time
  gettimeofday( &tp, NULL );
  srandom(( unsigned int )( tp.tv_usec ));
}

/*********************************************************/
/*
   Called at the beginning of each game
*/
void agent_start( int this_player ){
    reset_board( board );
    m = 0;
    move[m] = 0;
    player = this_player;
}

/*********************************************************/
/*
    FindAvailable
    Loops through index "i" 1 to 9 and
    marks child_nodes[depth][i] as "1" if "i" is a legal
    move in current play board (board[current][i] == 2,empty)
*/
void find_available(int depth, int current){
    int i;
    for (i = 1; i <= 9; i++) {
        child_nodes[depth][i] = 0;
        if (board[current][i] == 2) {
            child_nodes[depth][i] = 1;
        }
    }
}

/*********************************************************/
/*
    Sub_heuristic
    Adds up values to existing sub-heuristic value,
    winning or losing instantly gives "sub-heuristic" a 999999 or -999999,
    two marks in a single straight line without block gives 30 points,
    one mark in single straight line without block gives 1 points.
*/
int sub_heuristic(){
    if(number[1] == 3){// if 3 "1" in a row, we win, return 999999 without calculating other points
        heuristic = 999999;
        return heuristic;
    }
    if(number[0] == 3){// if 3 "0" in a row, we lost, return -999999 without calculating other points
        heuristic = -999999;
        return heuristic;
    }
    if (number[1] == 2 && number[2] == 1) { // if 2 "1" and 1 empty, we have 30 points
        heuristic = heuristic + 30;
    }
    if (number[0] == 2 && number[2] == 1) { // if 2 "0" and 1 empty, we lost 30 points
        heuristic = heuristic - 30;
    }
    if (number[2] == 2 && number[1] == 1) { // if 1 "1" and 2 empty, we have 1 point
        heuristic = heuristic + 1;
    }
    if (number[2] == 2 && number[0] == 1) { // if 1 "0" and 2 empty, we lost 1 point
        heuristic = heuristic - 1;
    }
    number[0] = 0;          // Reset the "number" array after finish using it
    number[1] = 0;          // So next time when we using it, it won't mess up
    number[2] = 0;          // the amount of "0","1", and "2".
    return heuristic;
}

/*********************************************************/
/*
    Counter
    For the straight line at board[cell],
    the straight line is formed with a, b, c position,
    number[1] ++ if we found "player" in the straight line,
    similarly, number[0] ++ if we found "!player" in the straight line,
    and number[2] ++ if we found "Empty"(2) in the straight line.
 */
void counter(int cell, int a, int b, int c){    // a, b, c are three positions that form a straight line.
    if (board[cell][a] == player) {             // e.g. 123,258,357 etc.
        number[1] ++;
    }else if (board[cell][a] == !player) {
        number[0] ++;
    }else if (board[cell][a] == 2) {
        number[2] ++;
    }
    if (board[cell][b] == player) {
        number[1] ++;
    }else if (board[cell][b] == !player) {
        number[0] ++;
    }else if (board[cell][b] == 2) {
        number[2] ++;
    }
    if (board[cell][c] == player) {
        number[1] ++;
    }else if (board[cell][c] == !player) {
        number[0] ++;
    }else if (board[cell][c] == 2) {
        number[2] ++;
    }
}


/*********************************************************/
/*
    Heuristic value
    Initialises the "heuristic" as 0,
    count the number of "0"s,"1"s and "2"s in a single straight
    line, and calculate the points earned by that straight line (sub-heuristic),
    accumulate all sub-heuristic value to get final heuristic value of one board.
 */
int heuristic_value(int cell){
    heuristic = 0;
    counter(cell,1,2,3);    // the 1,2,3 refer to a,b,c in function "counter" as positions
    sub_heuristic();        // calculate the points using the number counted in "counter" and reset it when finish.
    counter(cell,4,5,6);
    sub_heuristic();
    counter(cell,7,8,9);
    sub_heuristic();
    counter(cell,1,5,9);
    sub_heuristic();
    counter(cell,3,5,7);
    sub_heuristic();
    counter(cell,1,4,7);
    sub_heuristic();
    counter(cell,2,5,8);
    sub_heuristic();
    counter(cell,3,6,9);
    sub_heuristic();
    return heuristic;
}

/*********************************************************/
/*
    Winning
    Inspects the board[cell], if "player" or "!player" wins, return TRUE
*/
_Bool Winning(int cell, int play_){
    if (board[cell][1] == play_ && board[cell][2] == play_ &&board[cell][3] == play_){  //if board[cell][1,2,3] all == play_, play_ wins
        return TRUE;
    }else if(board[cell][4] == play_ && board[cell][5] == play_ && board[cell][6] == play_){
        return TRUE;
    }else if(board[cell][7] == play_ && board[cell][8] == play_ && board[cell][9] == play_){
        return TRUE;
    }else if(board[cell][1] == play_ && board[cell][4] == play_ && board[cell][7] == play_){
        return TRUE;
    }else if(board[cell][2] == play_ && board[cell][5] == play_ && board[cell][8] == play_){
        return TRUE;
    }else if(board[cell][3] == play_ && board[cell][6] == play_ && board[cell][9] == play_){
        return TRUE;
    }else if(board[cell][1] == play_ && board[cell][5] == play_ && board[cell][9] == play_){
        return TRUE;
    }else if(board[cell][3] == play_ && board[cell][5] == play_ && board[cell][7] == play_){
        return TRUE;
    }
    return FALSE;
}

/*********************************************************/
/*
    Draw
    If no child_nodes[depth][i] found to be 1,
    there is no legal move left, the game comes to draw.
*/
_Bool Draw(int depth){
    int i;
    for ( i = 1; i <= 9; i++ ){
        if (child_nodes[depth][i] == 1){
            return FALSE;
        }
    }
    return TRUE;
}


/*********************************************************/
/*
    Alphabeta
    Performs alphabeta pruning game tree search
*/
int alphabeta(int last_board, int prev_move, int depth, int play_, int alpha, int beta){
    int i, _move = 0;                       //  "i": index for looping throught arrays
                                        // "_move": the best legal move (updates when alpha is updated)
    find_available(depth, prev_move);   // assign available nodes in the 'child_nodes'
    if ( depth != search_depth && Winning(last_board, player) ){ // if "player" wins, return 999999 as heuristic value
        return 999999;               // without the "depth != search_depth", it will try to return 999999 as next_move
    }else if ( depth != search_depth && Winning(last_board, !player) ){ // if "!player" wins, return -999999 as heuristic value
        return -999999;
    }else if (depth == 0){                      // if depth == 0, return the total heuristic value (the sum of all heuristic values of all 9 boards)
        int total = 0, index;                   // instead of calculating all 9 heuristic values of each board at depth 0,
        for (index = 1; index <=9; index++){    // calculate 9 heuristic value of 9 boards at depth 2,
            if (index == prev_move){            // and replace the heuristic value of the last two board we played at depth 1 and depth 0
                total = total + heuristic_value(prev_move); // this can reduce the time spend on calculating heuristic values (b*b*b to b+b*b)
            }else if (index == last_board){
                total = total + last_move_heuristic;
            }else {
                total = total + heuristic_list[index];
            }
        }
        return total;
    }else if (Draw(depth)){ // if we have a draw situation, return 0 as heuristic
        return 0;
    }else if (play_ == player) { // our turn
        for (i = 1; i <= 9; i++) {
            if (child_nodes[depth][i] == 1) {   //for each legal child_node move
                int index;
                board[prev_move][i] = play_;    // play the move
                if (depth == 2){                // calculate all 9 heuristic values at depth 2
                    for (index = 1; index <= 9; index++){
                        heuristic_list[index] = heuristic_value(index); // store the heuristic value in heuristic_list with "index" as their board number
                    }
                }else if (depth == 1){          // calculate the heuristic value on the second last board we played
                    last_move_heuristic = heuristic_value(i); // store it as "last_move_heuristic" compare to depth 0 (this is depth 1)
                }
                int new_alpha = alphabeta(prev_move, i, depth-1, !play_, alpha, beta); // assign new alphabeta value to "new_alpha"
                if (alpha < new_alpha) {        // update "alpha" and "_move" if new_alpha > alpha
                    alpha = new_alpha;
                    _move = i;
                }
                board[prev_move][i] = 2;        // unplayed the board (set wherever we played to "empty"(2))
                if (alpha >= beta) {            // prune if alpha >= beta or we have a winning case
                    return alpha;               // because when we have the winning case, we will definitely do that among other moves
                }else if (alpha >= 900000){     // 900000 indicates winning case (999999 for winning plus or minus points from other boards)
                    if (depth == search_depth){ // return "_move" instead of alpha value at root
                        return _move;
                    }else {
                        return alpha;
                    }
                }
            }
        }
        if (depth != search_depth) {            // return alpha value if not at root
            return alpha;
        }else{
            return _move;                       // return "_move" when we are at root
        }
    } else { // opponent's turn
        for (i = 1; i <= 9; i++) {              // similar to above only we dont need to consider root
            if (child_nodes[depth][i] == 1) {   // case, since beta can never be atroot level
                int index;
                board[prev_move][i] = play_;
                if (depth == 2){
                    for (index = 1; index <= 9; index++){
                        heuristic_list[index] = heuristic_value(index);
                    }
                }else if (depth == 1){
                    last_move_heuristic = heuristic_value(i);
                }
                int new_beta = alphabeta(prev_move, i, depth-1, !play_, alpha, beta);
                if (beta > new_beta) {
                    beta = new_beta;
                }
                board[prev_move][i] = 2;
                if (alpha >= beta) {        // prune if beta <= alpha or we have a losing case
                    return beta;            // because when opponent have the winning case for them, they will definitely do that among other moves
                }else if (beta <= -900000){ // -900000 indicates losing case (-999999 for losing plus or minus points from other boards)
                    return beta;
                }
            }
        }
        return beta;
    }
    return 0;
}

/*********************************************************/
/*
    Call alphabeta search
    returns our move in "agent_second_move", "agent_third_move" and "agent_next_move"
*/
int search( int prev_move ){
    return alphabeta(0 , prev_move, search_depth, player, -9999999, 9999999);
}

/*********************************************************/
/*
   Choose second move and return it
*/
int agent_second_move( int board_num, int prev_move )
{
    int this_move;
    move[0] = board_num;
    move[1] = prev_move;
    board[board_num][prev_move] = !player;
    m = 2;
    this_move = search(prev_move);
    move[m] = this_move;
    board[prev_move][this_move] = player;
    return( this_move );
}

/*********************************************************/
/*
   Choose third move and return it
*/
int agent_third_move(
                     int board_num,
                     int first_move,
                     int prev_move
                    )
{
    int this_move;
    move[0] = board_num;
    move[1] = first_move;
    move[2] = prev_move;
    board[board_num][first_move] =  player;
    board[first_move][prev_move] = !player;
    m=3;
    this_move = search(prev_move);
    move[m] = this_move;
    board[move[m-1]][this_move] = player;
    return( this_move );
}

/*********************************************************/
/*
   Choose next move and return it
*/
int agent_next_move( int prev_move )
{
    int this_move;
    m++;
    move[m] = prev_move;
    board[move[m-1]][move[m]] = !player;
    m++;
    this_move = search(prev_move);
    move[m] = this_move;
    board[move[m-1]][this_move] = player;
    return( this_move );
}

/*********************************************************/
/*
   Receive last move and mark it on the board
*/
void agent_last_move( int prev_move )
{
    m++;
    move[m] = prev_move;
    board[move[m-1]][move[m]] = !player;
}

/*********************************************************/
/*
   Called after each game
*/
void agent_gameover(
                    int result,// WIN, LOSS or DRAW
                    int cause  // TRIPLE, ILLEGAL_MOVE, TIMEOUT or FULL_BOARD
                   )
{
    if(result==2){
        printf("Yay!!! We Win!! :)\n");
    }else if (result == 3){
        printf("We Lost :(\n");
    }
}

/*********************************************************/
/*
   Called after the series of games
*/
void agent_cleanup()
{
  // nothing to do here
}
