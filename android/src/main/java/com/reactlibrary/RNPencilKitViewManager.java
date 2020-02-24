package com.reactLibrary.RNPencilKit;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ViewGroupManager;
import com.facebook.react.uimanager.annotations.ReactProp;

import android.annotation.SuppressLint;
import android.view.View;
import javax.annotation.Nullable;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.common.MapBuilder;
import java.util.HashMap;
import java.util.Map;
import android.util.Log;
import android.view.ViewGroup;


public class RNPencilKitViewManager extends ViewGroupManager<RNPencilKit> {

    public static final String REACT_CLASS = "RCTPencilKitView";

    // The commands for the pencil kit
    private static final int COMMAND_UNDO = 1;
    private static final int COMMAND_REDO = 2;
    private static final int COMMAND_ERASE = 3;
    private static final int COMMAND_SAVE = 4;

    @Override
    public String getName() {
        return REACT_CLASS;
    }

    @Override
    public RNPencilKit createViewInstance(ThemedReactContext context) {
        return new RNPencilKit(context);
    }

    @ReactProp(name = "color")
    public void setPaintColor(RNPencilKit pencilKit, int color) {
        pencilKit.setPaintColor(color);

    }

    @Override
    public void receiveCommand(RNPencilKit pencilKit, int commandId, @Nullable ReadableArray arg) {
        Log.v(REACT_CLASS, "receive command: " + commandId);
        switch (commandId) {
            case COMMAND_UNDO:
                pencilKit.undo();
                return;
            case COMMAND_REDO:
                pencilKit.redo();
                return;
            case COMMAND_ERASE:
                pencilKit.setEraserMode();
                return;
            case COMMAND_SAVE:
                pencilKit.save();
                return;
        }
    }

    @Override
    public @Nullable Map<String, Integer> getCommandsMap() {
        Map<String, Integer> map = MapBuilder.of();
        map.put("redo", COMMAND_REDO);
        map.put("undo", COMMAND_UNDO);
        map.put("erase", COMMAND_ERASE);
        map.put("save", COMMAND_SAVE);
        return map;
    }

    @Override
    public @Nullable Map getExportedCustomDirectEventTypeConstants() {
        return MapBuilder.of(
                "onSaveEvent", MapBuilder.of("registrationName", "onSaveEvent")
        );
    }
}
