# react-native-draw-canvas

A cross-platform native drawing canvas which allows users to create hand made paintings with their fingers. On iOS this package uses the native PencilKit and on android it is implemented customly. While both the iOS and Android versions differ greatly, they share a common API that is exposed via JS. 

**Requirements**
 • iOS 13.0+
 • react-native 0.60.0+

## Getting started

`$ npm install react-native-draw-canvas --save`

## Usage
```javascript
import { DrawCanvas } from 'react-native-draw-canvas';

// note the color and stroke props only work on Android
<PencilKit color={"black"} strokeWidth={5} ref={ref => this.pencilKit = ref} />
```

## Methods

As well as rendering the canvas view as a component, this class has several instance methods that can be called using the objects ref once instantiated.

To set the stroke color without a prop (android only)
```javascript
this.pencilKit.setColor('black')
```

To undo / redo the previous drawing action
```javascript
this.pencilKit.undo()
this.pencilKit.redo()
```

To change the theme of the drawing
```javascript
this.pencilKit.setDarkMode()
this.pencilKit.setLightMode()
```

To get the drawing as an image
```javascript
 this.pencilKit.getDrawing(data => {
   // data has the following shape
   // { uri: 'file://drawing...', fileSize?: 123910 }
 })
 ```