import 'package:flutter/material.dart';

class MyOrderPage extends StatefulWidget {
  @override
  _MyOrderPageState createState() => _MyOrderPageState();
}

class _MyOrderPageState extends State<MyOrderPage> {
  final List<Map<String, String>> orders = [
    {
      "customerName": "خالد أحمد",
      "customerPhone": "0123456789",
      "serviceType": "منتجات",
      "address": "شارع الملك فهد، الرياض",
      "quantity": "15",
      "status": "مكتمل"
    },
    {
      "customerName": "ليلى محمد",
      "customerPhone": "9876543210",
      "serviceType": "خدمات",
      "address": "شارع الجامعة، جدة",
      "quantity": "",
      "status": "قيد التنفيذ"
    },
  ];

  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> filteredOrders = orders.where((order) {
      return order["customerName"]!
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          order["serviceType"]!
              .toLowerCase()
              .contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "الطلبات",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF556B2F), Color(0xFFA8D5BA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          const SizedBox(height: 10),
          Expanded(
            child: filteredOrders.isNotEmpty
                ? ListView.builder(
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      return _buildOrderCard(context, filteredOrders[index]);
                    },
                  )
                : const Center(
                    child: Text(
                      "لا يوجد طلبات مطابقة للبحث",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: Directionality(
        textDirection: TextDirection.rtl,
        child: FloatingActionButton(
          backgroundColor: const Color(0xFFFFFFFF),
          onPressed: () {
            _showAddOrderDialog();
          },
          child: const Icon(Icons.add, size: 30, color: Color(0xFF556B2F)),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: "ابحث عن اسم العميل أو نوع الخدمة...",
            prefixIcon: const Icon(Icons.search, color: Color(0xFF556B2F)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(15),
          ),
          onChanged: (value) {
            setState(() {
              searchQuery = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Map<String, String> order) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            orders.remove(order);
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Color(0xFF4CAF50)),
                        onPressed: () {
                          _showEditOrderDialog(order);
                        },
                      ),
                    ],
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          order["customerName"]!,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF556B2F),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const CircleAvatar(
                          backgroundColor: Color(0xFF556B2F),
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.grey),
              _buildDetailRow(
                icon: Icons.phone,
                label: "رقم العميل",
                value: order["customerPhone"]!,
              ),
              _buildDetailRow(
                icon: Icons.build,
                label: "نوع الخدمة",
                value: order["serviceType"]!,
              ),
              _buildDetailRow(
                icon: Icons.location_on,
                label: "العنوان",
                value: order["address"]!,
              ),
              _buildDetailRow(
                icon: Icons.inventory,
                label: "الكمية",
                value: order["quantity"]!,
              ),
              _buildDetailRow(
                icon: Icons.info,
                label: "الحالة",
                value: order["status"]!,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              "$label: $value",
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
          const SizedBox(width: 10),
          Icon(icon, color: const Color(0xFF556B2F)),
        ],
      ),
    );
  }

  void _showAddOrderDialog() {
    String customerName = "";
    String customerPhone = "";
    String serviceType = "";
    String address = "";
    String quantity = "";
    String status = "";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("إضافة طلب جديد"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: "اسم العميل"),
                  onChanged: (value) => customerName = value,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: "رقم العميل"),
                  onChanged: (value) => customerPhone = value,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: "نوع الخدمة"),
                  onChanged: (value) => serviceType = value,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: "العنوان"),
                  onChanged: (value) => address = value,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: "الكمية"),
                  onChanged: (value) => quantity = value,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: "الحالة"),
                  onChanged: (value) => status = value,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("إلغاء",
                  style: TextStyle(color: Color(0xFF556B2F))),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  orders.add({
                    "customerName": customerName,
                    "customerPhone": customerPhone,
                    "serviceType": serviceType,
                    "address": address,
                    "quantity": quantity,
                    "status": status,
                  });
                });
                Navigator.of(context).pop();
              },
              child: const Text("إضافة",
                  style: TextStyle(color: Color(0xFF556B2F))),
            ),
          ],
        );
      },
    );
  }

  void _showEditOrderDialog(Map<String, String> order) {
    String customerName = order["customerName"]!;
    String customerPhone = order["customerPhone"]!;
    String serviceType = order["serviceType"]!;
    String address = order["address"]!;
    String quantity = order["quantity"]!;
    String status = order["status"]!;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("تعديل معلومات الطلب"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: "اسم العميل"),
                  controller: TextEditingController(text: customerName),
                  onChanged: (value) => customerName = value,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: "رقم العميل"),
                  controller: TextEditingController(text: customerPhone),
                  onChanged: (value) => customerPhone = value,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: "نوع الخدمة"),
                  controller: TextEditingController(text: serviceType),
                  onChanged: (value) => serviceType = value,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: "العنوان"),
                  controller: TextEditingController(text: address),
                  onChanged: (value) => address = value,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: "الكمية"),
                  controller: TextEditingController(text: quantity),
                  onChanged: (value) => quantity = value,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: "الحالة"),
                  controller: TextEditingController(text: status),
                  onChanged: (value) => status = value,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("إلغاء",
                  style: TextStyle(color: Color(0xFF556B2F))),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  order["customerName"] = customerName;
                  order["customerPhone"] = customerPhone;
                  order["serviceType"] = serviceType;
                  order["address"] = address;
                  order["quantity"] = quantity;
                  order["status"] = status;
                });
                Navigator.of(context).pop();
              },
              child: const Text("تعديل",
                  style: TextStyle(color: Color(0xFF556B2F))),
            ),
          ],
        );
      },
    );
  }
}
