//================================================================================================
// Author: Scott Bateman
//
// Line graph of sensor readings to be displayed in a separate window during game play.
// Jumps are marked as highlighted regions.
//================================================================================================
public class SensorGraphApplet extends PApplet {
    private LimitedSizeQueue<Integer> leftReadings, rightReadings, lines;
    private long counter = 0;
    private Frame parentFrame;
    
    public SensorGraphApplet(Frame parentFrame){
      this.parentFrame = parentFrame; 
    }
    
    public void settings() {
      size(725, 410);
       
      leftReadings = new LimitedSizeQueue<Integer>(50);
      rightReadings = new LimitedSizeQueue<Integer>(50);
      lines = new LimitedSizeQueue<Integer>(50);
    }
    
    public void draw() {
      background(255);
      frameRate(20);
      giveFocusToParentFrame();
      
      leftReadings.add(round(rawReadings.get(LEFT_DIRECTION_LABEL)*100));
      rightReadings.add(round(rawReadings.get(RIGHT_DIRECTION_LABEL)*100));
      lines.add(round(rawReadings.get(JUMP_DIRECTION_LABEL)));
          
      lineChart(this,
            leftReadings, rightReadings,
            lines,
            50, 370, 
            675, 300, 
            100, false, 
            color(0,0,255), color(255, 0, 0), color(0,0,100),
            false); 
    }
    
    void removeExitEvent() {
      final java.awt.Window win = ((processing.awt.PSurfaceAWT.SmoothCanvas) getSurface().getNative()).getFrame();
 
      for (final java.awt.event.WindowListener evt : win.getWindowListeners())
        win.removeWindowListener(evt);
    }
    
    void giveFocusToParentFrame(){
     java.awt.EventQueue.invokeLater(
       new Runnable() {
          @Override
          public void run() {
            parentFrame.toFront();
            //parentFrame.repaint();
          }
      }); 
    }
}

void lineChart( PApplet graph,
                LimitedSizeQueue<Integer> data1, LimitedSizeQueue<Integer> data2, 
                LimitedSizeQueue<Integer> lines,
                int x, int y, 
                int w, int h, 
                int maxVal, boolean smartScale, 
                color lineColor1, color lineColor2, color labelColor,
                boolean displayValues
               ){
    
    LimitedSizeQueue<Integer>[] dataGroup = new LimitedSizeQueue[2];
    dataGroup[0] = data1;
    dataGroup[1] = data2;
    
    color[] colors = {lineColor1, lineColor2};
                 
    //Use system font 'Arial' as the header font with 12 point type
    PFont h1 = createFont("Lucida Sans Regular", 12, true);
    
    //Use system font 'Arial' as the label font with 9 point type
    PFont l1 = createFont("Lucida Sans Regular", 12, true);
    
    //Set the stroke color to a medium gray for the axis lines.
    graph.stroke(175);
    
    graph.textFont(l1);
    graph.textAlign(LEFT, TOP);

    graph.text("left", x+w/2 - 33, y + 10);
    graph.fill(lineColor1);
    graph.rect(x+w/2 - 46, y + 12, 10, 10);
    
    graph.fill(labelColor);
    graph.text("right", x+w/2 + 18, y + 10);
    graph.fill(lineColor2);
    graph.rect(x+w/2 + 5, y + 12, 10, 10);
    
    graph.fill(labelColor);
    graph.text("jump", x+w/2 + 77, y + 10);
    graph.fill(#F3F315,100);
    graph.rect(x+w/2 + 60, y + 12, 10, 10);
    
    //Declare a float variabe for the max y axis value.
    int ymax = 0;
    
    //Declare a float variable for the minimum y axis value.
    int ymin = 0;
    
    //draw the axis lines.
    graph.line(x-3,y+2,x+w-10,y+2);
    graph.line(x-3,y+2,x-3,y-h);
        
    //set the y -axis min and max values
    if (smartScale)
    {
        ymax = Collections.max(data1);
        ymin = Collections.min(data1)*10/10;
    }
    else{
        ymax = maxVal;//Collections.max(leftData);
    }

    // draw minimum activation threshold lines
    int leftMatY = y - round(emgManager.getMinimumActivationThreshold(LEFT_DIRECTION_LABEL)*h);
    int rightMatY = y - round(emgManager.getMinimumActivationThreshold(RIGHT_DIRECTION_LABEL)*h);

    graph.strokeWeight(4);

    graph.fill(0,0,255,128);
    graph.stroke(0,0,255,128);
    graph.line(x-3, leftMatY, x+w-10, leftMatY);

    graph.fill(255,0,0,128);
    graph.stroke(255,0,0,128);
    graph.line(x-3, rightMatY, x+w-10, rightMatY);

    graph.strokeWeight(1);

           
    //Count the number of pieces in the array.
    int xcount = data1.size();
    
    //Draw the minimum and maximum Y Axis labels. 
    graph.fill(labelColor);
    graph.textFont(h1);
    
    graph.textAlign(RIGHT, CENTER);
    
    graph.text(ymax+"%", x-8, y-h);
    graph.text(ymin, x-8, y-3);
    
    //Determine the width of the column placeholders on the X axis.
    int xwidth = w / xcount;
    int xStart = x + 13;
  
    //draw and find regions on graph where cocontractions are detected
    //draw line for
    boolean regionStarted = false;
    xStart = x + 13;
    int areaStartX=-1;
    
    for (int i=0; i < lines.size(); i++){
      
      if (lines.get(i) == 1 && !regionStarted)
      {
         areaStartX = xStart-xwidth;
         regionStarted = true;
      }
      
      else if (regionStarted){
        regionStarted = false;
        graph.fill(#F3F315,100);
        graph.noStroke();
        int areaWidth = xStart - areaStartX; 
        graph.rect(areaStartX,y-h,areaWidth,h);
        
      }
      xStart += xwidth;    
    }
    
    if (regionStarted){
      regionStarted = false;
      graph.fill(#F3F315,100);
      int areaWidth = xStart - areaStartX - xwidth;
      graph.rect(areaStartX,y-h,areaWidth,h);
    }
  
  
    //loop for each data series to draw line graph
    for (int g = 0; g < dataGroup.length; g++){
       xStart = x + 13;
      int lastX = -1, lastY = -1;
      
      //Draw each point in the data series.
      for (int i = 0; i < dataGroup[g].size(); i++){
      
          //Get the column value and set it has the height.
          int yHeight = dataGroup[g].get(i);
          
          //Declare the variables to hold column height as scaled to the y axis.     
          float yPCT = 0;
          int scaleHeight = 0;
          
          //calculate the scale of given the height of the chart.
          yPCT = ((yHeight - ymin) *1.0) / ((ymax - ymin)*1.0);
          
          //Calculate the scale y location of the point.
          scaleHeight = h - (int)(h * yPCT);
          
          //If the column height exceeds the chart height than truncate it to the max value possible.
          if (scaleHeight > h)
              scaleHeight = h;
  
          //println(w +" / " + xcount);
            
          //Set the fill color of the line.
          graph.stroke(colors[g]);
          
          //Draw the line.
          if (!(lastX == -1 && lastY==-1)){
            graph.line(xStart-xwidth, y-h+scaleHeight,lastX, lastY); 
            //graph.ellipse(xStart-xwidth, y-h+scaleHeight,3, 3); 
          }
          
          lastX = xStart - xwidth;
          lastY = y-h+scaleHeight;
            
          //println((xStart-xwidth)+", "+ (h-scaleHeight));
                  
          //Draw the labels.
          graph.textFont(l1);
          graph.textAlign(CENTER, CENTER);
          graph.fill(labelColor);
        
          //Decide where the labels will be placed.
          //if (displayValues)
              //Above the columns.
              //text(data.values()[i2], xf1 + (xwidth / 2), yf1 - (ysclhght + 8));
          
          //Below the columns.
          //text(data.keys()[i2], xf1 + (xwidth / 2), yf1 + 8);
              
          //increment the x point at which to draw a column.
          //xf1 = xf1 + xcolumns;
          
          xStart += xwidth;
          //println(xStart);
      }
    }
    
    
    //Reset the draw point the original X value to prevent infinite redrawing to the right of the chart.  
    //xf1 = xfstart;*/
}


public class LimitedSizeQueue<K> extends ArrayList<K> {

    private int maxSize;

    public LimitedSizeQueue(int size){
        this.maxSize = size;
    }

    public int getMaxSize(){
        return this.maxSize; 
    }

    public boolean add(K k){
        boolean r = super.add(k);
        if (size() >= maxSize){
            removeRange(0, size() - maxSize);
        }
        return r;
    }

    public K getYoungest() {
        return get(size() - 1);
    }

    public K getOldest() {
        return get(0);
    }
}