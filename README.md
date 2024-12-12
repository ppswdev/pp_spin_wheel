## Features

Custom rotating disarray, easy to achieve the lottery function.

<img src="https://github.com/user-attachments/assets/534ad9a3-9bdc-421e-8659-2b7b3f9a9966" alt="demo1" width="400" height="870">
<img src="https://github.com/user-attachments/assets/9d85cde3-3720-4a2d-aa42-f2f2b3f80f03" alt="demo2" width="400" height="870">
<img src="https://github.com/user-attachments/assets/b1c402ca-fcea-4c05-8d31-e95584ebb240" alt="demo3" width="400" height="870">
<img src="https://github.com/user-attachments/assets/71bba4cc-d203-46b2-8ef1-3dc29db75910" alt="demo4" width="400" height="870">

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
