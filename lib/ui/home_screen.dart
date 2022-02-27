import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _stocks = [];

  final _stockBox = Hive.box('stock_box');

  @override
  void initState() {
    super.initState();
    _refreshStocks();
  }

  void _refreshStocks() {
    final data = _stockBox.keys.map(
      (key) {
        final value = _stockBox.get(key);
        return {"key": key, "barcode": value["barcode"], "qty": value["qty"]};
      },
    ).toList();

    setState(() {
      _stocks = data.reversed.toList();
    });
  }

  // create data
  Future<void> _createStock(Map<String, dynamic> newStock) async {
    await _stockBox.add(newStock);
    _refreshStocks();
  }

  Map<String, dynamic> _readStock(int key) {
    final stock = _stockBox.get(key);
    return stock;
  }

  // update data
  Future<void> _updateStock(int stockKey, Map<String, dynamic> stock) async {
    await _stockBox.put(stockKey, stock);
    _refreshStocks();
  }

  // delete data
  Future<void> _deleteStock(int stockKey) async {
    await _stockBox.delete(stockKey);
    _refreshStocks();

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Stock has been deleted')));
  }

  // controller text
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();

  void _showForm(BuildContext ctx, int? stockKey) async {
    if (stockKey != null) {
      final existingStock =
          _stocks.firstWhere((element) => element['key'] == stockKey);
      _barcodeController.text = existingStock['barcode'];
      _qtyController.text = existingStock['qty'];
    }

    showModalBottomSheet(
        context: ctx,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(ctx).viewInsets.bottom,
                  top: 15,
                  left: 15,
                  right: 15),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextField(
                      controller: _barcodeController,
                      decoration: const InputDecoration(hintText: 'Barcode'),
                    ),
                    TextField(
                      controller: _qtyController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: 'qty'),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          if (stockKey == null) {
                            _createStock({
                              "barcode": _barcodeController.text,
                              "qty": _qtyController.text
                            });
                          }

                          if (stockKey != null) {
                            _updateStock(stockKey, {
                              "barcode": _barcodeController.text.trim(),
                              "qty": _qtyController.text.trim()
                            });
                          }

                          // clear text fields
                          _barcodeController.text = '';
                          _qtyController.text = '';

                          Navigator.of(context).pop();
                        },
                        child: Text(stockKey == null ? 'Input' : 'Update')),
                    const SizedBox(
                      height: 15,
                    )
                  ]),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stock App by olizyusuf.github.io')),
      body: _stocks.isEmpty
          ? const Center(
              child: Text(
                'No Data',
                style: TextStyle(fontSize: 30),
              ),
            )
          : ListView.builder(
              itemCount: _stocks.length,
              itemBuilder: (_, index) {
                final currentStock = _stocks[index];
                return Card(
                  color: Colors.blueGrey.shade100,
                  margin: const EdgeInsets.all(5),
                  elevation: 2,
                  child: ListTile(
                    title: Text('Kode: ${currentStock['barcode']}'),
                    subtitle: Text('Qty: ${currentStock['qty'].toString()}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // edit button
                        IconButton(
                            onPressed: () =>
                                _showForm(context, currentStock['key']),
                            icon: const Icon(Icons.edit)),
                        IconButton(
                            onPressed: () => _deleteStock(currentStock['key']),
                            icon: const Icon(Icons.delete)),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context, null),
        child: const Icon(Icons.add),
      ),
    );
  }
}
