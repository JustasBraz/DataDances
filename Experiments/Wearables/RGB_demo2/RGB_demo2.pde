
ArrayList RainbowLines;

void setup() {
  size(400, 400);
  strokeWeight(16);
  smooth();
  colorMode(HSB, 360, 100, 100);
  background(360);
  RainbowLines = new ArrayList();
}

void draw() {
  background(360);
  // Add new line?
  if (mousePressed){
    RainbowLines.add( new RainbowLine() );
  }
  // Cycle colors.
  colourdegrees+=1.5;
  colourdegrees%=360;
  // Render all lines  
  for( int i = 0; i < RainbowLines.size(); i++ ){
    RainbowLine t = (RainbowLine) RainbowLines.get(i);
    t.draw();
  }
  // Limit ArrayList size (optional)!
  while( RainbowLines.size() > 400 ){
     RainbowLines.remove(0);
  }
}

void keyPressed(){
  if( key == ' ' ){
    RainbowLines = new ArrayList();
  }
}
