/*************************************************
 File: Project 2.5
 By: Jonathan Raxa
 Date: Friday, March 13th, 2015
 Compile: Compile via Processing IDE with Android device hooked in
 Usage: Run via Processing by clicking play arrow
 System: Mac OSX
 Description: Application saves tags
 *************************************************/

import android.content.res.AssetManager;

// add from whsu for soundPool
import android.media.SoundPool; //this is the audio player for short quick audio files
import android.content.res.AssetManager; //the asset manager helps us find specific files and can be used in the style of an array if needed
import android.media.AudioManager; //the audio manager controlls all the audio connected to it, enabeling overall volume and such
import apwidgets.*; 

// added from whsu for textEdit
import android.text.InputType;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputMethodManager;
import android.content.Context;

// added from whsu for TextFileExternal
import java.util.Arrays;
import java.io.*;
import android.os.Environment;

// added - container and two buttons
APWidgetContainer widgetContainer; 
APButton button1;
APButton button2;

// textField object
APEditText textField;

boolean isVisible = false;

// added arrayList for listing saved elements
ArrayList<String> s;

// adding sound stuff
SoundPool soundPool;
AssetManager assetManager;

int sound1; 
int soundLeft; 
int soundRight; 
int sound4; 
int sound5; 

// initialize int values
int mode = 0; // 0 for thumbnails; 1 for selected image 
int left_most = 0; 
int theWidth;
int theHeight;
int currentImg;
int totalFrames;
int leftMost; 
int section; 
int posX; 

float thumbHeight;
float thumbWidth;
float thumbRatio;
float velX = 0;

// initialize images
PImage arrowR; 
PImage arrowL;
PImage[] images;


int[] currentThumbnails = {
  0, 1, 2, 3, 4
};


void setup() {
  orientation(LANDSCAPE);
  // left and right arrows 
  arrowR = loadImage("right.png"); 
  arrowL = loadImage("left.png");

  //textField.setImeOptions(EditorInfo.IME_FLAG_NO_EXTRACT_UI);

  section = displayWidth/5;
  leftMost = 0; 
  currentImg = 0; 

  loadImgs();
  soundSetup();
  widgetSetup();
  textSize(50);
} // end setup()

void loadText() {
  if (mode == 1) {
    File sketchDir = getFilesDir();
    // read strings from file into s
    try {
      String lines[] = loadStrings(sketchDir.getAbsolutePath() + "/inFile" + currentImg + ".txt");
      for (int i = 0; i < lines.length; i++) {
        text(lines[i], 50, 50);
      }
    }
    catch (Exception e) {
    }
  }
}

// sets up the sound environment
void soundSetup() {
  // (max #of streams, stream type, source quality) - see the android reference for details
  soundPool = new SoundPool(20, AudioManager.STREAM_MUSIC, 0);
  assetManager = this.getAssets();
  try { 
    // load files
    sound1 = soundPool.load(assetManager.openFd("hit.wav"), 0); 
    soundRight = soundPool.load(assetManager.openFd("kick1.wav"), 0); 
    soundLeft = soundPool.load(assetManager.openFd("kick2.wav"), 0); 
    sound4 = soundPool.load(assetManager.openFd("snare.wav"), 0);
    sound5 = soundPool.load(assetManager.openFd("wah.wav"), 0);
  } 
  catch (IOException e) {
    e.printStackTrace();
  }
}

void saveToFile() {
  File sketchDir = getFilesDir();
  java.io.File outFile;
  try {
    println("Saved to: " + sketchDir.getAbsolutePath());
    outFile = new java.io.File(sketchDir.getAbsolutePath() + "/inFile" + currentImg + ".txt");
    if (!outFile.exists())
      outFile.createNewFile();
    FileWriter outWriter = new FileWriter(sketchDir.getAbsolutePath() + "/inFile" + currentImg + ".txt", true);

    if (outFile.length() == 0) {
      outWriter.append(textField.getText());
    } else {
      outWriter.append(", " + textField.getText());
    } 

    outWriter.flush();
  }
  catch (Exception e) {
    textSize(40);
    text("File not found", width/4, 50);
  }
}


File getSketchDir() {
  File extDir = Environment.getExternalStorageDirectory();
  String sketchName = this.getClass().getSimpleName();
  return new File(extDir, sketchName);
}


// added - new setup for widget
void widgetSetup() {

  widgetContainer = new APWidgetContainer(this); //create new container for widgets
  button1 = new APButton( displayWidth - 160, 150, 400, 100, "save"); //create new button from x- and y-pos. and label. size determined by text content
  button2 = new APButton( displayWidth - 160, 260, 400, 100, "cancel"); //create new button from x- and y-pos., width, height and label
  widgetContainer.addWidget(button1); //place button in container
  widgetContainer.addWidget(button2); //place button in container

  // text edit widget

  textField = new APEditText( displayWidth-300, 20, // top right corner at (0, 50)
  width/2, 100 );     // width = width/2, height = 100
  widgetContainer.addWidget(textField); //place textField in container
  widgetContainer.hide();
  textField.setTextSize(30);
  println("size: " + textField.getTextSize());
}


////onClickWidget is called when a widget is clicked/touched
void onClickWidget(APWidget widget) {
  if (mode == 1) {
    // we're going to change this to save and read sooner or later
    if (widget == button1) { //if it was button1 that was clicked
      saveToFile();
    } else if (widget == button2) { //or if it was button2
      hideVirtualKeyboard();
    }
  }
}

void loadImgs() {
  String [] fileNames; 
  fileNames = new String[2];
  AssetManager am = getAssets();
  // load the files from Image folder 
  try {
    fileNames = am.list("Images");  // am - returns array of file names
    totalFrames = fileNames.length;
    images = new PImage[totalFrames];
  } 
  catch (IOException e) {
    print("Error, cannot find image!"); 
    return;
  }


  // loads the entire collection of images into an array
  for (int k = 0; k < fileNames.length; k++) {
    if (fileNames.length >= 1 && fileNames[k].endsWith(".png")) {
      images[k] = loadImage("Images/" + fileNames[k]);
      images[k].loadPixels();
    }
  }
  println("# of images: " + totalFrames);
}


void draw() {

  background(0);                                              // background color = white
  image(arrowR, displayWidth-100, displayHeight-100, 200, 200); // left arrow
  image(arrowL, 100, displayHeight-100, 200, 200);              // right arrow
  imageMode(CENTER); 
  displayImage();

  loadText();
} // end draw()


void mousePressed() {

  // STATIC ARROWS
  image(arrowR, displayWidth-100, displayHeight-100, 200, 200); // left arrow
  image(arrowL, 100, displayHeight-100, 200, 200);              // right arrow

  if (mode == 0) {
    modeZero();
  } else if (mode == 1) {
    modeOne();
  }
}


// boilder plate code to show and hide virtual keyboard on click 
void showVirtualKeyboard() {
  InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
  imm.toggleSoftInput(InputMethodManager.SHOW_FORCED, 0);
}

void hideVirtualKeyboard() {
  InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
  imm.toggleSoftInput(InputMethodManager.HIDE_IMPLICIT_ONLY, 0);
}


// List of images mode
void modeZero() {

  // if the right arrow is clicked
  if ((mouseX <= displayWidth ) && (mouseX >= displayWidth-200) &&
    (mouseY >=  displayHeight-200)) {


    println("right");
    soundPool.play(sound5, 1, 1, 0, 0, 1);

    velX = 250;     
    leftMost = leftMost + 5;
    currentImg += 5;

    if (leftMost > images.length - 1) {
      leftMost = leftMost - images.length;
    }
    if (currentImg > images.length - 1) {
      currentImg = currentImg - images.length;
    }

    // if the left arrow is clicked
  } else if ((mouseX <= 200) && (mouseX >= 0) && (mouseY >= displayHeight-200)) { // left arrow

    print("left");
    soundPool.play(sound5, 1, 1, 0, 0, 1);

    velX = -250; 

    leftMost = leftMost - 5;
    currentImg -= 5;

    if (leftMost < 0) {
      leftMost = images.length + leftMost;
    }
    if (currentImg < 0) {
      currentImg = images.length + currentImg;
    }
  }


  // if the images are in the middle
  if ((mouseY > (displayHeight/2-100)) && (mouseY < (displayHeight/2+100))) {
    currentImg = leftMost; 

    if (mouseX > 0 && mouseX < section) {
      mode = 1;

      widgetContainer.show();

      println("section 1");
      // plays the sound  
      soundPool.play(sound1, 2, 2, 0, 0, 1);
    } else if ( mouseX > section && mouseX < section*2 ) {
      currentImg = currentImg + 1;
      if (currentImg > images.length - 1) {
        currentImg = currentImg - images.length;
      }
      mode = 1;
      widgetContainer.show();

      println("section 2");
      // plays the sound  
      soundPool.play(sound1, 2, 2, 0, 0, 1);
    } else if ( mouseX > section*2 && mouseX < section*3 ) {
      currentImg = currentImg + 2;
      if (currentImg > images.length - 1) {
        currentImg = currentImg - images.length;
      }
      mode = 1;
      widgetContainer.show();

      println("section 3");
      // plays the sound  
      soundPool.play(sound1, 2, 2, 0, 0, 1);
    } else if ( mouseX > section*3 && mouseX < section*4 ) {
      currentImg = currentImg + 3;
      if (currentImg > images.length - 1) {
        currentImg = currentImg - images.length;
      }
      mode = 1;
      widgetContainer.show();

      println("section 4");
      // plays the sound  
      soundPool.play(sound1, 2, 2, 0, 0, 1);
    } else if ( mouseX > section*4 && mouseX < section*5 ) {
      currentImg = currentImg + 4; 
      if (currentImg > images.length - 1) {
        currentImg = currentImg - images.length;
      }
      mode = 1; 
      widgetContainer.show();

      println("section 5");
      // plays the sound  
      soundPool.play(sound1, 2, 2, 0, 0, 1);
    }
  }
} // end modeZero




// single image mode
void modeOne() {
  if (mode == 1)

    if (((mouseX < 200) && (mouseY > 530))) {
      print("left");
      soundPool.play(soundLeft, 1, 1, 0, 0, 1);
      currentImg--;
      velX = -50;

      if ( currentImg < 0 ) {
        currentImg = totalFrames - 1;
      }
      println("current image: " + currentImg);
    } else if ((mouseX > 1070) && (mouseY > 530)) {
      print("right"); 
      soundPool.play(soundRight, 1, 1, 0, 0, 1);

      currentImg++;
      velX = 50;
      if (currentImg > totalFrames - 1) {
        currentImg = 0;
      }
      println("current image: " + currentImg);
    }

  // user clicks on current image in MODE 1
  float posW = (width - thumbWidth) / 2;
  float posH = (height - thumbHeight) / 2;
  if ( (mouseX >= posW) && (mouseX < (width - posW)) &&
    (mouseY >= posH) && (mouseY < (height - posH))) {


    widgetContainer.hide();
    hideVirtualKeyboard();

    mode = 0; 
    leftMost = currentImg - 2; 
    println(currentImg); 
    soundPool.play(sound4, 1, 1, 0, 0, 1);

    if (leftMost < 2) {
      if ( currentImg == 0) {
        leftMost = images.length - 2;
      } else if (currentImg == 1) {
        leftMost = images.length - 1;
      }
    }
  }
}


void displayImage() {

  // displays images as concrete thumbnails
  if (mode == 0) {

    int[] thumbnail = new int[5];

    imageMode(CENTER);

    if (leftMost >= 0 && leftMost <= images.length-5) {
      for (int i = 0; i < 5; i++) {
        thumbnail[i] = leftMost + i;
      }

      drawModeZero(thumbnail);
    } else if (leftMost==images.length-4) {
      for (int i = 0; i < 4; i++) {
        thumbnail[i] = leftMost + i;
      } 
      thumbnail[4] = 0;
      drawModeZero(thumbnail);
    } else if (leftMost==images.length-3) {
      for (int i = 0; i < 3; i++) {
        thumbnail[i] = leftMost + i;
      }
      thumbnail[3] = 0;
      thumbnail[4] = 1;
      drawModeZero(thumbnail);
    } else if (leftMost==images.length-2) {
      for (int i = 0; i < 2; i++) {
        thumbnail[i] = leftMost + i;
      }
      thumbnail[2] = 0;
      thumbnail[3] = 1;
      thumbnail[4] = 2;
      drawModeZero(thumbnail);
    } else if (leftMost==images.length-1 || leftMost == -1) {
      leftMost = images.length - 1;
      thumbnail[0] = leftMost;
      for (int i = 0; i < 4; i++) {
        thumbnail[i+1] = i;
      }
      drawModeZero(thumbnail);
    }
    if (velX > 0) {
      velX -=10;
    } else if (velX < 0) {
      velX +=10;
    } else {
      currentThumbnails = thumbnail;
    }
  } else if (mode == 1) {

    thumbRatio = width/height;
    int direction;//direction of leftmost of current images
    if (velX > 0) { //if shifting right
      direction = -1;
    } else if (velX < 0) { //if shifting left
      direction = 1;
    } else {
      direction = 0;
    }

    int original = currentImg + direction;//Original image
    if (original > images.length-1) {
      original = 0;
    } else if (original < 0) {
      original = images.length-1;
    }

    resizeImage(images[original]);
    imageMode(CENTER);
    image(images[original], ((direction + velX/50) * width)+(width/2), height/2, thumbWidth, thumbHeight);   


    resizeImage(images[currentImg]);
    imageMode(CENTER);
    image(images[currentImg], ((velX/50) * width)+(width/2), height/2, thumbWidth, thumbHeight);     

    if (velX > 0) {
      velX -= 2;
    } else if (velX < 0) {
      velX += 2;
    }
  }
}

void drawModeZero(int[] thumbnail) {
  int direction;
  if ((mouseX <= displayWidth ) && (mouseX >= displayWidth-200) && (mouseY >=  displayHeight-200)) {
    direction = -5;
  } else {
    direction = 5;
  }

  for (int i = 0; i < 5; i++) {
    resizeImage(images[currentThumbnails[i]]);

    image(images[currentThumbnails[i]], ((direction + (velX/50)) * (width/5)) + ((width/5)/2), height/2, thumbWidth, thumbHeight);
    direction++; 

    resizeImage(images[thumbnail[i]]);

    image(images[thumbnail[i]], ((i + (velX/50)) * (width/5)) + ((width/5)/2), height/2, thumbWidth, thumbHeight);
  }
}


// resizes each image when called on
void resizeImage(PImage image) {
  float imageHeight = image.height;
  float imageWidth = image.width;
  float imageRatio = imageWidth/imageHeight;

  if (mode == 1) {
    if (thumbRatio > imageRatio) {
      thumbHeight = height-100;
      thumbWidth = (height) * imageRatio;
    } else if (thumbRatio < imageRatio) {
      thumbHeight = (width - 600) * (1/imageRatio);
      thumbWidth = width - 600;
    } else {
      thumbHeight = height - 100;
      thumbWidth = width/2;
    }
  } else if (mode == 0) {
    if (thumbRatio > imageRatio) {
      thumbHeight = (height/4) - (50/2);
      thumbWidth = (((height/4) - (50/2)) * imageRatio);
    } else if (thumbRatio < imageRatio) {
      thumbHeight = ((width/5) * (1/imageRatio));
      thumbWidth = ((width/5) - (50/2));
    } else {
      thumbHeight = ((width/5) - (50/2));
      thumbWidth = ((width/5) - (50/2));
    }
  }
}

