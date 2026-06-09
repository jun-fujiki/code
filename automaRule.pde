import controlP5.*;
ControlP5 cp5;
controlP5.Slider slider;

Cell[][] cells;
int SIZEX = 100;
int SIZEY = 100;
int step = 0;

int targetCountNum = 30;
int aroundRange = 3;

void controlEvent(ControlEvent e)
{
  if (e.isFrom( "Target Alive Cell Num" ) )
  {
    targetCountNum = (int)e.getValue();
    slider.getValueLabel().setText( "" + int( targetCountNum ) );
  }
}

int getDigit( Cell cell )
{
  if ( cell.state < 0.5 )
    return 0;
  else
    return 1;
}

// -----------------------
void setup()
{
  size( 1000, 1000 );
  frameRate( 60 );

  int min = 0;
  int max = 100;

  cp5 = new ControlP5(this);
  slider = cp5.addSlider( "Target Alive Cell Num" );
  slider
    .setPosition(20, 20)
    .setSize(200, 20)
    .setValue( 30 )
    .setNumberOfTickMarks( max - min + 1 )
    .showTickMarks( false )
    .getCaptionLabel().setColor( color(0, 0, 127) );

  // セルの初期化
  cells = new Cell[SIZEX][SIZEY];
  for ( int i=0; i<SIZEX; i++ )
  {
    for ( int j=0; j<SIZEY; j++ )
    {
      Cell c = new Cell();
      c.x = i*10;
      c.y = j*10;
      cells[i][j] = c;
    }
  }

  for ( int i=0; i<SIZEX; i++ )
  {
    cells[i][0].state = random(1);
  }

  // セルの描画
  for ( int i=0; i<SIZEX; i++ )
  {
    Cell c = cells[i][step%SIZEY];
    c.render();
  }
}

// -----------------------
void draw()
{
  // ルールの反映
  for ( int i=0; i<SIZEX; i++ )
  {
    int aa = getDigit( cells[(i+3+SIZEX)%SIZEX][step%SIZEY] );
    int a0 = getDigit( cells[(i+2+SIZEX)%SIZEX][step%SIZEY] );
    int a1 = getDigit( cells[(i+1+SIZEX)%SIZEX][step%SIZEY] );
    int a2 = getDigit( cells[(i+0+SIZEX)%SIZEX][step%SIZEY] );
    int a3 = getDigit( cells[(i-1+SIZEX)%SIZEX][step%SIZEY] );
    int a4 = getDigit( cells[(i-2+SIZEX)%SIZEX][step%SIZEY] );
    int a5 = getDigit( cells[(i-3+SIZEX)%SIZEX][step%SIZEY] );
    int idx = (a5<<6) | (a4<<5) | (a3<<4) | (a2<<3) | (a1<<2) | (a0<<1) | (aa<<0);
    cells[i][step%SIZEY].prevRule = cells[i][step%SIZEY].currentRule;
    cells[i][step%SIZEY].currentRule = idx;
    cells[i][(step+1)%SIZEY].state = cells[i][step%SIZEY].rule[idx];
    for ( int j=0; j<cells[i][(step+1)%SIZEY].rule.length; j++ )
    {
      cells[i][(step+1)%SIZEY].rule[j] = cells[i][(step)%SIZEY].rule[j];
    }
  }

  // ルールをバトンタッチ
  for ( int i=0; i<SIZEX; i++ )
  {
    cells[i][(step+1)%SIZEY].rule = cells[i][(step)%SIZEY].rule;
  }

  int currentCountNum = 0;
  for ( int i=0; i<SIZEX; i++ )
  {
    if ( getDigit( cells[i][(step+1)%SIZEY] ) == 1 )
    {
      currentCountNum++;
    }
  }
  int dis = abs( targetCountNum - currentCountNum );
  //if ( dis > 10 )
  //println( "target:" + targetCountNum + "  - current:" + currentCountNum );


  // -------------------------------------------------
  // 1

  float error = targetCountNum - currentCountNum;
  float gain = 0.3;

  for (int i = 0; i < SIZEX; i++)
  {
    float aa = ( cells[(i+3+SIZEX)%SIZEX][step%SIZEY].state );
    float a0 = ( cells[(i+2+SIZEX)%SIZEX][step%SIZEY].state );
    float a1 = ( cells[(i+1+SIZEX)%SIZEX][step%SIZEY].state );
    float a2 = ( cells[(i+0+SIZEX)%SIZEX][step%SIZEY].state );
    float a3 = ( cells[(i-1+SIZEX)%SIZEX][step%SIZEY].state );
    float a4 = ( cells[(i-2+SIZEX)%SIZEX][step%SIZEY].state );
    float a5 = ( cells[(i-3+SIZEX)%SIZEX][step%SIZEY].state );

    {
      int r = cells[i][step%SIZEY].currentRule;

      float localSum = aa + a0 + a1 + a2 + a3 + a4 + a5;
      float locality = map(localSum, 0, 7, 0.0, 1.0);
      float delta = gain * ( error / SIZEX );

      float v = cells[i][(step+1)%SIZEY].rule[r];
      v += delta;
      v = constrain(v, 0.0, 1.0);
      cells[i][(step+1)%SIZEY].rule[r] = v;
    }
  }

  // ステップ更新
  step++;

  // セルの描画
  for ( int i=0; i<SIZEX; i++ )
  {
    Cell c = cells[i][step%SIZEY];
    c.render();
  }
}

// -----------------------
// Rule class
// -----------------------

class Rule
{
  int index;
}

// -----------------------
// Cell class
// -----------------------

class Cell
{
  int x, y;
  float state; // 0か１のどちらかの状態
  float state_next; // 次の状態
  float rule[] = new float[(int)pow(2, 7)];
  int currentRule = -1;
  int prevRule = -1;

  Cell()
  {
    state = 0;
    for ( int i=0; i<rule.length; i++ )
    {
      rule[i] = random(1);
    }
  }

  void render()
  {
    colorMode( HSB, 8, 100, 100 );
    stroke( 0, 0, 90 );
    if ( getDigit( this ) == 0 )
    {
      fill( 0, 0, 100 );
    } else
    {
      fill( 0, 255, 255 );
    }

    rect( x, y, 10, 10 );
  }
}
