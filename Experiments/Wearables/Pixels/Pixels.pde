Tile [][] grid;
//number of rows and columns
int cols;
int rows;
int step=20;
void setup() {
  size(800, 800);
  cols=ceil(width/step);
  rows=ceil(height/step);
  grid = new Tile[cols][rows];

  //generate grid
  for (int i=0; i<cols; i++) {
    for (int j=0; j<rows; j++) {
      //initiate objects
      grid[i][j] = new Tile (i*cols, j*cols, cols, 255);
    }
  }
}


void draw() {
  background(255);
  for (int i=0; i<cols; i++) {
    for (int j=0; j<rows; j++) {
      //show me them goodies
      grid[i][j].display();
      grid[i][j].checkMouse();
      
      if(mousePressed){
        grid[i][j].displayID();
      }
    }
  }

}

void record(){
  
   if(frameCount%17==0){
 saveFrame("GridDemoImg/"+frameCount+".png");
  }
 grid[7][6].black();

}
