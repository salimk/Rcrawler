



import java.math.BigInteger;   
import java.util.ArrayList;   
import java.util.List;   
import java.util.StringTokenizer;   
  
public class SimHash {   
       
    public String getsimHash(String s, int hashbits) {
        int[] v = new int[hashbits];   
        StringTokenizer stringTokens = new StringTokenizer(s);   
        while (stringTokens.hasMoreTokens()) {   
            String temp = stringTokens.nextToken();   
            BigInteger t = hash(temp, hashbits);   
            for (int i = 0; i < hashbits; i++) {   
                BigInteger bitmask = new BigInteger("1").shiftLeft(i);   
                 if (t.and(bitmask).signum() != 0) {   
                    v[i] += 1;   
                } else {   
                    v[i] -= 1;   
                }   
            }   
        }   
        BigInteger fingerprint = new BigInteger("0");   
        StringBuffer simHashBuffer = new StringBuffer();   
        for (int i = 0; i < hashbits; i++) {   
            if (v[i] >= 0) {   
                fingerprint = fingerprint.add(new BigInteger("1").shiftLeft(i));   
                simHashBuffer.append("1");   
            }else{   
                simHashBuffer.append("0");   
            }   
        }   
		String strSimHash = simHashBuffer.toString();   
        //System.out.println(this.strSimHash + " length " + this.strSimHash.length());   
        return strSimHash; 	
    }   
    
	public BigInteger hash(String source, int hashbits) {
		
        if (source == null || source.length() == 0) {   
            return new BigInteger("0");   
        } else {   
            char[] sourceArray = source.toCharArray();   
            BigInteger x = BigInteger.valueOf(((long) sourceArray[0]) << 7);   
            BigInteger m = new BigInteger("1000003");   
            BigInteger mask = new BigInteger("2").pow(hashbits).subtract(   
                    new BigInteger("1"));   
            for (char item : sourceArray) {   
                BigInteger temp = BigInteger.valueOf((long) item);   
                x = x.multiply(m).xor(temp).and(mask);   
            }   
            x = x.xor(new BigInteger(String.valueOf(source.length())));   
            if (x.equals(new BigInteger("-1"))) {   
                x = new BigInteger("-2");   
            }   
            return x;   
        }   
    }  
	
   
   public static void main(String[] args) {   
 
    }   
}
