import 'package:creation_edge/utils/constance.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:loading_animation_widget/loading_animation_widget.dart';

class DeliveryOrder extends StatefulWidget {
  @override
  _DeliveryOrderState createState() => _DeliveryOrderState();
}

class _DeliveryOrderState extends State<DeliveryOrder> {
  List<dynamic> _orders = []; // Stores API response data
  bool _isLoading = true; // Loading indicator

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      final response = await http.get(
        Uri.parse('https://girlsparadisebd.com/api/v1/deliverd_orders'),
        headers: {"Authorization": "Bearer $accessToken"},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          _orders = jsonData['data'];
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      print(e);
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? LoadingAnimationWidget.progressiveDots(color: Color(0xFFdc1212), size: 30)
        : SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: DataTable(
            border: TableBorder.all(color: Colors.grey),
            columns: const [
              DataColumn(label: Text('Date')),
              DataColumn(label: Text('Order No')),
              DataColumn(label: Text('Quantity')),
              DataColumn(label: Text('Total')),
              DataColumn(label: Text('Discount')),
              DataColumn(label: Text('Coupon')),
              DataColumn(label: Text('Gross Total')),
              DataColumn(label: Text('Delivery Charge')),
              DataColumn(label: Text('Net Total')),
              DataColumn(label: Text('Advance')),
              DataColumn(label: Text('Due Amount')),
              DataColumn(label: Text('Courier Name')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Payment')),
              DataColumn(label: Text('Action')),
            ],
            rows: _orders.map((order) {
              return DataRow(cells: [
                DataCell(Text(order['created_at'].split('T')[0])),
                DataCell(Text('#${order['order_no']}')),
                DataCell(Text(order['total_order'].toString())),
                DataCell(Text('৳${order['total_price']}')),
                DataCell(Text('৳${order['product_discount']}')),
                DataCell(Text('৳${order['coupon_discount']}')),
                DataCell(Text('৳${order['gross_total']}')),
                DataCell(Text('৳${order['delivery_charge']}')),
                DataCell(Text('৳${order['net_total']}')),
                DataCell(Text('৳${order['advance_payment']}')),
                DataCell(Text('৳${order['due_amount']}')),
                DataCell(Text(order['courier_name'])),
                DataCell(Text(order['delivery_status'])),
                DataCell(Text(order['payment_status'])),
                DataCell(
                  IconButton(
                    icon: Icon(Icons.receipt, color: Colors.blue),
                    onPressed: () {
                      // Add action for button
                      print('Action for order ${order['order_no']}');
                    },
                  ),
                ),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }
}
