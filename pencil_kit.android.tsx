import React, { ReactElement } from 'react'
import ReactNative, {
  Button,
  processColor,
  requireNativeComponent,
  ScrollView,
  StyleSheet,
  SyntheticEvent,
  TouchableOpacity,
  UIManager,
  View,
} from 'react-native'

// import the native android pencil kit class
const RCTPencilKitView = requireNativeComponent('RCTPencilKitView')

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  frame: {
    justifyContent: 'center',
    backgroundColor: 'white',
    alignItems: 'baseline',
    flex: 1,
  },
  buttons: {
    flexDirection: 'row',
    justifyContent: 'space-evenly',
  },
  scrollView: {
    backgroundColor: 'white',
    flexShrink: 1,
    flexGrow: 0,
    padding: 4,
  },
  buttonFrame: {
    flexDirection: 'row',
  },
  button: {
    padding: 4,
  },
  color: {
    height: 40,
    width: 40,
  },
  border: {
    borderWidth: 2,
    borderRadius: 2,
    borderColor: '#FDD230',
    padding: 2,
  },
  row: {
    flexDirection: 'row',
    backgroundColor: 'white',
  },
})

interface Props {
  style?: 'light' | 'dark'
}
interface State {
  color: string
  tool: 'penil' | 'eraser'
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

  constructor(props: Props) {
    super(props)
    this.pencilKit = React.createRef()
    this.state = {
      color: 'black',
      tool: 'penil',
    }
  }

  setColor = (color: string): void => {
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
    const color = processColor(this.state.color)
    console.log('[APencilKit] android color:', color)
    return (
      <View style={styles.container}>
        <RCTPencilKitView style={styles.frame} color={color} ref={this.pencilKit} onSaveEvent={this.onSaveEvent} />
        <View style={styles.row}>
          <ColorPicker current={this.state.color} action={this.setColor} />
          <Button title={'erase'} onPress={this.erase} />
        </View>
      </View>
    )
  }
}

interface PickerProps {
  action: Function
  current: string
}
function ColorPicker(props: PickerProps): ReactElement {
  const { current, action } = props
  return (
    <ScrollView horizontal={true} style={styles.scrollView} contentContainerStyle={styles.buttonFrame}>
      {COLORS.map((color, i) => (
        <ColorButton color={color} key={i} current={current} action={action} />
      ))}
    </ScrollView>
  )
}

interface ButtonProps {
  action: Function
  current: string
  color: string
}
function ColorButton(props: ButtonProps): ReactElement {
  const onPress = (): void => props.action(props.color)
  const borders = props.color === props.current ? styles.border : null
  return (
    <TouchableOpacity style={[styles.button, borders]} onPress={onPress}>
      <View style={[styles.color, { backgroundColor: props.color }]} />
    </TouchableOpacity>
  )
}
