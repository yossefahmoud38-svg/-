import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

const green = Color(0xFF087F5B);
const gold = Color(0xFFD6A84F);
const cream = Color(0xFFF6F8F5);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MosqueDb.instance.database;
  runApp(const MasjidApp());
}

class MasjidApp extends StatelessWidget {
  const MasjidApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'مسجد أبو بكر الصديق',
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: green),
      scaffoldBackgroundColor: cream,
      appBarTheme: const AppBarTheme(backgroundColor: green, foregroundColor: Colors.white, centerTitle: true),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      ),
    ),
    home: const MainShell(),
  );
}

class MosqueDb {
  MosqueDb._();
  static final instance = MosqueDb._();
  Database? _db;
  Future<Database> get database async {
    if (_db != null) return _db!;
    final base = await getDatabasesPath();
    _db = await openDatabase(p.join(base, 'masjid_abu_bakr.db'), version: 1,
      onCreate: (db, version) async {
        await db.execute('CREATE TABLE transactions (id INTEGER PRIMARY KEY AUTOINCREMENT, type TEXT NOT NULL, person TEXT NOT NULL, amount REAL NOT NULL, date TEXT NOT NULL, note TEXT)');
        await db.execute('CREATE TABLE tasks (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, done INTEGER NOT NULL DEFAULT 0)');
        await db.execute('CREATE TABLE supplies (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, quantity TEXT NOT NULL, done INTEGER NOT NULL DEFAULT 0)');
        await db.execute('CREATE TABLE announcements (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, body TEXT NOT NULL, date TEXT NOT NULL)');
        final tasks = ['تنظيف أرضية المسجد','تنظيف دورات المياه','ترتيب المصاحف','تفقد أماكن الوضوء','تفقد المراوح والتكييف'];
        for (final t in tasks) { await db.insert('tasks', {'title': t, 'done': 0}); }
      });
    return _db!;
  }
  Future<List<Map<String,Object?>>> all(String table, {String orderBy = 'id DESC'}) async => (await database).query(table, orderBy: orderBy);
  Future<int> add(String table, Map<String,Object?> values) async => (await database).insert(table, values);
  Future<int> update(String table, int id, Map<String,Object?> values) async => (await database).update(table, values, where: 'id = ?', whereArgs: [id]);
  Future<int> remove(String table, int id) async => (await database).delete(table, where: 'id = ?', whereArgs: [id]);
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override State<MainShell> createState() => _MainShellState();
}
class _MainShellState extends State<MainShell> {
  int index = 0;
  final pages = const [HomePage(), CleaningPage(), SuppliesPage(), AnnouncementsPage(), AccountsPage()];
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('مسجد أبو بكر الصديق', style: TextStyle(fontWeight: FontWeight.bold))),
    body: pages[index],
    bottomNavigationBar: NavigationBar(
      selectedIndex: index, onDestinationSelected: (v) => setState(() => index = v),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'الرئيسية'),
        NavigationDestination(icon: Icon(Icons.cleaning_services_outlined), label: 'النظافة'),
        NavigationDestination(icon: Icon(Icons.inventory_2_outlined), label: 'المستلزمات'),
        NavigationDestination(icon: Icon(Icons.campaign_outlined), label: 'الإعلانات'),
        NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), label: 'الحسابات'),
      ],
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(18), children: [
    Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), gradient: const LinearGradient(colors: [green, Color(0xFF064D3A)])),
      child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.mosque, color: gold, size: 42), SizedBox(height: 12),
        Text('أهلاً بك في', style: TextStyle(color: Colors.white70, fontSize: 16)),
        Text('مسجد أبو بكر الصديق', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold)),
        SizedBox(height: 8), Text('إدارة يومية منظمة لشؤون المسجد', style: TextStyle(color: Colors.white70)),
      ]),
    ),
    const SizedBox(height: 18),
    const _HomeCard(icon: Icons.account_balance_wallet, title: 'الحسابات المالية', subtitle: 'سجل الوارد والمنصرف وتابع الرصيد'),
    const _HomeCard(icon: Icons.cleaning_services, title: 'النظافة اليومية', subtitle: 'علّم المهام التي تم إنجازها'),
    const _HomeCard(icon: Icons.inventory_2, title: 'مستلزمات المسجد', subtitle: 'سجّل المستلزمات والكميات'),
    const _HomeCard(icon: Icons.campaign, title: 'الإعلانات', subtitle: 'احتفظ بإعلانات المسجد داخل التطبيق'),
    const SizedBox(height: 8),
    const Text('تنبيه: مواقيت الصلاة والأذان والنسخ الاحتياطي والاستعادة لم تُفعّل بعد في هذه النسخة.', style: TextStyle(color: Colors.black54)),
  ]);
}
class _HomeCard extends StatelessWidget {
  final IconData icon; final String title, subtitle;
  const _HomeCard({required this.icon, required this.title, required this.subtitle});
  @override Widget build(BuildContext context) => Card(color: Colors.white, elevation: 0, margin: const EdgeInsets.only(bottom: 10), child: ListTile(
    leading: CircleAvatar(backgroundColor: const Color(0xFFE2F2EA), child: Icon(icon, color: green)),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text(subtitle)));
}

class CleaningPage extends StatefulWidget {
  const CleaningPage({super.key});
  @override State<CleaningPage> createState() => _CleaningPageState();
}
class _CleaningPageState extends State<CleaningPage> {
  late Future<List<Map<String,Object?>>> future;
  @override void initState() { super.initState(); future = MosqueDb.instance.all('tasks', orderBy: 'id ASC'); }
  void refresh() => setState(() => future = MosqueDb.instance.all('tasks', orderBy: 'id ASC'));
  Future<void> addTask() async {
    final c = TextEditingController();
    final value = await showDialog<String>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('إضافة مهمة'), content: TextField(controller: c, autofocus: true, decoration: const InputDecoration(labelText: 'اسم المهمة')),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')), FilledButton(onPressed: () => Navigator.pop(ctx, c.text.trim()), child: const Text('إضافة'))]));
    if (value != null && value.isNotEmpty) { await MosqueDb.instance.add('tasks', {'title': value, 'done': 0}); refresh(); }
  }
  @override Widget build(BuildContext context) => FutureBuilder<List<Map<String,Object?>>>(
    future: future, builder: (context, snap) {
      final rows = snap.data ?? [];
      final done = rows.where((e) => e['done'] == 1).length;
      return ListView(padding: const EdgeInsets.all(16), children: [
        Row(children: [const Expanded(child: Text('النظافة اليومية', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))), IconButton(onPressed: addTask, icon: const Icon(Icons.add_circle, color: green, size: 30))]),
        Text('تم إنجاز $done من ${rows.length} مهام', style: const TextStyle(color: Colors.black54)), const SizedBox(height: 10),
        ...rows.map((row) => Card(color: Colors.white, elevation: 0, child: CheckboxListTile(
          activeColor: green, value: row['done'] == 1, title: Text('${row['title']}'),
          onChanged: (v) async { await MosqueDb.instance.update('tasks', row['id'] as int, {'done': v == true ? 1 : 0}); refresh(); },
          secondary: IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: () async { await MosqueDb.instance.remove('tasks', row['id'] as int); refresh(); }),
        ))),
      ]);
    });
}

class SuppliesPage extends StatefulWidget {
  const SuppliesPage({super.key});
  @override State<SuppliesPage> createState() => _SuppliesPageState();
}
class _SuppliesPageState extends State<SuppliesPage> {
  late Future<List<Map<String,Object?>>> future;
  @override void initState() { super.initState(); future = MosqueDb.instance.all('supplies'); }
  void refresh() => setState(() => future = MosqueDb.instance.all('supplies'));
  Future<void> addSupply() async {
    final title = TextEditingController(); final quantity = TextEditingController();
    final values = await showDialog<List<String>>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('إضافة مستلزم'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: title, decoration: const InputDecoration(labelText: 'اسم المستلزم')),
        const SizedBox(height: 10), TextField(controller: quantity, decoration: const InputDecoration(labelText: 'الكمية / ملاحظة')),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')), FilledButton(onPressed: () => Navigator.pop(ctx, [title.text.trim(), quantity.text.trim()]), child: const Text('حفظ'))]));
    if (values != null && values[0].isNotEmpty) { await MosqueDb.instance.add('supplies', {'title': values[0], 'quantity': values[1], 'done': 0}); refresh(); }
  }
  @override Widget build(BuildContext context) => FutureBuilder<List<Map<String,Object?>>>(
    future: future, builder: (context, snap) {
      final rows = snap.data ?? [];
      return ListView(padding: const EdgeInsets.all(16), children: [
        Row(children: [const Expanded(child: Text('مستلزمات المسجد', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))), IconButton(onPressed: addSupply, icon: const Icon(Icons.add_circle, color: green, size: 30))]),
        if (rows.isEmpty) const Card(color: Colors.white, child: Padding(padding: EdgeInsets.all(20), child: Text('لا توجد مستلزمات مضافة. اضغط + لإضافة أول مستلزم.'))),
        ...rows.map((row) => Card(color: Colors.white, elevation: 0, child: CheckboxListTile(
          value: row['done'] == 1, activeColor: green, title: Text('${row['title']}'), subtitle: Text('الكمية: ${row['quantity']}'),
          onChanged: (v) async { await MosqueDb.instance.update('supplies', row['id'] as int, {'done': v == true ? 1 : 0}); refresh(); },
          secondary: IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: () async { await MosqueDb.instance.remove('supplies', row['id'] as int); refresh(); }),
        ))),
      ]);
    });
}

class AnnouncementsPage extends StatefulWidget {
  const AnnouncementsPage({super.key});
  @override State<AnnouncementsPage> createState() => _AnnouncementsPageState();
}
class _AnnouncementsPageState extends State<AnnouncementsPage> {
  late Future<List<Map<String,Object?>>> future;
  @override void initState() { super.initState(); future = MosqueDb.instance.all('announcements', orderBy: 'date DESC'); }
  void refresh() => setState(() => future = MosqueDb.instance.all('announcements', orderBy: 'date DESC'));
  Future<void> addAnnouncement() async {
    final title = TextEditingController(); final body = TextEditingController();
    final values = await showDialog<List<String>>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('إعلان جديد'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: title, decoration: const InputDecoration(labelText: 'عنوان الإعلان')),
        const SizedBox(height: 10), TextField(controller: body, maxLines: 4, decoration: const InputDecoration(labelText: 'نص الإعلان')),
      ])),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')), FilledButton(onPressed: () => Navigator.pop(ctx, [title.text.trim(), body.text.trim()]), child: const Text('حفظ'))]));
    if (values != null && values[0].isNotEmpty && values[1].isNotEmpty) {
      await MosqueDb.instance.add('announcements', {'title': values[0], 'body': values[1], 'date': DateFormat('yyyy-MM-dd').format(DateTime.now())}); refresh();
    }
  }
  @override Widget build(BuildContext context) => FutureBuilder<List<Map<String,Object?>>>(
    future: future, builder: (context, snap) {
      final rows = snap.data ?? [];
      return ListView(padding: const EdgeInsets.all(16), children: [
        Row(children: [const Expanded(child: Text('إعلانات المسجد', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))), IconButton(onPressed: addAnnouncement, icon: const Icon(Icons.add_circle, color: green, size: 30))]),
        if (rows.isEmpty) const Card(color: Colors.white, child: Padding(padding: EdgeInsets.all(20), child: Text('لا توجد إعلانات محفوظة حتى الآن.'))),
        ...rows.map((row) => Card(color: Colors.white, elevation: 0, child: ListTile(
          title: Text('${row['title']}', style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text('${row['date']}\n${row['body']}'), isThreeLine: true,
          trailing: IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: () async { await MosqueDb.instance.remove('announcements', row['id'] as int); refresh(); }),
        ))),
      ]);
    });
}

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});
  @override State<AccountsPage> createState() => _AccountsPageState();
}
class _AccountsPageState extends State<AccountsPage> {
  late Future<List<Map<String,Object?>>> future;
  final money = NumberFormat('#,##0.##', 'en');
  @override void initState() { super.initState(); future = MosqueDb.instance.all('transactions', orderBy: 'date DESC, id DESC'); }
  void refresh() => setState(() => future = MosqueDb.instance.all('transactions', orderBy: 'date DESC, id DESC'));
  @override Widget build(BuildContext context) => FutureBuilder<List<Map<String,Object?>>>(
    future: future, builder: (context, snap) {
      final rows = snap.data ?? [];
      double incoming = 0, outgoing = 0;
      for (final r in rows) { final a = (r['amount'] as num).toDouble(); if (r['type'] == 'وارد') incoming += a; else outgoing += a; }
      return ListView(padding: const EdgeInsets.all(16), children: [
        const Text('الحسابات المالية', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), const SizedBox(height: 12),
        Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: green, borderRadius: BorderRadius.circular(20)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('الرصيد الحالي', style: TextStyle(color: Colors.white70)),
          Text('${money.format(incoming-outgoing)} جنيه', style: const TextStyle(color: Colors.white, fontSize: 29, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12), Row(children: [
            Expanded(child: _Summary(title: 'إجمالي الوارد', value: incoming, fmt: money)),
            const SizedBox(width: 12), Expanded(child: _Summary(title: 'إجمالي المنصرف', value: outgoing, fmt: money)),
          ]),
        ])),
        const SizedBox(height: 12),
        FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: green, padding: const EdgeInsets.all(14)),
          onPressed: () async { final ok = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => const AddTransactionPage())); if (ok == true) refresh(); },
          icon: const Icon(Icons.add), label: const Text('تسجيل حركة مالية جديدة')),
        const SizedBox(height: 14), const Text('سجل الحركات', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
        if (rows.isEmpty) const Card(color: Colors.white, child: Padding(padding: EdgeInsets.all(18), child: Text('لا توجد حركات مالية مسجلة.'))),
        ...rows.map((r) {
          final isIn = r['type'] == 'وارد'; final amount = (r['amount'] as num).toDouble();
          return Card(color: Colors.white, elevation: 0, child: ListTile(
            leading: CircleAvatar(backgroundColor: isIn ? const Color(0xFFE2F2EA) : const Color(0xFFFFE8E5), child: Icon(isIn ? Icons.south_west : Icons.north_east, color: isIn ? green : Colors.red)),
            title: Text('${r['person']} • ${r['type']}', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${r['date']}${(r['note'] as String?)?.isNotEmpty == true ? '\n${r['note']}' : ''}'),
            isThreeLine: (r['note'] as String?)?.isNotEmpty == true,
            trailing: Text('${money.format(amount)} ج.م', style: TextStyle(color: isIn ? green : Colors.red, fontWeight: FontWeight.bold)),
            onLongPress: () async {
              final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: const Text('حذف الحركة؟'), content: const Text('هل تريد حذف الحركة المالية؟'), actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
                FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('حذف')),
              ]));
              if (ok == true) { await MosqueDb.instance.remove('transactions', r['id'] as int); refresh(); }
            },
          ));
        }),
        const SizedBox(height: 8),
        const Text('البيانات محفوظة محليًا على هذا الهاتف. لا توجد حركات افتراضية؛ الرصيد يبدأ من صفر ويُحسب من الحركات التي تسجلها.', style: TextStyle(fontSize: 12, color: Colors.black54)),
      ]);
    });
}
class _Summary extends StatelessWidget {
  final String title; final double value; final NumberFormat fmt;
  const _Summary({required this.title, required this.value, required this.fmt});
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .12), borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)), const SizedBox(height: 5),
    Text('${fmt.format(value)} ج.م', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
  ]));
}

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});
  @override State<AddTransactionPage> createState() => _AddTransactionPageState();
}
class _AddTransactionPageState extends State<AddTransactionPage> {
  final keyForm = GlobalKey<FormState>();
  final person = TextEditingController(), amount = TextEditingController(), note = TextEditingController();
  String type = 'وارد'; DateTime date = DateTime.now(); bool saving = false;
  @override void dispose() { person.dispose(); amount.dispose(); note.dispose(); super.dispose(); }
  Future<void> chooseDate() async {
    final d = await showDatePicker(context: context, initialDate: date, firstDate: DateTime(2020), lastDate: DateTime(2100), helpText: 'اختار تاريخ الحركة');
    if (d != null) setState(() => date = d);
  }
  Future<void> save() async {
    if (!keyForm.currentState!.validate()) return;
    setState(() => saving = true);
    try {
      await MosqueDb.instance.add('transactions', {
        'type': type, 'person': person.text.trim(),
        'amount': double.parse(amount.text.trim().replaceAll(',', '.')),
        'date': DateFormat('yyyy-MM-dd').format(date),
        'note': note.text.trim().isEmpty ? null : note.text.trim(),
      });
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) { setState(() => saving = false); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تعذر الحفظ: $e'))); }
    }
  }
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('تسجيل حركة مالية')),
    body: Form(key: keyForm, child: ListView(padding: const EdgeInsets.all(18), children: [
      SegmentedButton<String>(segments: const [
        ButtonSegment(value: 'وارد', label: Text('وارد'), icon: Icon(Icons.south_west)),
        ButtonSegment(value: 'منصرف', label: Text('منصرف'), icon: Icon(Icons.north_east)),
      ], selected: {type}, onSelectionChanged: (v) => setState(() => type = v.first)),
      const SizedBox(height: 18),
      TextFormField(controller: person, textDirection: TextDirection.rtl, decoration: const InputDecoration(labelText: 'الاسم', prefixIcon: Icon(Icons.person_outline)), validator: (v) => v == null || v.trim().isEmpty ? 'اكتب الاسم' : null),
      const SizedBox(height: 12),
      TextFormField(controller: amount, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'المبلغ بالجنيه المصري', prefixIcon: Icon(Icons.payments_outlined), suffixText: 'ج.م'),
        validator: (v) { final n = double.tryParse((v ?? '').trim().replaceAll(',', '.')); return n == null || n <= 0 ? 'اكتب مبلغًا صحيحًا أكبر من صفر' : null; }),
      const SizedBox(height: 12),
      OutlinedButton.icon(onPressed: chooseDate, icon: const Icon(Icons.calendar_month), label: Text('التاريخ: ${DateFormat('yyyy-MM-dd').format(date)}'), style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(14))),
      const SizedBox(height: 12),
      TextFormField(controller: note, maxLines: 3, decoration: const InputDecoration(labelText: 'البيان (اختياري)', prefixIcon: Icon(Icons.notes))),
      const SizedBox(height: 22),
      FilledButton.icon(onPressed: saving ? null : save, icon: const Icon(Icons.save_outlined), label: Text(saving ? 'جارٍ الحفظ...' : 'حفظ الحركة'), style: FilledButton.styleFrom(backgroundColor: green, padding: const EdgeInsets.all(15))),
    ])),
  );
}
