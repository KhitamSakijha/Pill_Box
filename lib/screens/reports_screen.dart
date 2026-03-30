import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pill_box/models/Medicine.dart';
import 'package:pill_box/services/medicine_service.dart';
//import '../services/medicine_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool isWeekly = true;
  List<Medicine> medicines = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);
    try {
      medicines = await MedicineService.getAll();
      // أضيفي هذا السطر للتحقق من عدد الأدوية التي وصلت
      print("Fetched medicines count: ${medicines.length}");
    } catch (e) {
      print("Error loading data: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  /*Future<void> loadData() async {
    setState(() => isLoading = true);

    await Future.delayed(const Duration(seconds: 1));

    // بيانات وهمية متوافقة مع الموديل الخاص بكِ
    medicines = [
      Medicine(
        id: '1',
        userId: 'user123',
        name: 'بندول (Panadol)',
        dose: '500mg',
        frequency: 'Daily',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 7)),
        times: ['08:00'],
        isActive: true, // مأخوذ (ستظهر باللون الأخضر في التقرير)
      ),
      Medicine(
        id: '2',
        userId: 'user123',
        name: 'فيتامين سي',
        dose: '1000mg',
        frequency: 'Daily',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        times: <TimeOfDay>['09:00'],
        isActive: false, // متأخر (ستظهر باللون البرتقالي في التقرير)
      ),
    ];

    setState(() => isLoading = false);
  }*/

  // ================= الحسابات المنطقية =================
  int get totalDoses => medicines.length;

  // نعتبر الجرعة مأخوذة إذا كان isActive صحيحاً (كمرحلة مؤقتة)
  int get takenDoses => medicines.where((m) => m.isActive).length;

  int get lateDoses => totalDoses - takenDoses;

  double get adherenceRate =>
      totalDoses == 0 ? 0 : (takenDoses / totalDoses) * 100;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F7FB),
      appBar: AppBar(
        title: const Text('Reports'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : medicines.isEmpty
          ? _buildEmptyState()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _periodSelector(),
                  const SizedBox(height: 20),
                  _adherenceHeader(),
                  const SizedBox(height: 20),
                  _chartsRow(),
                  const SizedBox(height: 30),
                  _medicationDetails(),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'No data available yet.\nAdd medicines to see your reports.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  // ================= اختيار الفترة =================
  Widget _periodSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _periodButton('Weekly', true),
          _periodButton('Monthly', false),
        ],
      ),
    );
  }

  Widget _periodButton(String text, bool weekly) {
    final bool selected = isWeekly == weekly;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => isWeekly = weekly),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? Colors.blue : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // ================= رأس الصفحة =================
  Widget _adherenceHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Adherence Rate',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              SizedBox(height: 4),
              Text(
                'Overall Progress',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Text(
            '${adherenceRate.toStringAsFixed(0)}%',
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 28,
            ),
          ),
        ],
      ),
    );
  }

  // ================= الرسوم البيانية =================
  Widget _chartsRow() {
    return Row(
      children: [
        Expanded(
          child: _circleChart(
            'On-time',
            adherenceRate,
            Colors.green,
            isPercent: true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _circleChart(
            'Late Doses',
            lateDoses.toDouble(),
            Colors.orange,
            isPercent: false,
          ),
        ),
      ],
    );
  }

  Widget _circleChart(
    String title,
    double value,
    Color color, {
    required bool isPercent,
  }) {
    // حساب النسبة المتبقية لتكملة الدائرة
    double totalForChart = isPercent ? 100 : totalDoses.toDouble();
    if (totalForChart == 0) totalForChart = 1; // لتجنب القسمة على صفر

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: PieChart(
              PieChartData(
                sectionsSpace: 0,
                centerSpaceRadius: 25,
                startDegreeOffset: -90,
                sections: [
                  PieChartSectionData(
                    value: value,
                    color: color,
                    radius: 12,
                    showTitle: false,
                  ),
                  PieChartSectionData(
                    value: totalForChart - value,
                    color: Colors.grey[100],
                    radius: 12,
                    showTitle: false,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isPercent ? '${value.toStringAsFixed(0)}%' : '${value.toInt()}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  // ================= تفاصيل الأدوية =================
  Widget _medicationDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Medication Details',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: medicines.length,
          itemBuilder: (context, index) {
            final m = medicines[index];
            final bool isOnTime = m.isActive;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: isOnTime
                        ? Colors.green[50]
                        : Colors.orange[50],
                    child: Icon(
                      isOnTime ? Icons.check : Icons.access_time,
                      color: isOnTime ? Colors.green : Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          isOnTime ? 'On time' : 'Late dose',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    isOnTime ? '100%' : '0%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isOnTime ? Colors.green : Colors.orange,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  void medicine({required String name, required bool isActive}) {}
}



/*import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/Medicine.dart';
import '../services/medicine_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool isWeekly = true;
  List<Medicine> medicines = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    medicines = await MedicineService.getAll();
    setState(() {});
  }

  int get totalDoses => medicines.length;
  int get takenDoses => medicines.where((m) => m.isActive).length;
  int get lateDoses => totalDoses - takenDoses;

  double get adherenceRate =>
      totalDoses == 0 ? 0 : (takenDoses / totalDoses) * 100;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F7FB),
      appBar: AppBar(
        title: const Text('Reports'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _periodSelector(),
            const SizedBox(height: 16),
            _adherenceHeader(),
            const SizedBox(height: 16),
            _chartsRow(),
            const SizedBox(height: 24),
            _medicationDetails(),
          ],
        ),
      ),
    );
  }

  // ================= Period =================
  Widget _periodSelector() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _periodButton('Weekly', true),
          _periodButton('Monthly', false),
        ],
      ),
    );
  }

  Widget _periodButton(String text, bool weekly) {
    final selected = isWeekly == weekly;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => isWeekly = weekly),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.blue : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // ================= Header =================
  Widget _adherenceHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Adherence Rate',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            '${adherenceRate.toStringAsFixed(0)}%',
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // ================= Charts =================
  Widget _chartsRow() {
    return Row(
      children: [
        Expanded(child: _circleChart('On-time', adherenceRate, Colors.green)),
        const SizedBox(width: 12),
        Expanded(
          child: _circleChart(
            'Late Doses',
            lateDoses.toDouble(),
            Colors.orange,
            showPercent: false,
          ),
        ),
      ],
    );
  }

  Widget _circleChart(
    String title,
    double value,
    Color color, {
    bool showPercent = true,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: value,
                    color: color,
                    radius: 18,
                    title: showPercent
                        ? '${value.toStringAsFixed(0)}%'
                        : '$value',
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PieChartSectionData(
                    value: showPercent ? 100 - value : totalDoses.toDouble(),
                    color: Colors.grey.shade200,
                    radius: 18,
                    title: '',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= Details =================
  Widget _medicationDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Medication Details',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        ...medicines.map((m) {
          final percent = m.isActive ? 100 : 0;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(m.name),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$percent%',
                      style: TextStyle(
                        color: percent == 100 ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      percent == 100 ? 'On time' : 'Late dose',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
*/