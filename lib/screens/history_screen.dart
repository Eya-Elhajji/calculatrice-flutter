import 'package:flutter/material.dart';
import '../database/database.dart';
import '../model/calcul.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Calculation> _calculations = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final calcs = await DatabaseHelper.instance.getAllCalculations();
    setState(() {
      _calculations = calcs;
    });
  }

  Future<void> _deleteItem(int id) async {
    await DatabaseHelper.instance.deleteCalculation(id);
    _loadHistory();
  }

  Future<void> _clearAll() async {
    await DatabaseHelper.instance.clearHistory();
    _loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Color(0xFF1C1C1E),
        title: Text('Historique', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_sweep),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: Color(0xFF2C2C2E),
                  title: Text('Vider l\'historique',
                      style: TextStyle(color: Colors.white)),
                  content: Text('Êtes-vous sûr ?',
                      style: TextStyle(color: Colors.white70)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text('Annuler',
                          style: TextStyle(color: Colors.blue)),
                    ),
                    TextButton(
                      onPressed: () {
                        _clearAll();
                        Navigator.pop(ctx);
                      },
                      child:
                      Text('Vider', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _calculations.isEmpty
          ? Center(
        child: Text(
          'Aucun historique',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: _calculations.length,
        itemBuilder: (ctx, index) {
          final calc = _calculations[index];
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Color(0xFF1C1C1E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text(
                '${calc.expression} = ${calc.result}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
              subtitle: Text(
                DateTime.parse(calc.timestamp)
                    .toString()
                    .substring(0, 16),
                style: TextStyle(color: Colors.grey),
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteItem(calc.id!),
              ),
            ),
          );
        },
      ),
    );
  }
}
