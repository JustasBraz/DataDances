Tile [][] grid;
//number of rows and columns
int cols;
int rows;
int step=20;
void setup() {
  size(1000, 800);
initTiles();
}


void draw() {
  background(255);
  //translate(width/2, height/2);
  displayTiles();
}
void displayTiles(){
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
void initTiles(){
  cols=ceil(width/step);
  rows=ceil(height/step);
  grid = new Tile[cols][rows];
  
  //generate grid
  for (int i=0; i<cols; i++) {
    for (int j=0; j<rows; j++) {
      //initiate objects
      float nudge=step/2;
      grid[i][j] = new Tile (i*step+nudge, j*step+nudge, step, 255);
    }
  }
}
void record(){
  
   if(frameCount%17==0){
 saveFrame("GridDemoImg/"+frameCount+".png");
  }
 grid[7][6].black();

}
