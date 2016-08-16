VizUtils gUtils = new VizUtils();
final String BASE_PATH = "G:\\KUMBH\\Projects\\rw\\NIH";
int i=0;
boolean displayAll = false;
final int SIZE_X  = displayAll? 13000 : 2000;// 13000;
final int SIZE_Y = displayAll ? 22000 : 4000;
final int START_ID = 1;
//PGraphics pg = createGraphics(SIZE_X, SIZE_Y);

void settings() {
  size(1000, 2000);
}

void setup() {
  //String fileName = "\\ID_X_Y_Z_sample.tsv";
  String fileName = "\\ID_X_Y_Z_frames1_51812-aug12.tsv";
  int[][] rawTracks = gUtils.readRawTracks(BASE_PATH+fileName);
  ArrayList<TrackSpan>spans = gUtils.genSpans(rawTracks);
  String stats = gUtils.getStats(spans);
  println("Stats: " + stats);
  Boolean visualize = false;
  if (visualize) {
    PGraphics pg = createGraphics(SIZE_X, SIZE_Y);
    pg.beginDraw();
    gUtils.visualize(spans, pg);
    String date = day() + "/" + month() + "/" + year();
    String label = displayAll ? "" : "[TRUNCATED - SHOWING UPPER CORNER ONLY]\n";
    label += "file: " + fileName.substring(1) + ", date: " + date +  "\n" + stats;
    int textSize = (int) (15*min(SIZE_X,SIZE_Y)/1000);
    pg.textSize( textSize );
    pg.fill(255);
    pg.text(label, 400+ 5*textSize, 2*textSize);
    pg.endDraw();
    image(pg, 0, 0);
    String outFile = displayAll? "outFull.png" : "outTruncated.png";
    pg.save(outFile);
  }
}