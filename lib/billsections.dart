import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';

class billsection extends StatelessWidget{

   String domains;
   String path;


   billsection({
     super.key,
     required this.domains,
     required this.path,

   });



  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        decoration: BoxDecoration(
            color: Color.fromARGB(255, 211, 211, 211),
            borderRadius: BorderRadius.circular(15)
        
        ),
        child: Column(
          children: [

            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Image.asset(path,
              height: 50,),

            ),
            Text(domains,style:TextStyle(fontWeight:FontWeight.w500,
            fontSize: 20),
            ),

          ],
        ),

      ),
    );
  }
}