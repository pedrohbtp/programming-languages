import java.util.concurrent.atomic.AtomicIntegerArray;
class GetNSetState implements State {
    // private byte[] value;
    private AtomicIntegerArray value;
    private byte maxval;

    GetNSetState(byte[] v) { value = new AtomicIntegerArray(byteArToIntAr(v)); maxval = 127; }

    GetNSetState(byte[] v, byte m) { value = new AtomicIntegerArray(byteArToIntAr(v)); maxval = m; }

    public int size() { return value.length(); }
    
    /*Receives a byte[] and returns int[]*/
    private int[] byteArToIntAr(byte[] v){
        int[] res = new int[v.length];
        for(int i=0; i<v.length;i++){
            res[i] = v[i];
        }
        return res;
    }
    
    public byte[] current() { 
        byte[] cur = new byte[value.length()];
        for(int i = 0; i<value.length();i++)
        {
           cur[i] =  (byte) value.get(i);
        }
        return cur; 
    
    }

    public boolean swap(int i, int j) {
	if (value.get(i) <= 0 || value.get(j) >= maxval) {
	    return false;
	}
// 	value[i]--;
// 	value[j]++;
    value.set(i,value.get(i)-1);
    value.set(j,value.get(j)+1);
	return true;
    }
}
