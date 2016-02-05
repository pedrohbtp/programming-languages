// Should achieve better performance than better safe
// and better reliability than unsynchronized.
// Cannot deadlock
import java.util.concurrent.atomic.AtomicIntegerArray;
class BetterSorryState implements State {
    //private byte[] value;
    private AtomicIntegerArray value;
    private byte maxval;

    BetterSorryState(byte[] v) { value = new AtomicIntegerArray(byteArToIntAr(v)); maxval = 127; }

    BetterSorryState(byte[] v, byte m) { value = new AtomicIntegerArray(byteArToIntAr(v)); maxval = m; }

    public int size() { return value.length(); }

    public byte[] current() { 
        byte[] cur = new byte[value.length()];
        for(int i = 0; i<value.length();i++)
        {
           cur[i] =  (byte) value.get(i);
        }
        return cur; 
    
    }
    
    /*Receives a byte[] and returns int[]*/
    private int[] byteArToIntAr(byte[] v){
        int[] res = new int[v.length];
        for(int i=0; i<v.length;i++){
            res[i] = v[i];
        }
        return res;
    }

    public boolean swap(int i, int j) {
    //Returns true to avoid deadlocking
	if (value.get(i) <= 0 || value.get(j) >= maxval) {
	    return true;
	}
	value.getAndDecrement(i);
	value.getAndIncrement(j);
	return true;
    }
}
