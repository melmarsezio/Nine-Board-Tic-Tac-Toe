#!/usr/bin/python3
# Sample starter bot by Zac Partridge
# Contact me at z.partridge@unsw.edu.au
# 06/04/19
# Feel free to use this and modify it however you wish

import socket
import sys
import numpy as np
import math
import collections

# a board cell can hold:
#   0 - Empty
#   1 - I played here
#   2 - They played here

#class Heuristic:
#    def __init__(self):
#        self.a = None
#        self.b = None
#        self.c = None
#        self.d = None
#        self.e = None
#        self.f = None
#        self.g = None
#        self.h = None
#        self.i = None

# the boards are of size 10 because index 0 isn't used
boards = np.zeros((10, 10), dtype="int8")
s = [".","X","O"]
S = [None,'a','b','c','d','e','f','g','h','i']
curr = 0 # this is the current board to play in
search_depth = 4
#scale = [0,2,1,2,1,3,1,2,1,2]
#heuristic = Heuristic()

# print a row
# This is just ported from game.c
def print_board_row(board, a, b, c, i, j, k):
    print(" "+s[board[a][i]]+" "+s[board[a][j]]+" "+s[board[a][k]]+" | " \
             +s[board[b][i]]+" "+s[board[b][j]]+" "+s[board[b][k]]+" | " \
             +s[board[c][i]]+" "+s[board[c][j]]+" "+s[board[c][k]])

# Print the entire board
# This is just ported from game.c
def print_board(board):
    print_board_row(board, 1,2,3,1,2,3)
    print_board_row(board, 1,2,3,4,5,6)
    print_board_row(board, 1,2,3,7,8,9)
    print(" ------+-------+------")
    print_board_row(board, 4,5,6,1,2,3)
    print_board_row(board, 4,5,6,4,5,6)
    print_board_row(board, 4,5,6,7,8,9)
    print(" ------+-------+------")
    print_board_row(board, 7,8,9,1,2,3)
    print_board_row(board, 7,8,9,4,5,6)
    print_board_row(board, 7,8,9,7,8,9)
    print(" ------+-------+------")
    print(" ------+-------+------")
    print()

# choose a move to play
def play():
    print_board(boards)
    n = alpha_beta(curr, search_depth, 1) # 1 means its us to play, in alpha_beta recursively times -1 to indicate whos turn
    place(curr, n, 1)
    return n

def killer_move(cell, target):
    global killermoves
    killermoves = []
    if (boards[cell][1:4] == [0,target,target]).all() or\
       (boards[cell][1::3] == [0,target,target]).all() or\
       (boards[cell][1::4] == [0,target,target]).all():
        killermoves.append(1)
    elif (boards[cell][1:4] == [target,0,target]).all() or\
         (boards[cell][2::3] == [0,target,target]).all():
        killermoves.append(2)
    elif (boards[cell][1:4] == [target,target,0]).all() or\
         (boards[cell][3::3] == [0,target,target]).all() or\
         (boards[cell][3:8:2] == [0,target,target]).all():
        killermoves.append(3)
    elif (boards[cell][4:7] == [0,target,target]).all() or\
         (boards[cell][1::3] == [target,0,target]).all():
        killermoves.append(4)
    elif (boards[cell][4:7] == [target,0,target]).all() or\
         (boards[cell][2::3] == [target,0,target]).all() or\
         (boards[cell][3:8:2] == [target,0,target]).all() or\
         (boards[cell][1::4] == [target,0,target]).all():
        killermoves.append(5)
    elif (boards[cell][4:7] == [target,target,0]).all() or\
         (boards[cell][3::3] == [target,0,target]).all():
        killermoves.append(6)
    elif (boards[cell][7:] == [0,target,target]).all() or\
         (boards[cell][1::3] == [target,target,0]).all() or\
         (boards[cell][3:8:2] == [target,target,0]).all():
        killermoves.append(7)
    elif (boards[cell][7:] == [target,0,target]).all() or\
         (boards[cell][2::3] == [target,target,0]).all():
        killermoves.append(8)
    elif (boards[cell][7:] == [target,target,0]).all() or\
         (boards[cell][3::3] == [target,target,0]).all() or\
         (boards[cell][1::4] == [target,target,0]).all():
        killermoves.append(9)

def alpha_beta(cell, depth, player, alpha = -math.inf, beta = math.inf):
    killer_move(cell,1)
    #print(f'My potential killer moves: {killermoves}') if depth == search_depth else 0
    if depth == search_depth and killermoves:
        return killermoves[0]
    child_nodes = killermoves
    length = len(child_nodes)
    child_nodes.extend([i for i in range(1,10) if boards[cell][i]== 0 and not (i in child_nodes)])
    #print(f'Current Available moves: {child_nodes}') if depth == search_depth else 0
    remove_list = []
    for i in child_nodes:
        killer_move(i,-1)
        if killermoves and child_nodes.index(i)>=length:
            remove_list.append(i)
    #print(f'Current opponent killer moves: {remove_list}') if depth == search_depth else 0
    for i in remove_list:
        child_nodes.remove(i)
    #print(f'After elimination, my available moves left: {child_nodes}') if depth == search_depth else 0
    #if depth == search_depth:
    #    killer_move(cell,-1)
    #    for i in killermoves:
    #        if i in child_nodes:
    #            return i

    if depth == 0 or not child_nodes or winning(cell, -player):
        evaluate(cell)
        #for index in range(1,10):
        #    total = 0
        #    if index != cell:
        #        total += heuristic.__dict__[S[index]]
        #    else:
        #        total += evaluate(cell)
        #return total if depth != search_depth else remove_list[0]
        return value if depth != search_depth else remove_list[0]
    elif player > 0:
        for i in child_nodes:
            fake_place(cell, i, player)
            #if depth == 1:
            #    for index in range(1,10):
            #        heuristic.__dict__[S[index]] = evaluate(index)
            if depth != search_depth:
                alpha = max(alpha, alpha_beta(i, depth-1, -player, alpha, beta))
            else:
                new_alpha = alpha_beta(i, depth-1, -player, alpha, beta)
                if new_alpha > alpha:
                    alpha, move = new_alpha, i
            unplace(cell, i)
            if alpha >= beta:
                return alpha
        return alpha if depth != search_depth else move
    else:
        for i in child_nodes:
            fake_place(cell, i, player)
            #if depth == 1:
            #    for index in range(1,10):
            #        heuristic.__dict__[S[index]] = evaluate(index)
            beta = min(beta, alpha_beta(i, depth-1, -player, alpha, beta))
            unplace(cell, i)
            if beta <= alpha:
                return beta
        return beta
    return 'Something went wrong!!!'

def evaluate(i):
    global x, value, X2, X1, O2, O1
    X2 = 0; X1 = 0; O2 = 0; O1 = 0;
    value = 0
    x = collections.Counter(boards[i][1:4])
    sub_evaluate()
    x = collections.Counter(boards[i][4:7])
    sub_evaluate()
    x = collections.Counter(boards[i][7:])
    sub_evaluate()
    x = collections.Counter(boards[i][1::3])
    sub_evaluate()
    x = collections.Counter(boards[i][2::3])
    sub_evaluate()
    x = collections.Counter(boards[i][3::3])
    sub_evaluate()
    x = collections.Counter(boards[i][1::4])
    sub_evaluate()
    x = collections.Counter(boards[i][3:8:2])
    sub_evaluate()
    value += 3*X2+X1-(20*O2+5*O1)
    return value

def sub_evaluate():
    global value, X2, X1, O2, O1
    if x[1] == 2 and x[0] == 1:
        X2 += 1
    elif x[-1] == 2 and x[0] == 1:
        O2 += 1
    elif x[0] == 2 and x[1] == 1:
        X1 += 1
    elif x[0] == 2 and x[-1] == 1:
        O1 += 1
    elif x[1] == 3:
        value += 1000
    elif x[-1] == 3:
        value -= 10000

#def sub_evaluate():
#    global value
#    if x[1] == 2 and x[0] == 1:
#        value += 300
#    elif x[-1] == 2 and x[0] == 1:
#        value -= 300
#    elif x[0] == 2 and x[1] == 1:
#        value += 10
#    elif x[0] == 2 and x[-1] == 1:
#        value -= 10
#    elif x[1] == 3:
#        value += 10000
#    elif x[-1] == 3:
#        value -= 10000
#    elif x[0] == 3:
#        value += 1

def winning(cell, player):
    if (boards[cell][1:4] == [player,player,player]).all() or (boards[cell][4:7] == [player,player,player]).all() or\
       (boards[cell][7:] == [player,player,player]).all() or (boards[cell][1::3] == [player,player,player]).all() or\
       (boards[cell][2::3] == [player,player,player]).all() or (boards[cell][3::3] == [player,player,player]).all() or\
       (boards[cell][1::4] == [player,player,player]).all() or (boards[cell][3:8:2] == [player,player,player]).all():
        return True
    return False

def fake_place(cell, num, player):
    boards[cell][num] = player

def unplace(cell, i):
    boards[cell][i] = 0

# place a move in the global boards
def place(board, num, player):
    global curr
    curr = num
    boards[board][num] = player

# read what the server sent us and
# only parses the strings that are necessary
def parse(string):
    if "(" in string:
        command, args = string.split("(")
        args = args.split(")")[0]
        args = args.split(",")
    else:
        command, args = string, []

    if command == "second_move":
        place(int(args[0]), int(args[1]), -1)
        return play()
    elif command == "third_move":
        # place the move that was generated for us
        place(int(args[0]), int(args[1]), 1)
        # place their last move
        place(curr, int(args[2]), -1)
        return play()
    elif command == "next_move":
        place(curr, int(args[0]), -1)
        return play()
    elif command == "win":
        print_board(boards)
        print("Yay!! We win!! :)")
        return -1
    elif command == "loss":
        print_board(boards)
        print("We lost :(")
        return -1
    elif command == "draw":
        print_board(boards)
        print("Draw game :|")
        return -1
    return 0

# connect to socket
def main():
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    port = int(sys.argv[2]) # Usage: ./agent.py -p (port)

    s.connect(('localhost', port))
    while True:
        text = s.recv(1024).decode()
        if not text:
            continue
        for line in text.split("\n"):
            response = parse(line)
            if response == -1:
                s.close()
                return
            elif response > 0:
                s.sendall((str(response) + "\n").encode())

if __name__ == "__main__":
    main()
