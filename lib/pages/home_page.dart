import 'package:flutter/material.dart';
import 'package:habit_tracker/components/habit_tile.dart';
import 'package:habit_tracker/components/my_drawer.dart';
import 'package:habit_tracker/database/habit_database.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/util/habit_util.dart';
import '../components/heat_map.dart';

class MyHomePage extends StatefulWidget{
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePage();
}

class _MyHomePage extends State<MyHomePage>{

  @override
  void initState(){
    Provider.of<HabitDatabase>(context, listen: false).readHabits();
    super.initState();
  }

  final TextEditingController textController = TextEditingController();

  void createNewHabit(){
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Create New Habit'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(
              hintText: 'Enter habit name',
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
          actions: <Widget>[
            MaterialButton(
              onPressed: () {
                String newHabitName = textController.text;
                context.read<HabitDatabase>().addHabit(newHabitName);
                Navigator.of(context).pop();
                textController.clear();
              },
              child: Text(
                'Create',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            MaterialButton(
              onPressed: () {
                Navigator.of(context).pop();
                textController.clear();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
          ],
        ),
    );
  }

  void checkHabitOnOff(bool? value, Habit habit){
    if (value != null){
      context.read<HabitDatabase>().updateHabitCompletion(habit.id, value);
    }
  }

  void editHabitBox(Habit habit){
    textController.text = habit.name;
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Edit Habit'),
          content: TextField(
            controller: textController,
          ),
          actions: [
            MaterialButton(
                onPressed: () {
                  String newHabitName = textController.text;
                  context.read<HabitDatabase>().updateHabitName(habit.id, newHabitName);
                  Navigator.of(context).pop();
                  textController.clear();
                },
                child: const Text('Save'),
            ),
            MaterialButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  textController.clear();
                },
                child: const Text('Cancel'),
            )
          ],
        )
    );
  }

  void deleteHabitBox(Habit habit){
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Text('Are you sure you want to delete ${habit.name}?'),
          actions: [
            MaterialButton(
                onPressed: () {
                  context.read<HabitDatabase>().deleteHabit(habit.id);
                  Navigator.of(context).pop();
                },
                child: const Text('Delete'),
            ),
            MaterialButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
            )
          ],
        )
    );
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Habit Tracker',
          style: TextStyle(
            color: Theme.of(context).colorScheme.inversePrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
        centerTitle: true,

      ),
      drawer: const MyDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewHabit,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        child: Icon(
            Icons.add,
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
      ),
      body: ListView(
        children: [
          _buildHeatMap(),
          _buildHabitList(),

        ],
      )
    );
  }

  Widget _buildHeatMap(){
    final habitDatabase = context.watch<HabitDatabase>();

    List<Habit> currentHabits = habitDatabase.currentHabits;

    return FutureBuilder<DateTime?>(
        future: habitDatabase.getFirstLaunchDate(),
        builder: (context, snapshot){
          if (snapshot.hasData){
            return MyHeatMap(
                startDate: snapshot.data!, datasets: prepareHeatMapDataset(currentHabits)
            );
          } else {
            return Container();
          }
        },
    );
  }

  Widget _buildHabitList(){
    final habitDatabase = context.watch<HabitDatabase>();

    List<Habit> currentHabits = habitDatabase.currentHabits;

    return ListView.builder(
      itemCount: currentHabits.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder:(context, index) {
        final habit = currentHabits[index];
        bool isCompletedToday = isHabitCompletedToday(habit.completedDays);
        return MyHabitTile(
          text: habit.name,
          isCompleted: isCompletedToday,
          onChanged: (value) => checkHabitOnOff(value, habit),
          editHabit: (context) => editHabitBox(habit),
          deleteHabit: (context) => deleteHabitBox(habit),
        );
      },
    );
  }
}