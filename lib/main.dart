import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MultiAccountApp());
}

/// مدل داده‌ای برای هر حساب
class AccountData {
  String name;                         // نام حساب
  double totalIncome;                  // کل درآمد
  double totalExpenses;                // کل هزینه
  double essentialLimit;               // درصد محدودیت ضروری
  double wantsLimit;                   // درصد محدودیت دلخواه
  double savingsLimit;                 // درصد محدودیت پس‌انداز
  List<Map<String, dynamic>> expenses; // لیست هزینه‌ها

  AccountData({
    required this.name,
    this.totalIncome = 0.0,
    this.totalExpenses = 0.0,
    this.essentialLimit = 50.0,
    this.wantsLimit = 30.0,
    this.savingsLimit = 20.0,
    List<Map<String, dynamic>>? expenses,
  }) : expenses = expenses ?? [];
}

/// ویجت اصلی برنامه که لیست حساب‌ها را مدیریت می‌کند و تم (روشن/تاریک) را نگه می‌دارد.
class MultiAccountApp extends StatefulWidget {
  @override
  _MultiAccountAppState createState() => _MultiAccountAppState();
}

class _MultiAccountAppState extends State<MultiAccountApp> {
  ThemeMode _themeMode = ThemeMode.light;

  /// فهرست همه حساب‌های موجود
  List<AccountData> accounts = [];

  /// اندیس حساب انتخاب‌شده
  int? selectedAccountIndex;

  void toggleTheme() {
    setState(() {
      _themeMode =
      _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  /// ساخت یک حساب جدید و افزودن به لیست حساب‌ها
  void createNewAccount(String name) {
    setState(() {
      accounts.add(AccountData(name: name));
    });
  }

  /// انتخاب یک حساب برای ورود به صفحه مدیریت هزینه‌ها
  void selectAccount(int index) {
    setState(() {
      selectedAccountIndex = index;
    });
  }

  /// بازگشت از صفحه مدیریت هزینه‌ها به صفحه انتخاب حساب
  void backToAccountSelection() {
    setState(() {
      selectedAccountIndex = null;
    });
  }

  /// ویرایش نام حساب
  void renameAccount(int index, String newName) {
    setState(() {
      accounts[index].name = newName;
    });
  }

  /// حذف حساب
  void deleteAccount(int index) {
    setState(() {
      accounts.removeAt(index);
    });
  }

  // --- ایجاد تم‌های سفارشی با Material 3 ---
  final ThemeData _lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    scaffoldBackgroundColor: Colors.grey[100],
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    cardTheme: CardTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      margin: EdgeInsets.all(8),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
    ),
  );

  final ThemeData _darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: Colors.grey[900],
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    cardTheme: CardTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      margin: EdgeInsets.all(8),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
    ),
  );
  // --- پایان ایجاد تم‌های سفارشی ---

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: _lightTheme,
      darkTheme: _darkTheme,
      home: selectedAccountIndex == null
          ? AccountSelectionPage(
        accounts: accounts,
        onCreateAccount: createNewAccount,
        onSelectAccount: selectAccount,
        // برای نمایش دکمه دارک‌مود در صفحه انتخاب حساب:
        toggleTheme: toggleTheme,
        themeMode: _themeMode,
        // جدید: کال‌بک‌های ویرایش و حذف حساب
        onRenameAccount: renameAccount,
        onDeleteAccount: deleteAccount,
      )
          : ExpenseTrackerHome(
        account: accounts[selectedAccountIndex!],
        onBack: backToAccountSelection,
        toggleTheme: toggleTheme,
        themeMode: _themeMode,
      ),
    );
  }
}
//Read!
/// صفحه انتخاب حساب یا ایجاد حساب جدید
class AccountSelectionPage extends StatefulWidget {
  final List<AccountData> accounts;
  final Function(String) onCreateAccount;
  final Function(int) onSelectAccount;

  /// موارد اضافه برای تم
  final VoidCallback toggleTheme;
  final ThemeMode themeMode;

  /// جدید: توابع ویرایش و حذف حساب
  final Function(int, String) onRenameAccount;
  final Function(int) onDeleteAccount;

  const AccountSelectionPage({
    Key? key,
    required this.accounts,
    required this.onCreateAccount,
    required this.onSelectAccount,
    required this.toggleTheme,
    required this.themeMode,
    required this.onRenameAccount,
    required this.onDeleteAccount,
  }) : super(key: key);

  @override
  _AccountSelectionPageState createState() => _AccountSelectionPageState();
}

class _AccountSelectionPageState extends State<AccountSelectionPage> {
  void _showCreateAccountDialog() {
    TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('ایجاد حساب جدید'),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'نام حساب',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('لغو'),
            ),
            TextButton(
              onPressed: () {
                 final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  widget.onCreateAccount(name);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('نام حساب نمی‌تواند خالی باشد.')),
                  );
                }
              },
              child: Text('ایجاد'),
            ),
          ],
        );
      },
    );
  }

  /// دیالوگ ویرایش نام حساب
  void _showRenameAccountDialog(int index) {
    final account = widget.accounts[index];
    TextEditingController nameController = TextEditingController(text: account.name);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('ویرایش نام حساب'),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: 'نام جدید حساب'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('لغو'),
            ),
            TextButton(
              onPressed: () {
                final newName = nameController.text.trim();
                if (newName.isNotEmpty) {
                  widget.onRenameAccount(index, newName);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('نام جدید حساب نمی‌تواند خالی باشد.')),
                  );
                }
              },
              child: Text('ذخیره'),
            ),
          ],
        );
      },
    );
  }

  /// دیالوگ تأیید حذف حساب
  void _showDeleteAccountDialog(int index) {
    final account = widget.accounts[index];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('حذف حساب'),
          content: Text('آیا از حذف حساب "${account.name}" اطمینان دارید؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('لغو'),
            ),
            TextButton(
              onPressed: () {
                widget.onDeleteAccount(index);
                Navigator.pop(context);
              },
              child: Text('حذف'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('انتخاب حساب'),
        actions: [
          IconButton(
            icon: Icon(
              widget.themeMode == ThemeMode.light
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: widget.accounts.isEmpty
            ? Center(
          child: Text(
            'هنوز حسابی ایجاد نشده. برای افزودن حساب جدید دکمه زیر را لمس کنید.',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        )
            : ListView.builder(
          itemCount: widget.accounts.length,
          itemBuilder: (context, index) {
            final account = widget.accounts[index];
            return Card(
              child: ListTile(
                title: Text(
                  account.name,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                    'درآمد: ${account.totalIncome} | هزینه: ${account.totalExpenses}'),
                onTap: () => widget.onSelectAccount(index),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'rename') {
                      _showRenameAccountDialog(index);
                    } else if (value == 'delete') {
                      _showDeleteAccountDialog(index);
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem(
                      value: 'rename',
                      child: Text('ویرایش حساب'),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('حذف حساب'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateAccountDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}

/// صفحه مدیریت هزینه‌ها (برای یک حساب خاص)
class ExpenseTrackerHome extends StatefulWidget {
  final AccountData account;
  final VoidCallback onBack;
  final VoidCallback toggleTheme;
  final ThemeMode themeMode;

  ExpenseTrackerHome({
    required this.account,
    required this.onBack,
    required this.toggleTheme,
    required this.themeMode,
  });

  @override
  _ExpenseTrackerHomeState createState() => _ExpenseTrackerHomeState();
}

class _ExpenseTrackerHomeState extends State<ExpenseTrackerHome> {
  String selectedCategory = 'همه';
  List<Map<String, dynamic>> filteredExpenses = [];

  final NumberFormat currencyFormat = NumberFormat("#,##0", "fa");

  @override
  void initState() {
    super.initState();
    filteredExpenses = widget.account.expenses;
  }

  void applyFilters() {
    setState(() {
      if (selectedCategory == 'همه') {
        filteredExpenses = widget.account.expenses;
      } else {
        filteredExpenses = widget.account.expenses
            .where((expense) => expense['category'] == selectedCategory)
            .toList();
      }
    });
  }

  bool validateLimits(String category, double price) {
    double essentialExpenses = widget.account.expenses
        .where((e) => e['category'] == 'ضروری')
        .fold(0.0, (sum, item) => sum + item['price']);
    double wantsExpenses = widget.account.expenses
        .where((e) => e['category'] == 'دلخواه')
        .fold(0.0, (sum, item) => sum + item['price']);
    double savingsExpenses = widget.account.expenses
        .where((e) => e['category'] == 'پس‌انداز')
        .fold(0.0, (sum, item) => sum + item['price']);

    if (category == 'ضروری') essentialExpenses += price;
    if (category == 'دلخواه') wantsExpenses += price;
    if (category == 'پس‌انداز') savingsExpenses += price;

    double essentialPercent = widget.account.totalIncome == 0
        ? 0
        : (essentialExpenses / widget.account.totalIncome) * 100;
    double wantsPercent = widget.account.totalIncome == 0
        ? 0
        : (wantsExpenses / widget.account.totalIncome) * 100;
    double savingsPercent = widget.account.totalIncome == 0
        ? 0
        : (savingsExpenses / widget.account.totalIncome) * 100;

    // بررسی با مقادیر پویا
    return essentialPercent <= widget.account.essentialLimit &&
        wantsPercent <= widget.account.wantsLimit &&
        savingsPercent <= widget.account.savingsLimit;
  }

  void addIncome(double income) {
    setState(() {
      widget.account.totalIncome += income;
    });
  }

  void addExpense(String description, double price, String category) {
    if (widget.account.totalIncome == 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('ابتدا درآمد را وارد کنید.'),
      ));
      return;
    }

    if (validateLimits(category, price)) {
      final currentDateTime =
      DateFormat('yyyy/MM/dd HH:mm').format(DateTime.now());
      setState(() {
        widget.account.expenses.add({
          'description': description,
          'price': price,
          'category': category,
          'dateTime': currentDateTime,
        });
        widget.account.totalExpenses += price;
        applyFilters();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('افزودن رد شد: محدودیت‌های تعیین شده رعایت نمی‌شوند.'),
      ));
    }
  }

  void editExpense(int index, String newDescription, double newPrice,
      String newCategory) {
    final expense = filteredExpenses[index];
    final realIndex = widget.account.expenses.indexOf(expense);
    if (realIndex < 0) return;

    widget.account.totalExpenses -= expense['price'];

    if (validateLimits(newCategory, newPrice)) {
      setState(() {
        widget.account.expenses[realIndex] = {
          'description': newDescription,
          'price': newPrice,
          'category': newCategory,
          'dateTime': expense['dateTime'],
        };
        widget.account.totalExpenses += newPrice;
        applyFilters();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('ویرایش رد شد: محدودیت‌های تعیین شده رعایت نمی‌شوند.'),
      ));
      widget.account.totalExpenses += expense['price'];
    }
  }

  void deleteExpense(int index) {
    final expense = filteredExpenses[index];
    final realIndex = widget.account.expenses.indexOf(expense);
    if (realIndex < 0) return;

    setState(() {
      widget.account.totalExpenses -= expense['price'];
      widget.account.expenses.removeAt(realIndex);
      applyFilters();
    });
  }

  void _showAddIncomeDialog(BuildContext context) {
    TextEditingController incomeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('افزودن درآمد'),
          content: TextField(
            controller: incomeController,
            decoration: InputDecoration(labelText: 'مقدار درآمد'),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              child: Text('لغو'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('افزودن'),
              onPressed: () {
                final parsedValue = double.tryParse(incomeController.text);
                if (parsedValue == null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('لطفا یک مقدار عددی معتبر وارد کنید.'),
                  ));
                  return;
                }
                final income = parsedValue;

                if (income > 0) {
                  addIncome(income);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('مقدار وارد شده نامعتبر است.'),
                  ));
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddExpenseDialog(BuildContext context) {
    TextEditingController descriptionController = TextEditingController();
    TextEditingController priceController = TextEditingController();
    String selectedExpenseCategory = 'ضروری';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('افزودن هزینه'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'توضیحات'),
              ),
              TextField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'مقدار'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              DropdownButton<String>(
                value: selectedExpenseCategory,
                isExpanded: true,
                onChanged: (value) {
                  setState(() {
                    selectedExpenseCategory = value!;
                  });
                },
                items: ['ضروری', 'دلخواه', 'پس‌انداز']
                    .map((category) => DropdownMenuItem(
                  child: Text(category),
                  value: category,
                ))
                    .toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('لغو'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('افزودن'),
              onPressed: () {
                final parsedValue = double.tryParse(priceController.text);
                if (parsedValue == null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('لطفا یک مقدار عددی معتبر وارد کنید.'),
                  ));
                  return;
                }
                final price = parsedValue;

                final description = descriptionController.text;

                if (description.isNotEmpty && price > 0) {
                  addExpense(description, price, selectedExpenseCategory);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('ورودی نامعتبر است.'),
                  ));
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditExpenseDialog(BuildContext context, int index) {
    final expense = filteredExpenses[index];
    TextEditingController descriptionController =
    TextEditingController(text: expense['description']);
    TextEditingController priceController =
    TextEditingController(text: expense['price'].toString());
    String selectedExpenseCategory = expense['category'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('ویرایش هزینه'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'توضیحات'),
              ),
              TextField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'مقدار'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              DropdownButton<String>(
                value: selectedExpenseCategory,
                isExpanded: true,
                onChanged: (value) {
                  setState(() {
                    selectedExpenseCategory = value!;
                  });
                },
                items: ['ضروری', 'دلخواه', 'پس‌انداز']
                    .map((category) => DropdownMenuItem(
                  child: Text(category),
                  value: category,
                ))
                    .toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('لغو'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('ذخیره'),
              onPressed: () {
                final parsedValue = double.tryParse(priceController.text);
                if (parsedValue == null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('لطفا یک مقدار عددی معتبر وارد کنید.'),
                  ));
                  return;
                }
                final newPrice = parsedValue;

                final newDescription = descriptionController.text;

                if (newDescription.isNotEmpty && newPrice > 0) {
                  editExpense(index, newDescription, newPrice, selectedExpenseCategory);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('ورودی نامعتبر است.'),
                  ));
                }
              },
            ),
          ],
        );
      },
    );
  }

  /// دیالوگ تنظیم درصدهای محدودیت
  void _showSetLimitsDialog(BuildContext context) {
    TextEditingController essentialController =
    TextEditingController(text: widget.account.essentialLimit.toString());
    TextEditingController wantsController =
    TextEditingController(text: widget.account.wantsLimit.toString());
    TextEditingController savingsController =
    TextEditingController(text: widget.account.savingsLimit.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('تنظیم درصدها'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: essentialController,
                  decoration: InputDecoration(labelText: 'درصد ضروری'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: wantsController,
                  decoration: InputDecoration(labelText: 'درصد دلخواه'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: savingsController,
                  decoration: InputDecoration(labelText: 'درصد پس‌انداز'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('لغو'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('ذخیره'),
              onPressed: () {
                final eLimit = double.tryParse(essentialController.text) ?? -1;
                final wLimit = double.tryParse(wantsController.text) ?? -1;
                final sLimit = double.tryParse(savingsController.text) ?? -1;

                // بررسی نامعتبر بودن یا بزرگتر بودن مجموع از 100
                if (eLimit < 0 ||
                    wLimit < 0 ||
                    sLimit < 0 ||
                    (eLimit + wLimit + sLimit) > 100) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        'مقادیر نامعتبر هستند یا مجموع از 100 درصد فراتر رفته است.'),
                  ));
                } else {
                  setState(() {
                    widget.account.essentialLimit = eLimit;
                    widget.account.wantsLimit = wLimit;
                    widget.account.savingsLimit = sLimit;
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.attach_money),
                title: Text('افزودن درآمد'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showAddIncomeDialog(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.shopping_cart),
                title: Text('افزودن هزینه'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showAddExpenseDialog(context);
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('تنظیم درصدها'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showSetLimitsDialog(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final account = widget.account;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: widget.onBack, // بازگشت به انتخاب حساب
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(
                widget.themeMode == ThemeMode.light
                    ? Icons.dark_mode
                    : Icons.light_mode,
                color: Colors.white,
              ),
              onPressed: widget.toggleTheme,
            ),
            Text('مدیریت هزینه‌ها (${account.name})'),
            SizedBox(width: 48), // برای حفظ تراز
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 4,
              margin: EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'کل درآمد: ${currencyFormat.format(account.totalIncome)} تومان',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'مانده حساب: ${currencyFormat.format(account.totalIncome - account.totalExpenses)} تومان',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700]),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'لیست هزینه‌ها',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                DropdownButton<String>(
                  value: selectedCategory,
                  onChanged: (value) {
                    selectedCategory = value!;
                    applyFilters();
                  },
                  items: ['همه', 'ضروری', 'دلخواه', 'پس‌انداز']
                      .map(
                        (category) => DropdownMenuItem(
                      child: Text(category),
                      value: category,
                    ),
                  )
                      .toList(),
                ),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: filteredExpenses.isEmpty
                  ? Center(
                child: Text(
                  'هیچ هزینه‌ای یافت نشد!',
                  style: TextStyle(fontSize: 16),
                ),
              )
                  : ListView.builder(
                itemCount: filteredExpenses.length,
                itemBuilder: (context, index) {
                  final expense = filteredExpenses[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 8.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // شرح هزینه
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                expense['description'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '[${expense['category']}] '
                                    '${currencyFormat.format(expense['price'])} تومان',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                '(${expense['dateTime']})',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blueGrey,
                                ),
                              ),
                            ],
                          ),
                          // آیکن‌های ویرایش و حذف
                          Row(
                            children: [
                              IconButton(
                                icon:
                                Icon(Icons.edit, color: Colors.blue),
                                onPressed: () =>
                                    _showEditExpenseDialog(context, index),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => deleteExpense(index),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showBottomSheet(context),
      ),
    );
  }
}
