import React, { ReactElement } from 'react'
import ReactNative, {
  processColor,
  requireNativeComponent,
  StyleSheet,
  SyntheticEvent,
  UIManager,
} from 'react-native'

// import the native android pencil kit class
const RCTPencilKitView = requireNativeComponent('RCTPencilKitView')

const styles = StyleSheet.create({
  container: {
    justifyContent: 'center',
    backgroundColor: 'white',
    alignItems: 'baseline',
    flex: 1,
  },
})

interface Props {
  style?: 'light' | 'dark'
  color?: 'string'
}
interface State {
  color: string
}

type SaveCallback = ({ uri: string }) => void

const COLORS = [
  'black',
  '#FA3142',
  '#157FFB',
  '#FDD230',
  '#51D727',
  '#F17CFC',
  '#835FF4',
  '#72E1FD',
  '#FF9800',
  '#985213',
]

export class PencilKit extends React.Component<Props, State> {

  private pencilKit: React.RefObject<PencilKit>
  private onSaveCallback: SaveCallback = null

  // Always true on android
  public static isAvailable = (): boolean => {
    return true
  }

  constructor(props: Props) {
    super(props)
    this.pencilKit = React.createRef()
    this.state = {
      color: props.color || 'black',
    }
  }

  static getDerivedStateFromProps(props:Props, state:State): State {
    const color = props.color || state.color
    return { ...state, color }
  }

  public setColor = (color: string): void => {
    this.setState({ color })
  }

  public undo = (): void => {
    UIManager.dispatchViewManagerCommand(this.getTag(), 1, null)
  }

  public redo = (): void => {
    UIManager.dispatchViewManagerCommand(this.getTag(), 2, null)
  }

  public erase = (): void => {
    UIManager.dispatchViewManagerCommand(this.getTag(), 3, null)
  }

  public setDarkMode = (): void => {
    UIManager.dispatchViewManagerCommand(this.getTag(), 5, null)
  }

  public setLightMode = (): void => {
    UIManager.dispatchViewManagerCommand(this.getTag(), 6, null)
  }

  private draw = (): void => {
    this.setState({ color: this.state.color })
  }

  private getTag = (): number => {
    return ReactNative.findNodeHandle(this.pencilKit.current)
  }

  public getDrawing = (callback: SaveCallback): void => {
    console.log('[Android] Pencil kit saved called!')
    this.onSaveCallback = callback
    UIManager.dispatchViewManagerCommand(this.getTag(), 4, null)
  }

  private onSaveEvent = (event: SyntheticEvent): void => {
    console.log('[AndroidPencilKit] on saved event called!', event.nativeEvent)
    if (this.onSaveCallback && event && event.nativeEvent && event.nativeEvent.uri)
      this.onSaveCallback({ uri: `file://${event.nativeEvent.uri}` })
  }

  render(): ReactElement {
    return (
      <RCTPencilKitView
        color={processColor(this.state.color)}
        onSaveEvent={this.onSaveEvent}
        style={styles.container}
        ref={this.pencilKit}
      />
    );
  }
}
