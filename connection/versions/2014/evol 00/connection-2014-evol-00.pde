int TEXT_SIZE; // define text size (height)
int CONNECTOBJ_TEXT_SPACE; // define the space between the box borders and the text inside connection objects
int CONNECTION_SPACE; // define the connection plug spaces

button addobj, editobj, conobj; // the buttons - add, edit and connect
boolean isedit, iscon; // are we in edit mode? are we in connect mode?
int editind; // which obj are we editing? (changing the name :P)
int con0, con1; // which two objs are we connecting?
boolean contd0, contd1; // are both of them below

PFont font; // use to set font

ArrayList<ConnectObj> connectobjs; // connection objects
int cind; // the current index for connection objects, to be assigned to the lately created ones then ++

ArrayList<ConnectInfo> coninfos; // connection infos. lines are drawn according to connection infos.

void config() {
  TEXT_SIZE = 16;
  CONNECTOBJ_TEXT_SPACE = 5;
  CONNECTION_SPACE = 5;
}

void setupButtons() { // setup the buttons
  addobj = new button(20, 20, 50, 50, "add");
  editobj = new button(90, 20, 50, 50, "edit");
  conobj = new button(160, 20, 50, 50, "con");
}

void keepDrag() { // call the keepDrag function for all the connection objects, possible improvement
  for (int i = 0; i < connectobjs.size(); i++) {
    connectobjs.get(i).keepDrag();
  }
}

void setup() {
  config(); // config the capital variables
  setupButtons(); // setup buttons

  size(800, 600); // size of the window
  font = createFont("Ubuntu Mono", TEXT_SIZE, true); // set the font for ubuntu users
  // textSize(TEXT_SIZE);
  textFont(font, TEXT_SIZE); // set the font to default text
  
  isedit = false; // by default we aren't in edit mode
  editind = -1; // so the edited index is -1
  
  iscon = false; // and we aren't in connection mode either
  con0 = -1; // so the first connection index is -1
  con1 = -1; // the second as well
  
  connectobjs = new ArrayList<ConnectObj>(); // init
  cind = 0; // the first index is 0
  
  coninfos = new ArrayList<ConnectInfo>(); // init
}

void draw() {
  keepDrag(); // calling keepDrags

  background(255); // refresh canvas
  
  // drawing the buttons
  addobj.draw();
  editobj.draw();
  conobj.draw();
  
  // drawing the connection objects
  for (int i = 0; i < connectobjs.size(); i++) {
    connectobjs.get(i).draw();
  }
  
  // drawing the connections
  stroke(0);
  for (int i = 0; i < coninfos.size(); i++) {
    // ucon or dcon? (up-connected or down-connected)
    line(
    connectobjs.get(coninfos.get(i).con0).x + (connectobjs.get(coninfos.get(i).con1).x > connectobjs.get(coninfos.get(i).con0).x + textWidth(connectobjs.get(coninfos.get(i).con0).val) / 2 ? CONNECTOBJ_TEXT_SPACE + textWidth(connectobjs.get(coninfos.get(i).con0).val) : -CONNECTOBJ_TEXT_SPACE),
    connectobjs.get(coninfos.get(i).con0).y + (coninfos.get(i).contd0 ? CONNECTOBJ_TEXT_SPACE + TEXT_SIZE : -CONNECTOBJ_TEXT_SPACE),
    connectobjs.get(coninfos.get(i).con1).x + (connectobjs.get(coninfos.get(i).con0).x > connectobjs.get(coninfos.get(i).con1).x + textWidth(connectobjs.get(coninfos.get(i).con1).val) / 2 ? CONNECTOBJ_TEXT_SPACE + textWidth(connectobjs.get(coninfos.get(i).con1).val) : -CONNECTOBJ_TEXT_SPACE),
    connectobjs.get(coninfos.get(i).con1).y + (coninfos.get(i).contd1 ? CONNECTOBJ_TEXT_SPACE + TEXT_SIZE : -CONNECTOBJ_TEXT_SPACE)
    );
  }
}

void mousePressed() {
  if (addobj.inside(mouseX, mouseY)) { // if addobj was pressed
    // add a new connection object
    ConnectObj add = new ConnectObj(300, 300, "something", cind++);
    connectobjs.add(add);
  } else if (editobj.inside(mouseX, mouseY)) { // if editobj was pressed
    isedit = !isedit; // toggle edit mode
    editobj.active = isedit; // toggle activation of the editobj button
    if (isedit) { // if edit mode is now on
      iscon = false; 
      conobj.active = false; // turn connection mode off
    } else { // if edit mode is now off
      if (editind != -1) { // if editind hasn't returned to -1
        connectobjs.get(editind).active = false; // deactivate the active connection object
        editind = -1; // setting back to default
      }
    }
  } else if (conobj.inside(mouseX, mouseY)) { // if conobj was pressed
    iscon = !iscon; // toggle connection mode
    conobj.active = iscon; // is the button active?
    if (iscon) { // if connection mode is now on
      isedit = false; 
      editobj.active = false; // turn edit mode off
    } else { // if connection mode is now off
      if (con0 != -1 && con1 != -1) { // connection succeeded! both assigned values other than -1
        if (contd0 != contd1) { // one has to be ucon, and the other has to be dcon
          if (contd0) { // if the con0 connection obj was dcon
            connectobjs.get(con0).dcon(con1); // dcon con0 to con1
            connectobjs.get(con1).ucon(con0); // ucon con1 to con0
          } else {
            connectobjs.get(con0).ucon(con1); // ucon con0 to con1
            connectobjs.get(con1).dcon(con0); // dcon con1 to con0
          }
          coninfos.add(new ConnectInfo(con0, con1, contd0, contd1, true)); // add the connection info for drawing lines!
        }
        
        // deactivate them
        connectobjs.get(con0).active = false;
        connectobjs.get(con1).active = false;
      }
      
      // revert them back to default -1
      con0 = -1;
      con1 = -1;
    }
  } else {
    boolean set = false; // after the for loop, to test if the coind was set or not (if not set then the user clicked on the blank space)
    int prevind = -1; // the index of the previously assigned clicked object, to compare with another object clicked
    int coind = -1; // the selected object
    for (int i = 0; i < connectobjs.size(); i++) {
      if (connectobjs.get(i).inside(mouseX, mouseY)) { // is it clicked?
        if (connectobjs.get(i).ind > prevind) { // if it's forward
          set = true; // now set
          coind = i; // set coind
          prevind = connectobjs.get(i).ind; // set prevind
          
          if (iscon) { // if we are in connection mode
            if (con0 == -1) { // if con0 isn't set yet
              contd0 = connectobjs.get(i).tdinside(mouseX, mouseY); // is con0 clicked on bottom half?
            } else if (con1 == -1) { // if con1 isn't set yet instead, notice i didn't use "else" but "else if" instead
              contd1 = connectobjs.get(i).tdinside(mouseX, mouseY); // is con1 clicked on bottom half?
            }
          }
        }
      }
    }
    
    if (set) { // if something was actually set
      if (isedit) { // if edit mode on
        if (editind != -1) { // if editind is set
          connectobjs.get(editind).active = false; // deactivate the current object in focus
        }
        editind = coind; // set it
        connectobjs.get(editind).active = true; // activate clicked connection object
      } else if (iscon) { // if connection mode on
        if (con0 == -1) { // if con0 is not set
          con0 = coind; // set con0
          connectobjs.get(con0).active = true; // activate
        } else if (con1 == -1) { // if con1 is not set
          con1 = coind; // set con1
          connectobjs.get(con1).active = true; // activate
        }
      } else { // no button pressed
        connectobjs.get(coind).startDrag(); // just startDrag
      }
    } else { // if the user clicked in the blank space
      if (isedit) { // if edit mode on
        if (editind != -1) { // if editind is set
          connectobjs.get(editind).active = false; // deactivate
          editind = -1; // reset default
        }
      } else if (iscon) { // if connection mode on
        /*
        con0 = -1; // reset default
        con1 = -1; // reset default
        */
      }
    }
  }
}

void mouseReleased() {
  // stopDrag for all anyway
  for (int i = 0; i < connectobjs.size(); i++) {
    connectobjs.get(i).stopDrag();
  }
}

void keyPressed() {
  if (isedit && editind != -1) { // if edit mode on AND something is selected
    if (key != CODED) { // if the key isn't CODED
      if (keyCode == BACKSPACE) { // if it's backspace
        if (connectobjs.get(editind).val.length() > 0) { // if the string is not empty
          connectobjs.get(editind).val = connectobjs.get(editind).val.substring(0, connectobjs.get(editind).val.length() - 1); // kick the last letter off
        }
      } else { // if it's just a regular char
        connectobjs.get(editind).val = connectobjs.get(editind).val.concat(str(key)); // add it
      }
    }
  }
}

class ConnectObj {
  int x, y;
  String val;
  int ind;

  // for dragging
  int dx, dy;
  boolean dragged;
  
  // is edited?
  boolean active;
  
  // connected
  int tucons, tdcons;
  IntList ucons, dcons;

  ConnectObj(int cx, int cy, String cval, int cind) {
    x = cx;
    y = cy;
    val = cval;
    ind = cind;
    active = false;
    tucons = 0;
    tdcons = 0;
    ucons = new IntList();
    dcons = new IntList();
  }
  
  void ucon(int i) {
    ucons.append(i);
  }
  
  void dcon(int i) {
    dcons.append(i);
  }
  
  boolean inside(int tx, int ty) {
    return (tx > x - CONNECTOBJ_TEXT_SPACE) && (tx < x + textWidth(val) + CONNECTOBJ_TEXT_SPACE) && (ty > y - CONNECTOBJ_TEXT_SPACE) && (ty < y + TEXT_SIZE + CONNECTOBJ_TEXT_SPACE);
  }
  
  boolean tdinside(int tx, int ty) {
    return (tx > x - CONNECTOBJ_TEXT_SPACE) && (tx < x + textWidth(val) + CONNECTOBJ_TEXT_SPACE) && (ty > y + TEXT_SIZE / 2) && (ty < y + TEXT_SIZE + CONNECTOBJ_TEXT_SPACE);
  }

  void draw() {
    stroke((active ? 255 : 0), 0, 0);
    fill(255);
    rect(x - CONNECTOBJ_TEXT_SPACE, y - CONNECTOBJ_TEXT_SPACE, textWidth(val) + CONNECTOBJ_TEXT_SPACE * 2, TEXT_SIZE + CONNECTOBJ_TEXT_SPACE * 2);
    fill(0);
    text(val, x, y + TEXT_SIZE);
    rect(x - CONNECTOBJ_TEXT_SPACE, y - CONNECTOBJ_TEXT_SPACE - CONNECTION_SPACE, textWidth(val) + CONNECTOBJ_TEXT_SPACE * 2, CONNECTION_SPACE);
    rect(x - CONNECTOBJ_TEXT_SPACE, y + TEXT_SIZE + CONNECTOBJ_TEXT_SPACE, textWidth(val) + CONNECTOBJ_TEXT_SPACE * 2, CONNECTION_SPACE);
  }

  void startDrag() {
    if (!dragged) {
      dx = mouseX - x;
      dy = mouseY - y;
      dragged = true;
    }
  }

  void keepDrag() {
    if (dragged) {
      x = mouseX - dx;
      y = mouseY - dy;
    }
  }

  void stopDrag() {
    dragged = false;
  }
}

class ConnectInfo {
  int con0, con1;
  boolean contd0, contd1;
  boolean curve;
  
  ConnectInfo(int cc0, int cc1, boolean ctdc0, boolean ctdc1, boolean ccurve) {
    con0 = cc0;
    con1 = cc1;
    contd0 = ctdc0;
    contd1 = ctdc1;
    curve = ccurve;
  }
};

class button {
  int x, y, w, h;
  String label;
  
  boolean active;

  button(int cx, int cy, int cw, int ch, String cl) {
    x = cx;
    y = cy;
    w = cw;
    h = ch;
    label = cl;
    active = false;
  }

  void draw() {
    stroke(0);
    fill(active ? 128 : 0);
    rect(x, y, w, h);
    fill(255);
    text(label, x + w / 2 - textWidth(label) / 2, y + h / 2 + TEXT_SIZE / 2);
  }

  Boolean inside(int tx, int ty) {
    return (tx > x) && (tx < x + w) && (ty > y) && (ty < y + h);
  }
}

