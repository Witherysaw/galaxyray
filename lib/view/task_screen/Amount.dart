import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:assignment/controllers/firestoreService.dart';
import 'package:assignment/models/transactionlog.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth_screens/login_screen.dart';
import '../auth_screens/registration_screen.dart';
import '../../controllers/auth.dart';
import '../../controllers/UserEmailProvider.dart';
import '../constants.dart';



class FinancialApp extends StatefulWidget {
  final GlobalKey<_FinancialAppState> financialAppKey = GlobalKey<_FinancialAppState>();
  @override
  _FinancialAppState createState() => _FinancialAppState();
}

class _FinancialAppState extends State<FinancialApp> {
  final FirestoreService _firestoreService = FirestoreService();
  TextEditingController _amountController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  String username = "";
  int mainAmount = 0;
  bool showDetails = false;
  String selectedDescription = '';
  int selectedMainAmount = 0;
  List<TransactionLogWithId> transactionLogs = [];
  String useremail = "";
  String userrank = "";
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadMainAmount();
    _loadTransactionLogs();
    _loadUsernameAndrank();
  }

  void refreshPage() {
    _loadMainAmount();
    _loadTransactionLogs();
    _loadUsernameAndrank();
  }

  Future<void> _loadTransactionLogs() async {
    List<TransactionLogWithId> logs = await _firestoreService.getTransactionLogsWithIds();

    // Sort the logs by datetime in descending order
    logs.sort((a, b) => b.datetime.compareTo(a.datetime));

    setState(() {
      transactionLogs = logs;
    });
  }


  String _formatDatetime(String datetime) {
    DateTime parsedDatetime = DateTime.parse(datetime);
    String formattedDatetime = "${parsedDatetime.day}/${parsedDatetime.month}/${parsedDatetime.year} ${parsedDatetime.hour}:${parsedDatetime.minute}";
    return formattedDatetime;
  }

  // Function to fetch the main amount from Firestore
  Future<void> _loadMainAmount() async {
    int amount = await _firestoreService.getMainAmount();

    setState(() {
      mainAmount = amount;
    });
  }

  Future<void> _loadUsernameAndrank() async {
    String? userEmail = Provider.of<UserEmailProvider>(context, listen: false).enteredEmail;
    print(userEmail);
    String? userName = await _firestoreService.getUserName(userEmail);
    String? userRank = await _firestoreService.getUserRank(userEmail);
    print(userName);

    setState(() {
      username = userName!;
      useremail = userEmail!;
      userrank = userRank!;
    });
  }



  Future<void> _deleteTransaction(String transactionId) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: bgColor,
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this transaction?'),
          actions: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                          // Change the button color based on different states
                          if (states.contains(MaterialState.pressed)) {
                            return Colors.redAccent; // Color when the button is pressed
                          }
                          return Colors.red; // Default color
                        },
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context, true); // User confirmed the delete operation
                    },
                    child: Text('Delete'),
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                          // Change the button color based on different states
                          if (states.contains(MaterialState.pressed)) {
                            return lightBlue; // Color when the button is pressed
                          }
                          return primaryColor; // Default color
                        },
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context, false); // User canceled the delete operation
                    },
                    child: Text('Cancel'),
                  ),
                ],
              ),
            )
          ],
        );
      },
    );

    if (confirmDelete == true) {
      // User confirmed, proceed with delete
      await _firestoreService.deleteTransaction(transactionId);
      await _loadMainAmount();
      await _loadTransactionLogs();
    }
  }


  void _showTransactionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Form(
          key: _formKey,
          child: AlertDialog(
            backgroundColor: bgColor,
            title: Text('Add Transaction'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Enter Amount',
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Enter amount';
                    } else if (!_isValidNumber(value!)) {
                      return 'Enter only numbers that are not zero';
                    }
                    return null;
                  },
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),

              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                            // Change the button color based on different states
                            if (states.contains(MaterialState.pressed)) {
                              return lightBlue; // Color when the button is pressed
                            }
                            return primaryColor; // Default color
                          },
                        ),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          String description = _descriptionController.text;
                          int amount = int.parse(_amountController.text);
                          await _firestoreService.addTransaction(amount, true);
                          await _loadMainAmount();
                          await _firestoreService.addTransactionLog(username, amount, true, description);
                          await _loadTransactionLogs();
                          _amountController.clear();
                          Navigator.pop(context); // Close the dialog
                        }
                        // Validate input to ensure it contains only numbers
                        // if (_isValidNumber(_amountController.text)) {
                        //   String description = _descriptionController.text;
                        //   int amount = int.parse(_amountController.text);
                        //   await _firestoreService.addTransaction(amount, true);
                        //   await _loadMainAmount();
                        //   await _firestoreService.addTransactionLog(username, amount, true, description);
                        //   await _loadTransactionLogs();
                        //   _amountController.clear();
                        //   Navigator.pop(context); // Close the dialog
                        // } else {
                        //   // Show an error message or take appropriate action
                        //   // For example, you can show a SnackBar
                        //   ScaffoldMessenger.of(context).showSnackBar(
                        //     SnackBar(
                        //       content: Text('Please enter numbers only.'),
                        //     ),
                        //   );
                        // }
                      },
                      child: Text('Deposit'),
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                            // Change the button color based on different states
                            if (states.contains(MaterialState.pressed)) {
                              return lightBlue; // Color when the button is pressed
                            }
                            return primaryColor; // Default color
                          },
                        ),
                      ),
                      onPressed: () async {
                        // Validate input to ensure it contains only numbers
                        if (_formKey.currentState!.validate()) {
                          String description = _descriptionController.text;
                          int amount = int.parse(_amountController.text);
                          await _firestoreService.addTransaction(amount, false);
                          await _loadMainAmount();
                          await _firestoreService.addTransactionLog(username, amount, false, description);
                          await _loadTransactionLogs();
                          _amountController.clear();
                          Navigator.pop(context); // Close the dialog
                        }
                      },
                      child: Text('Withdraw'),
                    ),
                  ],
                ),
              )

            ],
          ),
        );
      },
    );
  }

  void _editDescriptionDialog(String logId, String currentDescription) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newDescription = currentDescription;

        return AlertDialog(
          backgroundColor: bgColor,
          title: Text('Edit Description'),
          content: TextField(
            onChanged: (value) {
              newDescription = value;
            },
            controller: TextEditingController(text: currentDescription),
            decoration: InputDecoration(labelText: 'New Description'),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                          // Change the button color based on different states
                          if (states.contains(MaterialState.pressed)) {
                            return lightBlue; // Color when the button is pressed
                          }
                          return primaryColor; // Default color
                        },
                      ),
                    ),
                    onPressed: () {
                      // Call a function to update the description in Firestore using logId and newDescription
                      _updateDescription(logId, newDescription);
                      Navigator.pop(context); // Close the dialog
                    },
                    child: Text('Save'),
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                          // Change the button color based on different states
                          if (states.contains(MaterialState.pressed)) {
                            return lightBlue; // Color when the button is pressed
                          }
                          return primaryColor; // Default color
                        },
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context); // Close the dialog
                    },
                    child: Text('Cancel'),
                  ),
                ],
              ),
            )
          ],
        );
      },
    );
  }

  Future<void> _updateDescription(String logId, String newDescription) async {
    await _firestoreService.updateTransactionDescription(logId,newDescription);
    await _loadTransactionLogs();
  }


  bool _isValidNumber(String input) {
    // Use a regular expression to check if the input contains only digits
    final RegExp regex = RegExp(r'^\d+$');
    // Check if the input is a valid number and not zero
    return regex.hasMatch(input) && int.parse(input) != 0;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  color: lightBlue,
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 10),
                      Text(
                        'Current Main Amount: \$${mainAmount.toString()}',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: transactionLogs.length,
                    itemBuilder: (context, index) {
                      var log = transactionLogs[index];
                      Color transactionColor =
                      log.type == 'deposit' ? depositColor : withdrawColor;
                      bool isCurrentUser = log.username == username;
                      bool isAdmin = userrank == "Admin";
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(5, 1, 5, 3),
                        child: Card(
                          color: darkCard,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            side: BorderSide(
                              color: Colors.black54, // Inner border color (green or red)
                              width: 2.0,
                            ),
                          ),
                          // color: darkCard,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Stack(
                              children: [
                                Card(
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    side: BorderSide(
                                      color: transactionColor, // Inner border color (green or red)
                                      width: 2.0,
                                    ),
                                  ),
                                  color: Colors.transparent,
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${log.username}',
                                                    style: TextStyle(color: Colors.white, fontSize: 18),
                                                  ),
                                                  Text(
                                                    '${_formatDatetime(log.datetime)}',
                                                    style: TextStyle(color: Colors.white, fontSize: 12),
                                                  ),
                                                ],
                                              ),

                                            ],
                                          ),

                                          SizedBox(height: 10),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align items on opposite ends
                                            children: [
                                              Text(
                                                '${log.type == 'deposit' ? '+' : '-'}\$${log.amount}',
                                                style: TextStyle(
                                                  color: transactionColor,
                                                  fontSize: 20,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        log.showDetails = !log.showDetails;
                                                      });
                                                    },
                                                    child: Text(
                                                      log.showDetails ? 'See Less' : 'See More',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  Icon(
                                                    log.showDetails ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                                                    color: Colors.white,
                                                  ),
                                                ],
                                              ),

                                            ],
                                          ),
                                          if (log.showDetails) ...[
                                            SizedBox(height: 5),
                                            Row(
                                              children: [
                                                Text(
                                                'Main Amount After Transaction: ',
                                                style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
                                              ),
                                                Text(
                                                  '${log.mainAmount}',
                                                  style: TextStyle(fontSize: 16, color: Colors.white),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                                'Description',
                                              style: TextStyle(fontSize: 14, color: Colors.white,fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(height: 2,),
                                            Container(
                                              width: double.infinity,
                                              padding: EdgeInsets.all(8.0),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.white,  // Set your desired border color
                                                  width: 1.0,           // Set your desired border width
                                                ),
                                                borderRadius: BorderRadius.circular(8.0),  // Set your desired border radius
                                              ),
                                              child: Text(
                                                '${log.description}',
                                                style: TextStyle(fontSize: 14, color: Colors.white),
                                              ),
                                            ),
                                          ],
                                          // Text('Main Amount: \$${log.mainAmount}'),
                                          // Text('${log.description}'),
                                          SizedBox(height: 7,)
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right : 0,
                                  child: Visibility(
                                    visible: isCurrentUser && !isAdmin,
                                    child: PopupMenuButton<String>(
                                      color: bgColor,
                                      icon: Icon(Icons.more_vert, color: Colors.white),
                                      onSelected: (value) async {
                                        if (value == 'edit') {
                                          _editDescriptionDialog(log.id, log.description);
                                        } else if (value == 'delete') {
                                          await _deleteTransaction(log.id);
                                        }
                                      },
                                      itemBuilder: (BuildContext context) {
                                        List<String> options = [];

                                        if (userrank == 'Admin') {
                                          if (log.username == username) {
                                            options.add('Edit');
                                          }
                                          options.add('Delete');
                                        } else if (userrank == 'User' && log.username == username) {
                                          options.add('Edit');
                                        }

                                        return options.map((String choice) {
                                          return PopupMenuItem<String>(
                                            value: choice.toLowerCase(),
                                            child: Text(choice),
                                          );
                                        }).toList();
                                      },
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right :0,
                                  child: Visibility(
                                    visible: isAdmin,
                                    child: PopupMenuButton<String>(
                                      color: bgColor,
                                      icon: Icon(Icons.more_vert, color: Colors.white),
                                      onSelected: (value) async {
                                        if (value == 'edit') {
                                          _editDescriptionDialog(log.id, log.description);
                                        } else if (value == 'delete') {
                                          await _deleteTransaction(log.id);
                                        }
                                      },
                                      itemBuilder: (BuildContext context) {
                                        List<String> options = [];

                                        if (userrank == 'Admin') {
                                          if (log.username == username) {
                                            options.add('Edit');
                                          }
                                          options.add('Delete');
                                        } else if (userrank == 'User' && log.username == username) {
                                          options.add('Edit');
                                        }

                                        return options.map((String choice) {
                                          return PopupMenuItem<String>(
                                            value: choice.toLowerCase(),
                                            child: Text(choice),
                                          );
                                        }).toList();
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                      // return ListTile(
                      //   title: Text('${log.username} ${log.type} \$${log.amount}'),
                      //   subtitle: Text('${log.datetime} Main Amount: \$${log.mainAmount}'),
                      // );
                    },
                  ),
                ),
                // TextField(
                //   controller: _amountController,
                //   keyboardType: TextInputType.number,
                //   decoration: InputDecoration(labelText: 'Enter Amount'),
                // ),
                // SizedBox(height: 20),
                // ElevatedButton(
                //   onPressed: () async {
                //     int amount = int.parse(_amountController.text);
                //     await _firestoreService.addTransaction(amount, true);
                //     _amountController.clear();
                //     // Refresh the displayed main amount after a deposit
                //     await _loadMainAmount();
                //   },
                //   child: Text('Deposit'),
                // ),
                // ElevatedButton(
                //   onPressed: () async {
                //     int amount = int.parse(_amountController.text);
                //     await _firestoreService.addTransaction(amount, false);
                //     _amountController.clear();
                //     // Refresh the displayed main amount after a withdrawal
                //     await _loadMainAmount();
                //   },
                //   child: Text('Withdraw'),
                // ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showTransactionDialog();
        },
        child: Icon(Icons.add),
        backgroundColor: primaryColor,
      ),
    );

  }
}

