import React, { ReactElement } from 'react'
import ReactNative, { NativeModules, requireNativeComponent, StyleSheet } from 'react-native'

// Load Native iOS Components
const RNPencilKit = requireNativeComponent('RNPencilKit')
const RNPencilKitManager = NativeModules.RNPencilKitManager

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
})

interface Props {
  style?: 'light' | 'dark'
  onFinished: (uri: string) => void
}

export class PencilKit extends React.Component<Props> {
  private pencilKit: React.RefObject<PencilKit>

  static isAvailable(): boolean {
    return RNPencilKitManager.available
  }

  constructor(props: Props) {
    super(props)
    this.pencilKit = React.createRef()
  }

  componentDidMount(): void {
    this.setToolPicker()
  }

  getTag(): number {
    return ReactNative.findNodeHandle(this.pencilKit.current)
  }

  getDrawing(callback: (data: { uri: string }) => void): void {
    RNPencilKitManager.getDrawing(this.getTag(), callback)
  }

  setToolPicker(): void {
    RNPencilKitManager.setToolPicker(this.getTag())
  }

  setDarkMode(): void {
    RNPencilKitManager.setDarkMode(this.getTag())
  }

  setLightMode(): void {
    RNPencilKitManager.setLightMode(this.getTag())
  }

  save = (): void => {
    this.getDrawing((data: { uri: string }): void => {
      this.props.onFinished(data.uri)
    })
  }

  undo = (): void => {
    RNPencilKitManager.undo(this.getTag())
  }

  redo = (): void => {
    RNPencilKitManager.redo(this.getTag())
  }

  render(): ReactElement {
    return <RNPencilKit ref={this.pencilKit} style={styles.container} />
  }
}
