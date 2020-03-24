import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;
import java.util.Random;

public class Agent {

    static int prevMove = 0;
    static int[][] boards = new int[10][10];
    static Random rand = new Random();
    /* 0 = Empty
     * 1 = I played here
     * 2 = They played here
     * Zero index not used
     */
    public static void main(String args[]) throws IOException {

	if(args.length < 2) {
	    System.out.println("Usage: java Agent -p (port)");
	    return;
	}
		
	final String host = "localhost";
	final int portNumber = Integer.parseInt(args[1]);

	Socket socket = new Socket(host, portNumber);
	BufferedReader br = new BufferedReader(new InputStreamReader(socket.getInputStream()));
	PrintWriter out = new PrintWriter(socket.getOutputStream(), true);

	String line;

	while (true) {

	    line = br.readLine();

	    int move = parse(line);

	    if(move == -1) {
		socket.close();
		return;
	    }else if(move == 0){
		//TODO
	    }else {
		out.println(move);
	    }

	}
    }

    public static int parse(String line) {

	if(line.contains("init")) {
	    //TODO
	}else if(line.contains("start")) {
	    //TODO
	}else if(line.contains("second_move")) {

	    int argsStart = line.indexOf("(");
	    int argsEnd = line.indexOf(")");

	    String list = line.substring(argsStart+1, argsEnd);
	    String[] numbers = list.split(",");

	    place(Integer.parseInt(numbers[0]),Integer.parseInt(numbers[1]), 2);

	    return makeRandomMove();

	}else if(line.contains("third_move")) {

	    int argsStart = line.indexOf("(");
	    int argsEnd = line.indexOf(")");

	    String list = line.substring(argsStart+1, argsEnd);	
	    String[] numbers = list.split(",");

	    place(Integer.parseInt(numbers[0]),Integer.parseInt(numbers[1]), 1);
	    place(Integer.parseInt(numbers[1]),Integer.parseInt(numbers[2]), 2);

	    return makeRandomMove();

	}else if(line.contains("next_move")) {
			
	    int argsStart = line.indexOf("(");
	    int argsEnd = line.indexOf(")");

	    String list = line.substring(argsStart+1, argsEnd);	
	    place(prevMove, Integer.parseInt(list), 2);

	    return makeRandomMove();

	}else if(line.contains("last_move")) {
	    //TODO
	}else if(line.contains("win")) {
	    //TODO
	}else if(line.contains("loss")) {
	    //TODO
	}else if(line.contains("end")) {

	    return -1;
	}
	return 0;
    }

    public static void place(int board, int num, int player) {

	prevMove = num;
	boards[board][num] = player;
    }

    public static int makeRandomMove() {

	int n = rand.nextInt(9) + 1;

	while(boards[prevMove][n] != 0) {
	    n = rand.nextInt(9) + 1;
	}

	place(prevMove, n, 1);
	return n;
    }

}
