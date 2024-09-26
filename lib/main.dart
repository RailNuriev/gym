import 'package:flutter/material.dart';
import 'dart:async'; // Импорт для работы с таймерами
import 'package:provider/provider.dart'; // Импорт для управления состоянием

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => StopwatchModel(), // Создаем состояние для секундомера
      child: MyApp(), // Запуск нашего приложения
    ),
  );
}

// Виджет основного приложения
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light; // Переменная для темы (по умолчанию светлая)
  bool _isDarkMode = false; // Хранит состояние текущей темы (светлая или тёмная)

  // Функция для смены темы
  void _toggleTheme(bool isDarkMode) {
    setState(() {
      _isDarkMode = isDarkMode;
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light; // Меняем тему
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TabBar Example',
      themeMode: _themeMode, // Используем текущую тему
      theme: ThemeData.light(), // Светлая тема
      darkTheme: ThemeData.dark(), // Тёмная тема
      debugShowCheckedModeBanner: false, // Убираем баннер "Debug"
      home: SimpleTabBar(
        toggleTheme: _toggleTheme, // Передаем функцию смены темы
        isDarkMode: _isDarkMode, // Передаем текущее состояние темы
      ),
    );
  }
}

// Виджет с табами
class SimpleTabBar extends StatelessWidget {
  final Function(bool) toggleTheme; // Функция для переключения темы
  final bool isDarkMode; // Состояние темы

  const SimpleTabBar({
    Key? key,
    required this.toggleTheme,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5, // Количество вкладок
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Название приложения',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
          centerTitle: true, // Название по центру
        ),
        body: TabBarView(
          children: [
            Center(child: Text("Рисунок чувака с названием мышц")),
            SimpleGridPage(), // Страница со списком мышц
            Center(child: Text("Избранные упражнения")),
            Center(child: StopwatchTab()), // Вкладка с секундомером
            SettingsPage(
              toggleTheme: toggleTheme, // Страница с настройками
              isDarkMode: isDarkMode,
            ),
          ],
        ),
        bottomNavigationBar: TabBar(
          tabs: [
            Tab(icon: Icon(Icons.accessibility_new)), // Иконка для вкладки "Мышцы"
            Tab(icon: Icon(Icons.view_headline)), // Иконка для вкладки "Упражнения"
            Tab(icon: Icon(Icons.favorite)), // Иконка для вкладки "Избранное"
            Tab(icon: Icon(Icons.access_time)), // Иконка для вкладки "Секундомер"
            Tab(icon: Icon(Icons.settings)), // Иконка для вкладки "Настройки"
          ],
          labelColor: Colors.red, // Цвет активной вкладки
          unselectedLabelColor: Colors.grey, // Цвет неактивных вкладок
          indicatorColor: Colors.red, // Цвет индикатора под вкладками
        ),
      ),
    );
  }
}

// Модель для секундомера
class StopwatchModel extends ChangeNotifier {
  Stopwatch _stopwatch = Stopwatch(); // Внутренний секундомер
  Timer? _timer; // Таймер для обновления интерфейса
  String _elapsedTime = '00:00:00'; // Текущее время отображения

  String get elapsedTime => _elapsedTime; // Геттер для времени
  bool get isRunning => _stopwatch.isRunning; // Геттер для состояния секундомера

  StopwatchModel() {
    // Таймер, который каждые 10 миллисекунд обновляет состояние, если секундомер работает
    _timer = Timer.periodic(Duration(milliseconds: 10), (timer) {
      if (_stopwatch.isRunning) {
        _elapsedTime = _formatTime(_stopwatch.elapsed); // Форматируем время
        notifyListeners(); // Обновляем интерфейс
      }
    });
  }

  // Метод для запуска секундомера
  void start() {
    _stopwatch.start();
    notifyListeners();
  }

  // Метод для остановки секундомера
  void stop() {
    _stopwatch.stop();
    notifyListeners();
  }

  // Метод для сброса секундомера
  void reset() {
    _stopwatch.stop(); // Останавливаем
    _stopwatch.reset(); // Сбрасываем время
    _elapsedTime = '00:00:00'; // Обнуляем отображение
    notifyListeners(); // Обновляем интерфейс
  }

  // Метод для форматирования времени в "мм:сс:мс"
  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0'); // Добавляем ведущий ноль
    int milliseconds = (duration.inMilliseconds % 1000) ~/ 10; // Выводим сотые доли секунды
    return "${twoDigits(duration.inMinutes % 60)}:${twoDigits(duration.inSeconds % 60)}:${twoDigits(milliseconds)}";
  }

  @override
  void dispose() {
    _timer?.cancel(); // Останавливаем таймер при удалении виджета
    super.dispose();
  }
}

// Виджет для вкладки "Секундомер"
class StopwatchTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final stopwatchModel = Provider.of<StopwatchModel>(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Отображение времени
          Padding(
            padding: const EdgeInsets.only(bottom: 40.0),
            child: Text(
              stopwatchModel.elapsedTime, // Отображаем текущее время
              style: TextStyle(
                fontSize: 48, // Увеличиваем размер шрифта для времени
                fontWeight: FontWeight.bold, // Делаем текст жирным для лучшей читаемости
              ),
            ),
          ),
          // Кнопки "Старт/Стоп" и "Сброс"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Равномерно распределяем кнопки
            children: [
              // Задаем фиксированную ширину для кнопки "Старт/Стоп"
              SizedBox(
                width: 150, // Ширина кнопки
                child: ElevatedButton(
                  onPressed: () {
                    if (stopwatchModel.isRunning) {
                      stopwatchModel.stop();
                    } else {
                      stopwatchModel.start();
                    }
                  },
                  child: Text(
                    stopwatchModel.isRunning ? 'Стоп' : 'Старт', // Меняем текст на кнопке в зависимости от состояния
                    style: TextStyle(
                      fontSize: 20, // Размер шрифта текста на кнопке
                      color: Colors.white, // Цвет текста
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: stopwatchModel.isRunning ? Colors.red : Colors.green, // Цвет кнопки
                    padding: EdgeInsets.symmetric(vertical: 12), // Внутренние отступы по вертикали
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), // Закругленные углы кнопки
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10), // Отступ между кнопками
              // Задаем фиксированную ширину для кнопки "Сброс"
              SizedBox(
                width: 150, // Ширина кнопки
                child: ElevatedButton(
                  onPressed: stopwatchModel.reset,
                  child: Text(
                    'Сброс', // Текст на кнопке сброса
                    style: TextStyle(
                      fontSize: 20, // Размер шрифта текста на кнопке
                      color: Colors.white, // Цвет текста
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Цвет кнопки сброса
                    padding: EdgeInsets.symmetric(vertical: 12), // Внутренние отступы по вертикали
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), // Закругленные углы кнопки
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}



// Пример страницы "Список упражнений" (сетка)
class SimpleGridPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final itemNames = [
      "Разминка", "Шеи", "Спины", "Груди", "Кора",
      "Плечевого пояса и руки", "Ног", "Интересные факты"
    ];

    final imageUrls = [
      "https://i.pinimg.com/564x/ac/8e/61/ac8e61c5e8330074e9ac52ce1c4abfc6.jpg",
      "https://i.imgur.com/hNdHPYV.jpeg",
      "https://i.imgur.com/ey6BO8l.jpeg",
      "https://sun1-89.userapi.com/impg/qD9eknoAb_tpboJRER3M1-Y0hksU1ENaXgIIsQ/RQgAIKEfFYI.jpg?size=300x206&quality=95&sign=e274949615ba6a997b74b475df560929&type=album",
      "https://via.placeholder.com/150",
      "https://i.pinimg.com/originals/41/7a/b0/417ab0b494629a36962fa0356ee99f90.jpg",
      "https://via.placeholder.com/150",
      "https://via.placeholder.com/150",
    ];

    return Column(
      children: [
        Text(
          "Упражнения для мышц", // Оставляем это название как общий заголовок страницы
          style: TextStyle(fontSize: 26, color: Colors.red),
          textAlign: TextAlign.center,
        ),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            padding: EdgeInsets.all(10),
            children: List.generate(itemNames.length, (index) {
              return GestureDetector(
                onTap: () {
                  // Переход на соответствующую страницу упражнений
                  switch (itemNames[index]) {
                    case "Разминка":
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WarmUpPage(),
                        ),
                      );
                      break;
                    case "Шеи":
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NeckExercisesPage(),
                        ),
                      );
                      break;
                    case "Спины":
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BackExercisesPage(),
                        ),
                      );
                      break;
                    case "Груди":
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChestExercisesPage(),
                        ),
                      );
                      break;
                    case "Кора":
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CoreExercisesPage(),
                        ),
                      );
                      break;
                    case "Плечевого пояса и руки":
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ShoulderArmExercisesPage(),
                        ),
                      );
                      break;
                    case "Ног":
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LegExercisesPage(),
                        ),
                      );
                      break;
                    case "Интересные факты":
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InterestingFactsPage(),
                        ),
                      );
                      break;
                  }
                },
                child: Column(
                  children: [
                    Expanded(
                      child: Image.network(
                        imageUrls[index], // Используем изображение из imageUrls
                        fit: BoxFit.cover,
                      ),
                    ),
                    Text(itemNames[index], style: TextStyle(fontSize: 14)),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}


class WarmUpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final warmUpExercises = [
      {
        'name': 'Крутить головой',
        'description': 'Поворачивайте голову медленно в разные стороны',
        'icon': Icons.rotate_right,
      },
      {
        'name': 'Разминка плеч',
        'description': 'Круговые движения плечами вперёд и назад',
        'icon': Icons.accessibility,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Разминка'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: warmUpExercises.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: Icon(warmUpExercises[index]['icon'] as IconData),
              title: Text(warmUpExercises[index]['name'] as String),
              subtitle: Text(warmUpExercises[index]['description'] as String),
              trailing: Icon(Icons.more_vert),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExerciseDetailPage(
                      exerciseName: warmUpExercises[index]['name'] as String,
                      description: warmUpExercises[index]['description'] as String,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}


class NeckExercisesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final neckExercises = [
      {
        'name': 'Наклоны головы вперед',
        'description': 'Наклоняйте голову медленно вперед, удерживая каждую позу по 5 секунд.',
        'icon': Icons.rotate_right,
      },
      {
        'name': 'Наклоны головы в стороны',
        'description': 'Наклоняйте голову к плечам, удерживая каждую позу по 5 секунд.',
        'icon': Icons.accessibility_new,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Упражнения для шеи'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: neckExercises.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: Icon(neckExercises[index]['icon'] as IconData),
              title: Text(neckExercises[index]['name'] as String),
              subtitle: Text(neckExercises[index]['description'] as String),
              trailing: Icon(Icons.more_vert),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExerciseDetailPage(
                      exerciseName: neckExercises[index]['name'] as String,
                      description: neckExercises[index]['description'] as String,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}


class BackExercisesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final backExercises = [
      {
        'name': 'Наклоны вперед с прямой спиной',
        'description': 'Наклоняйтесь вперед с прямой спиной, держа руки перед собой.',
        'icon': Icons.accessibility,
      },
      {
        'name': 'Подъемы корпуса лежа на спине',
        'description': 'Лежа на спине, поднимайте корпус вверх.',
        'icon': Icons.fitness_center,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Упражнения для спины'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: backExercises.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: Icon(backExercises[index]['icon'] as IconData),
              title: Text(backExercises[index]['name'] as String),
              subtitle: Text(backExercises[index]['description'] as String),
              trailing: Icon(Icons.more_vert),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExerciseDetailPage(
                      exerciseName: backExercises[index]['name'] as String,
                      description: backExercises[index]['description'] as String,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}


class ChestExercisesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final backExercises = [
      {
        'name': 'Наклоны груди сиси писи с прямой спиной',
        'description': 'Наклоняйтесь вперед с прямой спиной, держа руки перед собой.',
        'icon': Icons.accessibility,
      },
      {
        'name': 'Подъемы корпуса лежа на спине',
        'description': 'Лежа на спине, поднимайте корпус вверх.',
        'icon': Icons.fitness_center,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Упражнения для груди'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: backExercises.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: Icon(backExercises[index]['icon'] as IconData),
              title: Text(backExercises[index]['name'] as String),
              subtitle: Text(backExercises[index]['description'] as String),
              trailing: Icon(Icons.more_vert),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExerciseDetailPage(
                      exerciseName: backExercises[index]['name'] as String,
                      description: backExercises[index]['description'] as String,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class CoreExercisesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final backExercises = [
      {
        'name': 'Наклоны вперед с прямым кором',
        'description': 'Наклоняйтесь вперед с прямой спиной, держа руки перед собой.',
        'icon': Icons.accessibility,
      },
      {
        'name': 'Подъемы корпуса лежа на спине',
        'description': 'Лежа на спине, поднимайте корпус вверх.',
        'icon': Icons.fitness_center,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Упражнения для мышц кора'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: backExercises.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: Icon(backExercises[index]['icon'] as IconData),
              title: Text(backExercises[index]['name'] as String),
              subtitle: Text(backExercises[index]['description'] as String),
              trailing: Icon(Icons.more_vert),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExerciseDetailPage(
                      exerciseName: backExercises[index]['name'] as String,
                      description: backExercises[index]['description'] as String,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}


class ShoulderArmExercisesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final backExercises = [
      {
        'name': 'Наклоны качаешь руки и туда сюда',
        'description': 'Наклоняйтесь вперед с прямой спиной, держа руки перед собой.',
        'icon': Icons.accessibility,
      },
      {
        'name': 'Подъемы корпуса лежа на спине',
        'description': 'Лежа на спине, поднимайте корпус вверх.',
        'icon': Icons.fitness_center,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Упражнения для плечевого пояса и руки'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: backExercises.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: Icon(backExercises[index]['icon'] as IconData),
              title: Text(backExercises[index]['name'] as String),
              subtitle: Text(backExercises[index]['description'] as String),
              trailing: Icon(Icons.more_vert),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExerciseDetailPage(
                      exerciseName: backExercises[index]['name'] as String,
                      description: backExercises[index]['description'] as String,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}


class LegExercisesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final backExercises = [
      {
        'name': 'Наклоны ногой туда сюда',
        'description': 'Наклоняйтесь вперед с прямой спиной, держа руки перед собой.',
        'icon': Icons.accessibility,
      },
      {
        'name': 'Подъемы корпуса лежа на спине',
        'description': 'Лежа на спине, поднимайте корпус вверх.',
        'icon': Icons.fitness_center,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Упражнения для ног'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: backExercises.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: Icon(backExercises[index]['icon'] as IconData),
              title: Text(backExercises[index]['name'] as String),
              subtitle: Text(backExercises[index]['description'] as String),
              trailing: Icon(Icons.more_vert),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExerciseDetailPage(
                      exerciseName: backExercises[index]['name'] as String,
                      description: backExercises[index]['description'] as String,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}


class InterestingFactsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final backExercises = [
      {
        'name': 'Вот и интересный факт',
        'description': 'Наклоняйтесь вперед с прямой спиной, держа руки перед собой.',
        'icon': Icons.accessibility,
      },
      {
        'name': 'Подъемы корпуса лежа на спине',
        'description': 'Лежа на спине, поднимайте корпус вверх.',
        'icon': Icons.fitness_center,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Интересные факты'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: backExercises.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: Icon(backExercises[index]['icon'] as IconData),
              title: Text(backExercises[index]['name'] as String),
              subtitle: Text(backExercises[index]['description'] as String),
              trailing: Icon(Icons.more_vert),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExerciseDetailPage(
                      exerciseName: backExercises[index]['name'] as String,
                      description: backExercises[index]['description'] as String,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}






class ExerciseDetailPage extends StatelessWidget {
  final String exerciseName;
  final String description;

  ExerciseDetailPage({
    required this.exerciseName,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Назад'), // Заголовок страницы изменен
        centerTitle: false,

      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exerciseName, // Отображается название упражнения
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              description, // Описание упражнения
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}



// Страница "Настройки" с переключателем для смены темы
class SettingsPage extends StatelessWidget {
  final Function(bool) toggleTheme; // Функция для изменения темы
  final bool isDarkMode; // Текущая тема (тёмная или светлая)

  const SettingsPage({
    Key? key,
    required this.toggleTheme,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // Центрируем содержимое
        children: [
          Icon(Icons.brightness_7), // Иконка для светлой темы
          Switch(
            value: isDarkMode, // Состояние переключателя (включена ли тёмная тема)
            onChanged: (value) {
              toggleTheme(value); // Переключаем тему при изменении
            },
          ),
          Icon(Icons.brightness_3), // Иконка для тёмной темы
        ],
      ),
    );
  }
}

