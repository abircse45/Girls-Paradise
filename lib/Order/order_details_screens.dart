import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:creation_edge/Profile/profile_screens.dart';
import 'package:creation_edge/screens/home/home_screens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constance.dart';

class OrderDetailsScreen extends StatefulWidget {
  final String orderUuid;

  const OrderDetailsScreen({Key? key, required this.orderUuid})
      : super(key: key);

  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  Map<String, dynamic>? _orderDetails;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrderDetails();
  }

  Future<void> fetchOrderDetails() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://girlsparadisebd.com/api/v1/order_invoice/${widget.orderUuid}'),
        headers: {"Authorization": "Bearer $accessToken"},
      );

      if (response.statusCode == 200) {
        setState(() {
          _orderDetails = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load order details');
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
    print("id--${widget.orderUuid}");
    log("id--${accessToken}");
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Order Details',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Get.to(const HomeScreens(), transition: Transition.noTransition);
          },
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Company Header
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset('assets/images/appbarlogo.png', height: 50),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _orderDetails?['comapny_info']['address'] ?? '',
                            style: TextStyle(fontSize: 14),
                          ),
                          Text(
                            _orderDetails?['comapny_info']['email'] ?? '',
                            style: TextStyle(color: Colors.blue),
                          ),
                          Text(
                            _orderDetails?['comapny_info']['phone'] ?? '',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Invoice Header
                  Text(
                    'Invoice',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Order Info
                  _buildInfoRow('Order Id:',
                      '#${_orderDetails?['invoice_info']['order_no']}'),
                  _buildInfoRow('Order Date:',
                      _orderDetails?['invoice_info']['order_date']),
                  _buildInfoRow('Payment Method:',
                      _orderDetails?['invoice_info']['payment_method']),
                  _buildInfoRow('Courier:',
                      _orderDetails?['invoice_info']['courier_name']),

                  SizedBox(height: 24),

                  // Billing Address
                  Text(
                    'Billing Address:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(_orderDetails?['billing_address']['customer'] ?? ''),
                  Text(_orderDetails?['billing_address']['address'] ?? ''),
                  Text(_orderDetails?['billing_address']['contact_number'] ??
                      ''),

                  SizedBox(height: 16),

                  // Status Information
                  _buildStatusSection(
                      'Delivery Status:', _orderDetails?['delivery_status']),
                  SizedBox(
                    height: 10,
                  ),
                  _buildStatusSection(
                      'Payment Status:', _orderDetails?['payment_status']),

                  SizedBox(height: 24),

                  // Order Items
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DataTable(
                          dataRowHeight: 100,
                          border: TableBorder.all(color: Colors.grey),
                          columns: const [
                            DataColumn(label: Text('S/N')),
                            DataColumn(label: Text('Item')),
                            DataColumn(label: Text('Image')),
                            DataColumn(label: Text('Quantity')),
                            DataColumn(label: Text('Price')),
                            DataColumn(label: Text('Total')),
                          ],
                          rows: List<DataRow>.generate(
                            _orderDetails?['order_list'].length ?? 0,
                            (index) {
                              final item = _orderDetails?['order_list'][index];
                              final totalPrice =
                               item['item_price'] *
                                   item['item_qty'];

                              return DataRow(cells: [
                                DataCell(Text('${index + 1}')),
                                DataCell(
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start, // Align items to the start
                                    mainAxisAlignment: MainAxisAlignment
                                        .center, // Center vertically
                                    children: [
                                      Text(
                                        item['item_name'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      if (item['item_color'] != null)
                                        Text(
                                          'Color: ${item['item_color']}',
                                          style: TextStyle(
                                              color: Colors.grey, fontSize: 12),
                                        ),
                                      if (item['item_size'] != null)
                                        Text(
                                          'Size: ${item['item_size']}',
                                          style: TextStyle(
                                              color: Colors.grey, fontSize: 12),
                                        ),
                                    ],
                                  ),
                                ),
                                DataCell(
                                  CachedNetworkImage(
                                    imageUrl: "${ImagebaseUrl}${item['item_image']}",
                                    height: 50,
                                    errorWidget: (context, error, stackTrace) {
                                      return Container(
                                        height: 50,
                                        width: 50,
                                        color: Colors.grey.shade200,
                                        child: Icon(Icons.image_not_supported),
                                      );
                                    },
                                  ),
                                ),
                                DataCell(Text( item['item_qty'].toString())),
                                DataCell(Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text('৳${item['item_price']}'),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    _orderDetails?['order_summary']
                                                ['product_discount'] ==
                                        0
                                        ? Container()
                                        : Text(
                                            '৳${item['item_price'] + _orderDetails?['order_summary']['product_discount']}',
                                            style: const TextStyle(
                                                fontSize: 14,
                                                decoration:
                                                    TextDecoration.lineThrough),
                                          ),
                                  ],
                                )),
                                DataCell(
                                    Text('৳${totalPrice.toStringAsFixed(2)}')),
                              ]);
                            },
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 24),

                  // Order Summary
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        _buildSummaryRow('Total Items:',
                            '${_orderDetails?['order_summary']['total_order']}'),
                        _buildSummaryRow('Item Subtotal:',
                            '৳${_orderDetails?['order_summary']['total_price']}'),
                        _buildSummaryRow('Product Discount:',
                            '৳${_orderDetails?['order_summary']['product_discount']}'),
                        _buildSummaryRow('Coupon Discount:',
                            '৳${_orderDetails?['order_summary']['coupon_discount']}'),

                        _buildSummaryRow('Gross Total:',
                            '৳${_orderDetails?['order_summary']['gross_total']}'),
                        _buildSummaryRow('Delivery Charge:',
                            '৳${_orderDetails?['order_summary']['delivery_charge']}'),
                        _buildSummaryRow('Net Total:',
                            '৳${_orderDetails?['order_summary']['net_total']}'),
                        _buildSummaryRow('Advanced Payment:',
                            '৳${_orderDetails?['order_summary']['advance_payment']}'),
                        Divider(),
                        _buildSummaryRow(
                          'Grand Total:',
                          '৳${_orderDetails?['order_summary']['due_amount']}',
                          isBold: true,
                        ),
                     //   SizedBox(height: 20,),
                      ],
                    ),
                  ),
               SizedBox(height: 20,),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          SizedBox(width: 8),
          Text(value ?? ''),
        ],
      ),
    );
  }

  Widget _buildStatusSection(String label, String? status) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        SizedBox(width: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: status?.toLowerCase() == 'pending'
                ? Colors.orange.shade100
                : Colors.green.shade100,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            status ?? '',
            style: TextStyle(
              color: status?.toLowerCase() == 'pending'
                  ? Colors.orange.shade900
                  : Colors.green.shade900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
