import 'package:cached_network_image/cached_network_image.dart';
import 'package:creation_edge/screens/shop/controller/product_controller.dart';
import 'package:creation_edge/screens/shop/product_details.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/constance.dart';


class ProductList extends StatefulWidget {
  const ProductList({super.key});

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  final ProductController productController = Get.put(ProductController());

  String selectedFilter = "Best Rated";

  List<String> filterList = [
    "Best Rated",
    "High Rated",
    "Low Rated",
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${productController.products?.data?.length} Item Found",
                style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
              Container(
                padding: EdgeInsets.only(left: 8, right: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: DropdownButtonHideUnderline(
                    child: DropdownButton(
                      value: selectedFilter,
                      items: filterList.map((e) {
                        return DropdownMenuItem(
                          child: Text(e),
                          value: e,
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedFilter = val!;
                        });
                      },
                    )),
              )
            ],
          ),
        ),
        Obx(() {
          if (productController.isLoading) {
            return  Center(
              child: CircularProgressIndicator(

              ),
            );
          } else {
            return Expanded(
              child: GridView.builder(
                shrinkWrap: true,
                primary: false,
                itemCount: productController.products?.data!.length,
                itemBuilder: (_, index) {
                  var data = productController.products?.data![index];
                  return GestureDetector(
                    onTap: () {
                      Get.to(ProductDetails(id: data?.id),
                          transition: Transition.noTransition);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Stack(
                          children: [
                            // Background image
                            CachedNetworkImage(
                              imageUrl: "$ImagebaseUrl${data?.defaultImage}",
                              height: 300,
                              fit: BoxFit.fill,
                            ),

                            Positioned(
                              top: 110,
                              right: 0,
                              left: 0,
                              child: Padding(
                                padding:
                                const EdgeInsets.only(left: 4.0, right: 4),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 5.0, left: 4, bottom: 5, right: 4),
                                  child: Center(
                                    child: Container(
                                      padding: EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.8),
                                          borderRadius:
                                          BorderRadius.circular(5)),
                                      child: Text(
                                        "${data?.shortName}",
                                        textAlign: TextAlign.start,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Buttons Row
                            Positioned(
                              top: 155,
                              right: 0,
                              left: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildButton(
                                    icon: Icons.shopping_cart,
                                    onTap: () {
                                      // Handle cart button action
                                    },
                                  ),
                                  const SizedBox(
                                      width: 16), // Spacing between buttons
                                  _buildButton(
                                    icon: Icons.favorite,
                                    onTap: () {
                                      // Handle favorite button action
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                                height:
                                12), // Spacing between buttons and price
                            // Price Tag
                            Positioned(
                              top: 205,
                              right: 0,
                              left: 0,
                              child: Center(
                                child: Container(
                                  alignment: Alignment.center,
                                  width: 90,
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colors.black.withOpacity(0.8)),
                                  child: Text(
                                    '৳${data?.defaultPrice}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, childAspectRatio: 8 / 9.5),
              ),
            );
          }
        }),
      ],
    );
  }

  Widget _buildButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.blue,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}
