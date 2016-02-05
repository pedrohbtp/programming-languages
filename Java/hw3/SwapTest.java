import java.util.concurrent.ThreadLocalRandom;

class SwapTest implements Runnable {
    private int nTransitions;
    private State state;

    SwapTest(int n, State s) {
	nTransitions = n;
	state = s;
    }

    public void run() {
	int n = state.size();
	if (n != 0)
	// Loops until the specified number of swaps is met
	    for (int i = 0; i < nTransitions; ) {
		int a = ThreadLocalRandom.current().nextInt(0, n);
		int b = ThreadLocalRandom.current().nextInt(0, n - 1);
		// A swap cannot be performed with itself, then if the indexes of the 
		// array are the same, make b=n-1
		if (a == b)
		    b = n - 1;
		// Only if the swap is successful, increments the counter. 
		// It might loop forever if there exist no valid pair of nodes to be
		// swapped. That is: if all elements are equal to 0 or maxvalue,
		// then it will always fail and loop forever.
		if (state.swap(a, b))
		    i++;
	    }
    }
}
