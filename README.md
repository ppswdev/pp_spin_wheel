## Features

Custom rotating disarray, easy to achieve the lottery function.

## Usage

```dart
class GameWheelPage extends StatefulWidget {
  const GameWheelPage({super.key});

  @override
  State<GameWheelPage> createState() => _GameWheelPageState();
}

class _GameWheelPageState extends State<GameWheelPage> {
  var items = [
    const PPSpinWheelItem(
        title: 'Item 1',
        bgColor: Color(0xFFF44336),
        weight: 5.0,
        selected: false),
    const PPSpinWheelItem(
        title: 'Item 2',
        bgColor: Color.fromARGB(255, 131, 143, 132),
        weight: 10.0,
        selected: false),
    const PPSpinWheelItem(
        title: 'Item 3',
        bgColor: Color(0xFF2196F3),
        weight: 15.0,
        selected: false),
    const PPSpinWheelItem(
        title: 'Item 4',
        bgColor: Color(0xFFFFC107),
        weight: 20.0,
        selected: false),
    const PPSpinWheelItem(
        title: 'Item 5',
        bgColor: Color(0xFF9C27B0),
        weight: 50.0,
        selected: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: PPSpinWheel(
          size: 360,
          backgroundSize: 340,
          wheelSize: 300,
          // backgroundImage: Image.asset(A.iconWheelDefaultBottom),
          // overlay: Image.asset(
          //   A.iconWheelDefaultHighlight,
          //   width: 302,
          //   height: 302,
          // ),
          // spinIcon: Image.asset(
          //   A.iconWheelDefaultSpin,
          //   width: 60,
          //   height: 60,
          // ),
          // indicator: Image.asset(
          //   A.iconWheelDefaultTopPin,
          //   width: 28,
          //   height: 47,
          // ),
          enableWeight: false,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          items: items,
          //filterIndexs: const [0, 1],
          numberOfTurns: 10,
          onItemPressed: (index) {
            print('index: $index');
          },
          onStartPressed: () {
            //Play start audio
          },
          onSpinFastAudio: () {
            //Play fast audio
          },
          onSpinSlowAudio: () {
            //Play slow audio
          },
          onAnimationEnd: (index) {
            //Play end audio & show result
            print('onAnimationEnd $index');
          },
        ),
      ),
    );
  }
}
```
