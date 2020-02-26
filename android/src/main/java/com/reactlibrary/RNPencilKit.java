package com.reactlibrary;

import android.content.ContentResolver;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Path;
import android.os.Environment;
import android.view.MotionEvent;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.LifecycleEventListener;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.events.RCTEventEmitter;
import com.facebook.react.views.view.ReactViewGroup;
import android.util.Log;

import java.io.FileOutputStream;
import java.io.File;
import java.util.ArrayList;
import android.provider.MediaStore;

// this is a helper class which keeps track of the different paths, which color they are
// when drawn as well as the thickness. this replaces the lineTo method with a cubic spline
// function which smooths the lines when drawing.
//
// https://stackoverflow.com/questions/8287949/android-how-to-draw-a-smooth-line-following-your-finger
class Drawing extends Path {
    int color;
    float strokeWidth;
    float pX, pY, pDX, pDY;
    public Drawing(int color, float width) {
        super();
        this.color = color;
        this.strokeWidth = width;
    }

    public void moveTo(float x, float y) {
        super.moveTo(x, y);
        pX = x;
        pY = y;
        pDX = 0;
        pDY = 0;
    }

    // cubic spline function
    public void lineTo(float x2, float y2) {
        float dx = ((x2 - pX) / 3.0f);
        float dy = ((y2 - pY) / 3.0f);
        if (pDX == 0) pDX = dx;
        if (pDY == 0) pDY = dy;
        this.cubicTo(pX + pDX, pY + pDY, x2 - dx, y2 - dy, x2, y2);
        pX = x2;
        pY = y2;
        pDX = dx;
        pDY = dy;
    }
}


public class RNPencilKit extends ReactViewGroup implements LifecycleEventListener {

    // setup initial color
    private int paintColor = Color.BLACK;
    private final float WIDTH_PENCIL = 5;
    private final float WIDTH_ERASER = 50;
    private float width = WIDTH_PENCIL;
    private boolean isDarkMode = false;

    // defines paint and canvas
    private Paint drawPaint;

    // stores next circle
    // private Drawing drawing = new Drawing(paintColor, width);
    private ArrayList<Drawing> currents = new ArrayList<Drawing>();
    private ArrayList<Drawing> drawings = new ArrayList<Drawing>();
    private ArrayList<Drawing> scrapped = new ArrayList<Drawing>();

    // tag for debugging
    private final String TAG = "PencilKit";

    public RNPencilKit(ThemedReactContext reactContext) {
        super(reactContext);
        setDrawingCacheEnabled(true);
        setFocusable(true);
        setFocusableInTouchMode(true);
        setupPaint();
        Log.v(TAG, "RNPencilKit setup!");
    }

    private void setupPaint() {
        // Setup paint with color and stroke styles
        drawPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
        drawPaint.setColor(paintColor);
        drawPaint.setAntiAlias(true);
        drawPaint.setStrokeWidth(width);
        drawPaint.setStyle(Paint.Style.STROKE);
        drawPaint.setStrokeJoin(Paint.Join.ROUND);
        drawPaint.setStrokeCap(Paint.Cap.ROUND);
    }

    public void setPaintColor(int color) {
        this.paintColor = color;
        this.width = WIDTH_PENCIL;
        drawPaint.setStrokeWidth(width);
        this.drawPaint.setColor(this.paintColor);
        addDrawings();
    }

    public void setEraserMode() {
        paintColor = Color.WHITE;
        width = WIDTH_ERASER;
        drawPaint.setColor(Color.WHITE);
        drawPaint.setStrokeWidth(width);
        addDrawings();
    }

    public void setDarkMode() {
        setBackgroundColor(Color.BLACK);
        invertAllColors(Color.BLACK, Color.WHITE);
    }

    public void setLightMode() {
        setBackgroundColor(Color.WHITE);
        invertAllColors(Color.WHITE, Color.BLACK);
    }

    public void invertAllColors(int fromColor, int toColor) {
        for (Drawing drawing : drawings)
            if (drawing.color == fromColor)
                drawing.color = toColor;
        for (Drawing drawing : currents)
            if (drawing.color == fromColor)
                drawing.color = toColor;
        for (Drawing drawing : scrapped)
            if (drawing.color == fromColor)
                drawing.color = toColor;
    }

    @Override
    protected void onDraw(Canvas canvas) {
        Log.v(TAG, "on draw!");

        // Iterate through all the previous strokes
        for (Drawing savedDrawing : drawings) {
            draw(canvas, savedDrawing);
        }

        // Draw the current drawing last! (shows up on top)
        for (Drawing activeDrawing: currents) {
            draw(canvas, activeDrawing);
        }

        // Reset the stroke color back to default
        drawPaint.setColor(paintColor);
        drawPaint.setStrokeWidth(width);
    }

    // Helper method to draw the specific drawing
    private void draw(Canvas canvas, Drawing drawing) {
        drawPaint.setStrokeWidth(drawing.strokeWidth);
        drawPaint.setColor(drawing.color);
        canvas.drawPath(drawing, drawPaint);
    }


    // Add the current drawing to the saved array, and then create a new current
    // drawing that can be used during the current touch events.
    private void addDrawings() {
        for (Drawing current: currents) {
            drawings.add(current);
        }
        currents = new ArrayList<Drawing>();
    }

    public void undo() {
        if (drawings.size() > 0) {
            Drawing lastDrawing = drawings.remove(drawings.size() - 1);
            scrapped.add(lastDrawing);
        }
        postInvalidate();
    }

    public void redo() {
        if (scrapped.size() > 0) {
            Drawing lastDrawing = scrapped.remove(scrapped.size() - 1);
            drawings.add(lastDrawing);
        }
        postInvalidate();
    }

    public void save() {
        Log.v(TAG, "Saving image!");
        try {

            // create a new file called drawing_123123809123.jpeg
            File file = new File(Environment.getExternalStoragePublicDirectory(
                    Environment.DIRECTORY_PICTURES
            ), "drawing_"+System.currentTimeMillis()+".jpeg");

            // create the file stream and load the bitmap data
            FileOutputStream stream = new FileOutputStream(file);
            Bitmap b = this.getDrawingCache();
            b.compress(Bitmap.CompressFormat.JPEG, 100, stream);
            stream.flush();
            stream.close();

            // then we need to expose the saved image to the users photo gallery
            ContentResolver resolver = getContext().getApplicationContext().getContentResolver();
            MediaStore.Images.Media.insertImage(resolver, file.getAbsolutePath(), file.getName(), file.getName());

            // send the data back to javascript
            onSaveEvent(file.getAbsolutePath());
        }
        catch(Exception e) {
            Log.e(TAG, "Save failed: " + e.toString());
            e.printStackTrace();
        }
    }

    private void onSaveEvent(String path) {
        WritableMap map = Arguments.createMap();
        map.putString("uri", path);
        final ReactContext context = (ReactContext)getContext();
        context.getJSModule(RCTEventEmitter.class).receiveEvent(
                getId(),
                "onSaveEvent",
                map
        );
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {

        Log.v(TAG, "on touch event...");

        // the number of all motion events on touch
        final int pointerCount = event.getPointerCount();

        // iterate through all of the pointer events
        for (int p = 0; p < pointerCount; p++) {

            // use the pointer id as the corresponding index in currents
            // and load the x and y coordinates for that point
            int id = event.getPointerId(p);
            float x = event.getX(p);
            float y = event.getY(p);

            // load the current drawing at the index for that events id or
            // initialize a new element there with the point (x,y)
            Drawing drawing = getCurrentDrawing(id, x, y);

            // Checks for the event that occurs, the action down event here might be
            // unnecessary, then action move will draw a line to, and finally when on
            // action up we add all currents to the drawing array.
            switch (event.getAction()) {
                case MotionEvent.ACTION_DOWN:
                    drawing.moveTo(x, y);
                    return true;
                case MotionEvent.ACTION_MOVE:
                    drawing.lineTo(x, y);
                    break;
                case MotionEvent.ACTION_UP:
                    addDrawings();
                    return true;
                default:
                    return false;
            }
        }

        // re-draw the view
        postInvalidate();
        return true;
    }

    // load the current drawing at the index for that events id or
    // initialize a new element there with that point, since multi-touch
    // events don't trigger the ACTION_DOWN, we need move_to there when we add.
    private Drawing getCurrentDrawing(int id, float x, float y) {
        if (id < currents.size()) return currents.get(id);
        Drawing drawing = new Drawing(paintColor, width);
        drawing.moveTo(x, y);
        currents.add(drawing);
        return drawing;
    }

    @Override
    public void onHostResume() {
        // do nothing
    }

    @Override
    public void onHostPause() {
        // do nothing
    }

    @Override
    public void onHostDestroy() {
        // do nothing
    }
}
