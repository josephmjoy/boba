class TrackSpan {
  public int id;
  public int start;
  public int end;

  public String toString() {
    return "(" + id +", " + start + ", " + end + ")";
  }
}

class VizUtils {

  public int[][] readRawTracks(String path) {
    //String[] rows = loadStrings(path);
    //println("rows: "  + rows.length);
    Table t = loadTable(path);
    if (t!=null) {
      println(t.getRowCount() + " total rows in table");
    }
    int nRows= t.getRowCount();
    int[][] tracks = new int[nRows][0];
    int i=0;
    for (TableRow row : t.rows()) {
      int[] aRow = new int[5];
      for (int j=0; j<aRow.length; j++) {
        aRow[j] = row.getInt(j);
      }
      tracks[i] = aRow;
      i++;
    }
    return tracks;
  }

  public ArrayList<TrackSpan> genSpans(int[][] rawTracks) {
    int prevTrack = -1;
    ArrayList<TrackSpan> spans = new ArrayList<TrackSpan>();
    TrackSpan curTs=null;
    int gapCount = 0; // Number of gaps found *within* tracks while processing the data.
    int maxGap  = 0; // Widest gap.
    for (int[] row : rawTracks) {
      int curTrack = row[0];
      if (curTrack!=prevTrack) {
        if (curTs!=null) {
          spans.add(curTs);
        }
        // New track
        prevTrack = curTrack;
        TrackSpan ts = new TrackSpan();
        ts.id = curTrack;
        ts.start  = row[4]; // 5th element is the frame count.
        ts.end=ts.start;
        curTs = ts;
      } else {
        // Continuing existing track.
        int d = row[4] - curTs.end;
        assert(d>0);
        if (d>1) {
          // Expect consecutive frames? 
          //println("GAP! id: " + curTs.id + ", frames: " + curTs.end + " - " + row[4]);
          gapCount++;
          maxGap = max(maxGap, d-1);
        }
        curTs.end = row[4]; // Update end
      }
    }
    println("nGaps: " + gapCount + ", maxGap: " + maxGap);
    // Add final track
    if (curTs!=null) {
      spans.add(curTs);
    }
    return  spans;
  }


  public String getStats(ArrayList<TrackSpan> spans) {
    int sum=0;
    int nIds = spans.size();
    int minSpan  = MAX_INT;
    int maxSpan = 0;
    for (TrackSpan ts : spans) {
      int len = ts.end-ts.start;
      assert(len>=0);
      sum += len;
      minSpan = min(minSpan, len);
      maxSpan = max(maxSpan, len);
      //println(ts);
    }
    if (nIds>0) {
      return "nIDs: " + nIds + ", avgSpan: " + sum/nIds+ ", minSpan: " + minSpan + ", maxSpan: " + maxSpan;
    } else {
      return "No data.";
    }
  }

  void visualize(ArrayList<TrackSpan> spans, PGraphics pg) {
    final int WEIGHT = displayAll ? 2 : 2; // We want  track thinner when displaying all
    final float SCALE_X =  displayAll ? 0.25 : 0.25; // We want tracks shorter when displayin all.
    final int BASE_X = 4;
    final int BASE_Y = 0;
    pg.background(0);
    
    // Dim border to visually check  tracks get truncated at image boundaries.
    pg.strokeWeight(10);
    pg.stroke(100, 0, 0);
    pg.noFill();
    pg.rect(0, 0, SIZE_X, SIZE_Y);
    
    pg.stroke(255);
    pg.strokeWeight(WEIGHT);
    //pg.line(0, 0, SIZE_X, SIZE_Y);
    int tracksVisualized = 0;
    for (TrackSpan ts : spans) {
      float x1 = BASE_X + SCALE_X*ts.start;
      float x2 = BASE_X + SCALE_X*ts.end;
      int y = BASE_Y + (WEIGHT+1)*ts.id;
      if (x1 < SIZE_X && y < SIZE_Y) {
        pg.line (x1, y, x2, y); 
        //println(ts);
        tracksVisualized++;
      }
    }
    println("tracks visualized: " + tracksVisualized);
  }
}