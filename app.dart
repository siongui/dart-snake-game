import 'dart:html';
import 'dart:math';
import 'dart:collection';
import 'dart:async';

int col_number = 10;
int row_number = 10;
int snake_initial_length = 3;
String goDir;
Queue<List<int>> snakeBody = new Queue();
const speed = const Duration(milliseconds: 900);
List<int> foodPosition;


String randomDirection(Random random) {
  int dir_num = random.nextInt(4);
  if (dir_num == 0) { return "←"; }
  if (dir_num == 1) { return "↑"; }
  if (dir_num == 2) { return "→"; }
  return "↓";
}


bool isFoodCollideWithSnakeBody(int row, int col, Queue<List<int>> sb) {
  bool flag = false;
  sb.forEach((List<int> position) {
    if (row == position[0] && col == position[1]) {
      flag = true;
      return;
    }
  });
  return flag;
}

List<int> randomFood(Queue<List<int>> sb) {
  // input: snakeBody
  Random random = new Random(new DateTime.now().millisecondsSinceEpoch);
  int row, col;
  do {
    // food position: row
    row = random.nextInt(row_number);
    // food position: column
    col = random.nextInt(col_number);
  } while (isFoodCollideWithSnakeBody(row, col, sb));

  return [row, col];
}


List<int> nextPosition(String direction, List<int> position) {
  if (position.length != 2) {
    throw new FormatException('bad position format');
  }
  if (direction == "←") {
    int new_col = (position[1] + col_number - 1) % col_number;
    return [position[0], new_col];
  }
  if (direction == "↑") {
    int new_row = (position[0] + row_number - 1) % row_number;
    return [new_row, position[1]];
  }
  if (direction == "→") {
    int new_col = (position[1] + 1) % col_number;
    return [position[0], new_col];
  }
  if (direction == "↓") {
    int new_row = (position[0] + 1) % row_number;
    return [new_row, position[1]];
  }
  throw new FormatException('bad direction');
}

void startGame() {
//void startGame(Event e) {
  query('#start').style.display = 'none';
  DivElement main = query('#main');
  // plot grids
  for(int i=0; i<row_number; i++) {
    for(int j=0; j<col_number; j++) {
      var elm = new DivElement()
        ..classes.add('square')
        ..attributes['data-row'] = '${i}'
        ..attributes['data-col'] = '${j}'
        ..text = ' ';
      main.children.add(elm);
    }
    main.children.add(new BRElement());
  }

  // generate random snake
  Random random = new Random(new DateTime.now().millisecondsSinceEpoch);
  // snake head position: row
  int row = random.nextInt(row_number);
  // snake head position: column
  int col = random.nextInt(col_number);
  // snake initial go direction
  goDir = randomDirection(random);

  query('div[data-row="${row}"][data-col="${col}"]').classes.add('select');
  snakeBody.add([row, col]);

  // snake body direction
  String snakeBodyDir;
  do {
    snakeBodyDir = randomDirection(random);
  } while (snakeBodyDir == goDir);

  // generate snake body
  List<int> pos = snakeBody.first;
  for (int i=0; i<(snake_initial_length-1); i++) {
    pos = nextPosition(snakeBodyDir, pos);
    snakeBody.add(pos);
    query('div[data-row="${pos[0]}"][data-col="${pos[1]}"]')
      .classes.add('select');
  }

  // generate food
  foodPosition = randomFood(snakeBody);
  query('div[data-row="${foodPosition[0]}"][data-col="${foodPosition[1]}"]')
    .classes.add('food');

  // start to move snake
  new Timer.periodic(speed, snakeMove);
}

void snakeMove(Timer t) {
  // move snake: get next position
  List<int> pos = nextPosition(goDir, snakeBody.elementAt(0));

  // check if snake eat itself
  snakeBody.forEach((List<int> position) {
    if (position[0] == pos[0] && position[1] == pos[1]) {
      t.cancel();
      query('#info').text = 'Game Over!';
      return;
    }
  });

  snakeBody.addFirst(pos);
  if (foodPosition[0] == pos[0] && foodPosition[1] == pos[1]) {
    // snake eat food
    // add next position to snake body
    query('div[data-row="${pos[0]}"][data-col="${pos[1]}"]')
      ..classes.add('select')
      ..classes.remove('food');
    // generate food
    foodPosition = randomFood(snakeBody);
    query('div[data-row="${foodPosition[0]}"][data-col="${foodPosition[1]}"]')
      .classes.add('food');
  } else {
    // snake does not eat food
    // add next position to snake body
    query('div[data-row="${pos[0]}"][data-col="${pos[1]}"]')
      .classes.add('select');
    // move snake: remove last position
    pos = snakeBody.removeLast();
    query('div[data-row="${pos[0]}"][data-col="${pos[1]}"]')
      .classes.remove('select');
  }
}

void handleArrowKey(Event e) {
  if (e is KeyboardEvent) {
    KeyboardEvent kevt = e as KeyboardEvent;
    //query('#info').text = '${kevt.keyCode}';

    switch(kevt.keyCode) {
      case 37: // left
        if (goDir != "→") { goDir = "←"; }
        break;

      case 38: // up
        if (goDir != "↓") { goDir = "↑"; }
        break;

      case 39: // right
        if (goDir != "←") { goDir = "→"; }
        break;

      case 40: // down
        if (goDir != "↑") { goDir = "↓"; }
        break;

      default:
    }
  }
}

void main() {
  //query('#start').onClick.listen(startGame);
  startGame();

  window.onKeyDown.listen(handleArrowKey);
}
