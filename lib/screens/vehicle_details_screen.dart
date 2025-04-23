import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VehicleDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> vehicle;

  const VehicleDetailsScreen({Key? key, required this.vehicle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صورة المركبة
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: AssetImage('assets/images/car.png'), // استبدل بالصورة المناسبة
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 16),
            // تفاصيل المركبة
            Text(
              'ماركة: ${vehicle['manufacturers']['name']}',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(height: 4),
            Text(
              'رقم اللوحة: ${vehicle['plate_number']}', // رقم الهيكل
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'الموديل: ${vehicle['models']['name']}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              'السنة: ${vehicle['year']}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 8),
            Text(
              'الحالة: ${vehicle['is_active']}', // تأكد من وجود هذا الحقل في البيانات
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 8),
            SizedBox(height: 16),
            // أزرار التعديل والحذف
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // تنفيذ عملية التعديل
                    _showEditDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // لون زر التعديل
                  ),
                  child: Text('تعديل'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // تنفيذ عملية الحذف
                    _confirmDeleteVehicle(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // لون زر الحذف
                  ),
                  child: Text('حذف'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    String _model = vehicle['models']['name'];
    String _year = vehicle['year'].toString();
    String _plateNumber = vehicle['plate_number'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('تعديل المركبة'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: _model,
                  decoration: InputDecoration(labelText: 'الموديل', border: OutlineInputBorder()),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال الموديل';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _model = value!;
                  },
                ),
                SizedBox(height: 8),
                TextFormField(
                  initialValue: _year,
                  decoration: InputDecoration(labelText: 'السنة', border: OutlineInputBorder()),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال السنة';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _year = value!;
                  },
                ),
                SizedBox(height: 8),
                TextFormField(
                  initialValue: _plateNumber,
                  decoration: InputDecoration(labelText: 'رقم اللوحة', border: OutlineInputBorder()),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال رقم اللوحة';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _plateNumber = value!;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // إغلاق الحوار
              },
              child: Text('إلغاء', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  _updateVehicle(context, _model, _year, _plateNumber);
                }
              },
              child: Text('تحديث'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteVehicle(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('تأكيد الحذف'),
          content: Text('هل أنت متأكد أنك تريد حذف هذه المركبة؟'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // إغلاق الحوار
              },
              child: Text('إلغاء', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                _deleteVehicle(context);
              },
              child: Text('حذف', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _deleteVehicle(BuildContext context) async {
    final response = await Supabase.instance.client
        .from('vehicles')
        .delete()
        .eq('vehicle_id', vehicle['id']); // تأكد من أن لديك حقل id في قاعدة البيانات

    if (response.error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم حذف المركبة بنجاح!')),
      );
      Navigator.pop(context); // العودة إلى الشاشة السابقة
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: ${response.error!.message}')),
      );
    }
  }

  void _updateVehicle(BuildContext context, String model, String year, String plateNumber) async {
    final response = await Supabase.instance.client
        .from('vehicles')
        .update({
      'models': {'name': model}, // تأكد من أن لديك هيكل البيانات الصحيح
      'year': year,
      'plate_number': plateNumber,
    })
        .eq('vehicle_id', vehicle['id']); // تأكد من أن لديك حقل id في قاعدة البيانات

    if (response.error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم تحديث المركبة بنجاح!')),
      );
      Navigator.pop(context); // العودة إلى الشاشة السابقة
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: ${response.error!.message}')),
      );
    }
  }
}