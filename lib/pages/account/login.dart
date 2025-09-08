@@ .. @@
 import 'package:provider/provider.dart';
 import 'package:restaurant/pages/account/forgetPassword.dart';
 import 'package:restaurant/pages/account/register.dart';
 import 'package:restaurant/pages/component/progress.dart';
 import 'package:restaurant/pages/home/home.dart';
 import 'package:restaurant/pages/provider/loading.dart';
 import 'package:shared_preferences/shared_preferences.dart';
-import 'package:toast/toast.dart';
+import 'package:fluttertoast/fluttertoast.dart';

 import '../config.dart';
 import '../function.dart';

 class Login extends StatefulWidget {
   @override
   _LoginState createState() => _LoginState();
 }

 class _LoginState extends State<Login> {
   bool isloading = false;

   var _formKey = GlobalKey<FormState>();

   TextEditingController txtcus_pwd = new TextEditingController();
   TextEditingController txtcus_mobile = new TextEditingController();

   loginDataCustomer(context, LoadingControl load) async {
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
         "cus_pwd": txtcus_pwd.text,
         "cus_mobile": txtcus_mobile.text,
       };

       Map resArray =
           await SaveDataList(arr, "customer/login.php", context, "select");
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
-      Toast.show("المعلومات غير صحيحة", context,
-          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
+      Fluttertoast.showToast(
+          msg: "المعلومات غير صحيحة",
+          toastLength: Toast.LENGTH_SHORT,
+          gravity: ToastGravity.BOTTOM);
     }
   }