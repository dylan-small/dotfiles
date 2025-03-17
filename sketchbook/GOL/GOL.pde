import java.util.Collections;

int cellSize = 8;
int columns, rows;
boolean[][] grid;
boolean[][] next;
PGraphics pg;
int counter = 0;
String[] patterns = {
  "glider", "blinker", "spaceship", "gosper", "random"
};

void settings() {
  size(1080,400);
}

void setup() {
  frameRate(20);
  noCursor();
  columns = width / cellSize;
  rows = height / cellSize;
  
  grid = new boolean[columns][rows];
  next = new boolean[columns][rows];
  pg = createGraphics(width, height);
  
  initializePatterns();
}

void draw() {
  pg.beginDraw();
  pg.background(0);
  
  for (int x = 0; x < columns; x++) {
    for (int y = 0; y < rows; y++) {
      

      int neighbors = countNeighbors(x, y);
      
      if (grid[x][y]) {
        next[x][y] = (neighbors == 2 || neighbors == 3);
      } else {
        next[x][y] = (neighbors == 3);
      }
      

      if (grid[x][y]) {
        pg.fill(10, 78, 111);
        pg.rect(x * cellSize, y * cellSize, cellSize-1, cellSize-1);
      }
    }
  }
  
  pg.endDraw();
  image(pg, 0, 0);
  
  // Swap grids
  boolean[][] temp = grid;
  grid = next;
  next = temp;
}

void initializePatterns() {
  for (int i = 0; i < random(10,30); i++) {
    addRandomPattern(
      (int)random(width),
      (int)random(height)
    );
  }
}

void addRandomPattern(int x, int y) {
  x = constrain(x, cellSize*37, width-cellSize*37);
  y = constrain(y, cellSize*10, height-cellSize*10);
  
  int col = x / cellSize;
  int row = y / cellSize;
  
  int diceRoll = (int)random(100);
  String pattern;
  if (diceRoll > 85) {
    pattern = "gosper";
  }
  else if (diceRoll > 45) {
    pattern = "spaceship";
  }
  else if (diceRoll > 30) {
    pattern = "glider";
  }
  else if (diceRoll > 20) {
    pattern = "blinker";
  }
  else {
    pattern = "random";
  }
  
  switch(pattern) {
    case "glider":
      setCell(col+1, row, true);
      setCell(col+2, row+1, true);
      setCell(col, row+2, true);
      setCell(col+1, row+2, true);
      setCell(col+2, row+2, true);
      break;
      
    case "blinker":
      setCell(col, row, true);
      setCell(col, row+1, true);
      setCell(col, row+2, true);
      break;
      
    case "spaceship":
      setCell(col+1, row, true);
      setCell(col+2, row, true);
      setCell(col+3, row, true);
      setCell(col+4, row, true);
      setCell(col, row+1, true);
      setCell(col+4, row+1, true);
      setCell(col+4, row+2, true);
      setCell(col, row+3, true);
      setCell(col+3, row+3, true);
      break;
      
    case "gosper":
      // Gosper Glider Gun
      
      //left block
      setCell(col+1, row-4, true);
      setCell(col+1, row-5, true);
      setCell(col+2, row-4, true);
      setCell(col+2, row-5, true);
      
      //generator
      setCell(col + 11, row - 3, true);
      setCell(col + 11, row - 4, true);
      setCell(col + 11, row - 5, true);
      setCell(col + 12, row - 2, true);
      setCell(col + 12, row - 6, true);
      setCell(col + 13, row - 1, true);
      setCell(col + 14, row - 1, true);
      setCell(col + 13, row - 7, true);
      setCell(col + 14, row - 7, true);
      setCell(col + 15, row - 4, true);
      setCell(col + 16, row - 6, true);
      setCell(col + 16, row - 2, true);
      setCell(col + 17, row - 3, true);
      setCell(col + 17, row - 4, true);
      setCell(col + 17, row - 5, true);
      setCell(col + 18, row - 4, true);
      
      setCell(col + 21, row - 5, true);
      setCell(col + 21, row - 6, true);
      setCell(col + 21, row - 7, true);
      setCell(col + 22, row - 5, true);
      setCell(col + 22, row - 6, true);
      setCell(col + 22, row - 7, true);
      setCell(col + 23, row - 8, true);
      setCell(col + 23, row - 4, true);
      setCell(col + 25, row - 8, true);
      setCell(col + 25, row - 9, true);
      setCell(col + 25, row - 4, true);
      setCell(col + 25, row - 3, true);
      
      //right block
      setCell(col + 35, row - 6, true);
      setCell(col + 36, row - 6, true);
      setCell(col + 35, row - 7, true);
      setCell(col + 36, row - 7, true);
      
      break;
      
    case "random":
    default:
      for (int i = 0; i < (cellSize * 2); i++) {
        setCell(col+(int)random(-5,5), row+(int)random(-5,5), true);
      }
      break;
  }
}

int countNeighbors(int x, int y) {
  int count = 0;
  for (int i = -1; i <= 1; i++) {
    for (int j = -1; j <= 1; j++) {
      if (i == 0 && j == 0) continue;
      int nx = (x + i + columns) % columns;
      int ny = (y + j + rows) % rows;
      if (grid[nx][ny]) count++;
    }
  }
  return count;
}

void setCell(int x, int y, boolean state) {
  if (x >= 0 && x < columns && y >= 0 && y < rows) {
    grid[x][y] = state;
  }
}
