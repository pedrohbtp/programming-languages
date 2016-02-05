import java.util.concurrent.locks.ReentrantLock;
class BetterSafeState implements State {
    private ReentrantLock stateLock = new ReentrantLock();
    private volatile byte[] value;
    private byte maxval;

    BetterSafeState(byte[] v) { value = v; maxval = 127; }

    BetterSafeState(byte[] v, byte m) { value = v; maxval = m; }

    public int size() { return value.length; }

    public byte[] current() { return value; }

    public boolean swap(int i, int j) {
    stateLock.lock();
	if (value[i] <= 0 || value[j] >= maxval) {
	    stateLock.unlock();
	    return false;
	}
	value[i]--;
	value[j]++;
	stateLock.unlock();
	return true;
    }
}
