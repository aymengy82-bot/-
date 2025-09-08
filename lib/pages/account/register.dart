@@ .. @@
 import 'package:restaurant/pages/home/home.dart';
 import 'package:restaurant/pages/provider/loading.dart';
 import 'package:shared_preferences/shared_preferences.dart';
-import 'package:toast/toast.dart';
+import 'package:fluttertoast/fluttertoast.dart';

 import '../config.dart';
 import '../function.dart';

 class Register extends StatefulWidget {
   @override
   _RegisterState createState() => _RegisterState();
 }

 class _RegisterState extends State<Register> {
   bool isloading = false;

   var _formKey = GlobalKey<FormState>();
   TextEditingController txtcus_name = new TextEditingController();
   TextEditingController txtcus_pwd = new TextEditingController();
   TextEditingController txtcus_mobile = new TextEditingController();

   TextEditingController txtcus_email = new TextEditingController();

   saveDataCustomer(context, LoadingControl load) async {
     if (!await checkConnection()) {
-      Toast.show("Not connected Internet", context,
-          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
+      Fluttertoast.showToast(
+          msg: "لا يوجد اتصال بالإنترنت",
+          toastLength: Toast.LENGTH_SHORT,
+          gravity: ToastGravity.BOTTOM);
     }
     bool myvalid = _formKey.currentState.validate();
     load.add_loading();
     if (myvalid) {
       isloading = true;
       load.add_loading();
       Map arr = {
         "cus_name": txtcus_name.text,
         "cus_pwd": txtcus_pwd.text,
         "cus_mobile": txtcus_mobile.text,
         "cus_email": txtcus_email.text,
       };

       Map resArray = await SaveDataList(
           arr, "customer/insert_customer.php", context, "insert");
       isloading = resArray != null ? true : false;
       if (isloading) {
         SharedPreferences sh = await SharedPreferences.getInstance();
         sh.setString(G_cus_id, resArray["cus_id"]);
         sh.setString(G_cus_name, resArray["cus_name"]);
         sh.setString(G_cus_image, resArray["cus_image"]);
         sh.setString(G_cus_mobile, resArray["cus_mobile"]);
         sh.setString(G_cus_email, resArray["cus_email"]);
         Navigator.pushReplacement(
             context, MaterialPageRoute(builder: (context) => Home()));
       }
       /*await createData(
           arr, "delivery/insert_delivery.php", context, () => Delivery());*/

       load.add_loading();
     } else {
-      Toast.show("Please fill data", context,
-          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
+      Fluttertoast.showToast(
+          msg: "يرجى ملء جميع البيانات",
+          toastLength: Toast.LENGTH_SHORT,
+          gravity: ToastGravity.BOTTOM);
     }
   }