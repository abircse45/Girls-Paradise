import 'package:cached_network_image/cached_network_image.dart';
import 'package:creation_edge/utils/constance.dart';
import 'package:flutter/material.dart';
 class ImageFullView extends StatelessWidget {
   final String ? image;
   const ImageFullView({super.key, this.image});

   @override
   Widget build(BuildContext context) {
     return  Scaffold(

       body: Stack(
         children: [
           CachedNetworkImage(imageUrl: "$ImagebaseUrl${image}",height: double.infinity,width: double.infinity,fit: BoxFit.fill,),
           Positioned(
             top: 60,
               right: 30,

               child: GestureDetector(
             onTap: (){
               Navigator.pop(context);
             },
             child: Container(
               height: 50,
               width: 40,
               alignment: Alignment.center,
               padding: EdgeInsets.all(1),
               decoration: BoxDecoration(
                 color: Colors.grey,
                 shape: BoxShape.circle
               ),
                 child: Icon(Icons.close,color: Colors.white,)),
           ))
         ],
       ),
     );
   }
 }
