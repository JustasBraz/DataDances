import java.util.ArrayList;
import java.util.Random;
import java.lang.Math;

public class ColorSingleton {
 
    private static ColorSingleton instance;
    private ArrayList<Integer> curColors;
    private int allowedError = 60;
    private Random rand = new Random();
    
    private ColorSingleton() {
      curColors = new ArrayList<Integer>();
    }
     
    public static ColorSingleton getInstance() {
        if(instance == null) {
            instance = new ColorSingleton();
        }
         
        return instance;
    }
    
    public int getColor() {
      int sample = rand.nextInt((360));
      int c = 0;
      
      while (tooSimilar(sample)) {
        c += 1;
        sample += allowedError;
        if (sample > 360) {
          sample -= 360;
        }
        if (c > 360 / allowedError) {
          c = 0;
          allowedError /= 2;
        }
      }
      return sample;
    }
    
    private boolean tooSimilar(int input) {
      for (int i : curColors) {
        if (Math.abs(input - i) < allowedError) {
          return true;
        }
      }
      return false;
    }
    
}
