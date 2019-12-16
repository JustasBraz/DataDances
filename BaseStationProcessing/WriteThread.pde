 public class WriteThread implements Runnable {
  private Serial serial;
  public WriteThread(Serial serial) {
     this.serial = serial;
  }

  public void run() {
    serial.write('0');
  }
 }
