import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../screens/add_vehicle_screen.dart';

// تعريف القيم الثابتة لأنواع الطلبات
class RequestTypes {
  static const String PERIODIC = 'صيانة دورية';
  static const String EMERGENCY = 'حوادث/أعطال';
}

// تعريف القيم الثابتة لمقدمي الخدمة
class ServiceProviders {
  static const String AGENCY = 'وكالة';
  static const String WORKSHOP = 'ورش';
}

class NewRequestModal extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final bool isDarkMode;

  const NewRequestModal({
    super.key,
    this.userData,
    required this.isDarkMode,
  });

  @override
  State<NewRequestModal> createState() => _NewRequestModalState();
}

class _NewRequestModalState extends State<NewRequestModal> {
  final _formKey = GlobalKey<FormState>();

  // متغيرات الحالة
  String? requestType;
  String? serviceProvider;
  int? selectedVehicleModelId;
  bool _isLoading = false;
  List<Map<String, dynamic>> vehicleModels = [];
  late int userID;
  String? fname;
  String? userPhone;

  // وحدات التحكم
  final TextEditingController notesController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  // الألوان الديناميكية
  Color get primaryColor => const Color(0xFF3CD3AD);
  Color get secondaryColor =>
      widget.isDarkMode ? Colors.white70 : const Color(0xFF2A2D3E);
  Color get backgroundColor =>
      widget.isDarkMode ? Colors.grey[900]! : const Color(0xFFF5F5F5);
  Color get surfaceColor =>
      widget.isDarkMode ? Colors.grey[800]! : Colors.white;
  Color get textColor => widget.isDarkMode ? Colors.white : Colors.black;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    if (widget.userData != null && widget.userData!['user_id'] != null) {
      setState(() {
        userID = widget.userData!['user_id'];
        fname = widget.userData!['full_name'];
        userPhone = widget.userData!['phone_number'] ?? '';
      });
      await _fetchVehicleModels();
    } else {
      setState(() => userID = 0);
    }
  }

  @override
  void dispose() {
    notesController.dispose();
    locationController.dispose();
    super.dispose();
  }

  Future<void> _fetchVehicleModels() async {
    try {
      final response =
          await Supabase.instance.client.from('vehicles').select('''
            vehicle_id,
            models!inner (
              name
            ),
            year,
            created_at
          ''').eq('user_id', userID).order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          vehicleModels = (response as List<dynamic>).map((item) {
            return {
              'vehicle_id': item['vehicle_id'],
              'model_name': item['models']['name'],
              'year': item['year'].toString(),
            };
          }).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackbar(
          'خطأ',
          'حدث خطأ في تحديث بيانات المركبات',
          SnackBarType.fail,
        );
      }
    }
  }

  Future<void> _navigateToAddVehicle() async {
    setState(() => _isLoading = true);

    try {
      final result = await Navigator.push<Map<String, dynamic>>(
        context,
        MaterialPageRoute(
          builder: (context) => AddVehicleScreen(
            userData: widget.userData,
            isDarkMode: widget.isDarkMode,
          ),
        ),
      );

      if (result != null && mounted) {
        // تحديث قائمة المركبات
        final response = await Supabase.instance.client
            .from('vehicles')
            .select('''
              vehicle_id,
              models!inner (
                name
              ),
              year,
              created_at
            ''')
            .eq('user_id', userID)
            .order('created_at', ascending: false)
            .limit(1)
            .single();

        if (mounted && response.isNotEmpty) {
          setState(() {
            // إضافة المركبة الجديدة في بداية القائمة
            vehicleModels.insert(0, {
              'vehicle_id': response['vehicle_id'],
              'model_name': response['models']['name'],
              'year': response['year'].toString(),
            });

            // تحديد المركبة الجديدة
            selectedVehicleModelId = response['vehicle_id'];

            _showSnackbar(
              'تم بنجاح',
              'تم إضافة المركبة الجديدة وتحديدها',
              SnackBarType.success,
            );
          });
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackbar(
          'خطأ',
          'حدث خطأ أثناء تحديث قائمة المركبات',
          SnackBarType.fail,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // تصميم حقول الإدخال
  InputDecoration _getInputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: surfaceColor,
      labelStyle: TextStyle(
        color: secondaryColor,
        fontFamily: 'Cairo',
      ),
      hintStyle: TextStyle(
        color: widget.isDarkMode ? Colors.grey[400] : Colors.grey[600],
        fontFamily: 'Cairo',
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: primaryColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(
          color: widget.isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }

// إضافة دالة لتحديث البيانات
  Future<void> _refreshVehicleModels() async {
    setState(() => _isLoading = true);
    try {
      final response =
          await Supabase.instance.client.from('vehicles').select('''
          vehicle_id,
          models!inner (
            name
          ),
          year,
          created_at
        ''').eq('user_id', userID).order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          vehicleModels = (response as List<dynamic>).map((item) {
            return {
              'vehicle_id': item['vehicle_id'],
              'model_name': item['models']['name'],
              'year': item['year'].toString(),
            };
          }).toList();

          // إذا كان هناك مركبة محددة وليست موجودة في القائمة الجديدة
          if (selectedVehicleModelId != null &&
              !vehicleModels.any(
                  (model) => model['vehicle_id'] == selectedVehicleModelId)) {
            selectedVehicleModelId = vehicleModels.isNotEmpty
                ? vehicleModels.first['vehicle_id']
                : null;
          }
        });
        _showSnackbar(
            'تم التحديث', 'تم تحديث قائمة المركبات', SnackBarType.success);
      }
    } catch (e) {
      if (mounted) {
        _showSnackbar(
          'خطأ',
          'حدث خطأ في تحديث بيانات المركبات',
          SnackBarType.fail,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

// تحديث _buildVehicleModelSection
  Widget _buildVehicleModelSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: CircularProgressIndicator(),
            ),
          )
        else ...[
          if (vehicleModels.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'لا توجد مركبات مضافة',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            )
          else
            GestureDetector(
              onTap: () => _refreshVehicleModels(),
              child: AbsorbPointer(
                absorbing: _isLoading,
                child: Stack(
                  children: [
                    DropdownButtonFormField<int>(
                      value: selectedVehicleModelId,
                      decoration: _getInputDecoration(
                        'موديل المركبة',
                        'اختر موديل المركبة',
                      ).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.refresh,
                            color: primaryColor,
                          ),
                          onPressed: _isLoading ? null : _refreshVehicleModels,
                        ),
                      ),
                      dropdownColor: surfaceColor,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontFamily: 'Cairo',
                      ),
                      items: vehicleModels.map((model) {
                        return DropdownMenuItem<int>(
                          value: model['vehicle_id'],
                          child: Text(
                            '${model['model_name']} (${model['year']})',
                            style: TextStyle(
                              color: textColor,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => selectedVehicleModelId = value);
                      },
                      validator: (value) =>
                          value == null ? 'يرجى اختيار موديل المركبة' : null,
                    ),
                    if (_isLoading)
                      Positioned.fill(
                        child: Container(
                          color: surfaceColor.withValues(alpha:0.5),
                          child: const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _isLoading ? null : _navigateToAddVehicle,
            icon: Icon(Icons.add_circle_outline, color: primaryColor),
            label: Text(
              'إضافة مركبة جديدة',
              style: TextStyle(
                color: primaryColor,
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: primaryColor.withValues(alpha:0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: primaryColor),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: const BorderRadius.all(Radius.circular(4)),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioTile(
    String title,
    String value,
    String? groupValue,
    Function(String?) onChanged,
  ) {
    final isSelected = groupValue == value;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? primaryColor.withValues(alpha:widget.isDarkMode ? 0.2 : 0.1)
            : surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? primaryColor
              : widget.isDarkMode
                  ? Colors.grey[700]!
                  : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: RadioListTile<String>(
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? primaryColor : textColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontFamily: 'Cairo',
          ),
        ),
        value: value,
        groupValue: groupValue,
        activeColor: primaryColor,
        onChanged: onChanged,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      _showErrorSnackBar();
      return;
    }

    setState(() => _isLoading = true);
    try {
      // إنشاء طلب الصيانة
      final maintenanceResponse = await Supabase.instance.client
          .from('maintenance_requests')
          .insert({
        'request_type': requestType,
        'user_id': userID,
        'service_provider': serviceProvider,
        'vehicle_id': selectedVehicleModelId,
        'problem_description': notesController.text,
        'location_address': locationController.text,
      })
          .select()
          .single();

      if (maintenanceResponse.isNotEmpty) {
        final requestId = maintenanceResponse['request_id'];
        final serviceProviderText = serviceProvider == 'AGENCY' ? 'الوكالة' : 'الورش';
        final requestTypeText = requestType == 'PERIODIC' ? 'صيانة دورية' : 'حوادث/أعطال';

        // إنشاء إشعار للمسؤول
        await Supabase.instance.client.from('notifications').insert({
          'user_id': userID,
          'title': 'طلب صيانة جديد',
          'message': '''تم إنشاء طلب صيانة جديد
نوع الطلب: $requestTypeText
مقدم الخدمة: $serviceProviderText
اسم العميل: $fname
رقم الهاتف: $userPhone''',
          'notification_type': 'new_maintenance_request',
          'related_request_id': requestId,
          'is_read': false,
          'is_for_admin': true // إشعار للمسؤول
        });

        // إنشاء إشعار للمستخدم
        await Supabase.instance.client.from('notifications').insert({
          'user_id': userID,
          'title': 'تم استلام طلبك',
          'message': 'تم استلام طلب $requestTypeText لدى $serviceProviderText بنجاح. سيتم مراجعة طلبك قريباً.',
          'notification_type': 'request_confirmation',
          'related_request_id': requestId,
          'is_read': false,
          'is_for_admin': false // إشعار للمستخدم
        });

        _showSnackbar('نجاح', 'تم تقديم الطلب بنجاح!', SnackBarType.success);
        await _sendToWhatsApp();

        if (mounted) {
          Navigator.pop(context, {
            'requestType': requestType,
            'serviceProvider': serviceProvider,
            'vehicleId': selectedVehicleModelId,
            'notes': notesController.text,
            'location': locationController.text,
            'full_name': fname
          });
        }
      }
    } catch (e) {
      _showErrorSnackBar();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _sendToWhatsApp() async {
    try {
      final selectedVehicle = vehicleModels.firstWhere(
        (model) => model['vehicle_id'] == selectedVehicleModelId,
        orElse: () => {'model_name': 'غير معروف'},
      );

      final String phoneNumber = '966507274427';
      final String message = '''طلب جديد:
اسم العميل: $fname
رقم الهاتف: $userPhone
نوع الطلب: $requestType
مقدم الخدمة: $serviceProvider
موديل المركبة: ${selectedVehicle['model_name']}
ملاحظات: ${notesController.text}
الموقع: ${locationController.text}''';

      final Uri url = Uri.parse(
          'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}');

      if (await canLaunchUrl(url)) {
        await launchUrl(url);
        _showSnackbar(
            'نجاح', 'تم فتح WhatsApp لإرسال الرسالة!', SnackBarType.success);
      } else {
        _showSnackbar('خطأ', 'لم يتمكن من فتح WhatsApp.', SnackBarType.fail);
      }
    } catch (e) {
      _showSnackbar('خطأ', 'حدث خطأ أثناء فتح WhatsApp.', SnackBarType.fail);
    }
  }

  void _showErrorSnackBar() {
    _showSnackbar(
      'خطأ',
      'يرجى التحقق من المعلومات المدخلة',
      SnackBarType.fail,
    );
  }

  void _showSnackbar(String title, String message, SnackBarType type) {
    IconSnackBar.show(
      context,
      snackBarType: type,
      label: message,
      backgroundColor: type == SnackBarType.fail ? Colors.red : Colors.green,
    );
  }
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // شريط الإغلاق العلوي
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // زر الإغلاق
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      color: textColor,
                      size: 24,
                    ),
                  ),
                  // مؤشر السحب
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    onPanUpdate: (details) {
                      // إغلاق عند السحب لأسفل
                      if (details.delta.dy > 5) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: widget.isDarkMode
                            ? Colors.grey[600]
                            : Colors.grey[400],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // مساحة فارغة للتوازن
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // المحتوى الرئيسي
            Flexible(
              child: GestureDetector(
                // إغلاق عند السحب لأسفل في أي مكان
                onPanUpdate: (details) {
                  if (details.delta.dy > 8) {
                    Navigator.of(context).pop();
                  }
                },
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                      left: 16,
                      right: 16,
                      top: 8,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('نوع الطلب'),
                          _buildRadioTile(
                            'صيانة دورية',
                            RequestTypes.PERIODIC,
                            requestType,
                                (value) => setState(() => requestType = value),
                          ),
                          _buildRadioTile(
                            'حوادث / أعطال',
                            RequestTypes.EMERGENCY,
                            requestType,
                                (value) => setState(() => requestType = value),
                          ),
                          if (requestType != null) ...[
                            _buildSectionTitle('مقدم الخدمة'),
                            _buildRadioTile(
                              'وكالة',
                              ServiceProviders.AGENCY,
                              serviceProvider,
                                  (value) => setState(() => serviceProvider = value),
                            ),
                            _buildRadioTile(
                              'ورش',
                              ServiceProviders.WORKSHOP,
                              serviceProvider,
                                  (value) => setState(() => serviceProvider = value),
                            ),
                          ],
                          if (serviceProvider != null) ...[
                            _buildSectionTitle('تفاصيل المركبة'),
                            _buildVehicleModelSection(),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: notesController,
                              maxLines: 3,
                              style: TextStyle(color: textColor),
                              decoration: _getInputDecoration(
                                'وصف المشكلة',
                                'اكتب أي ملاحظات تبي تضيفها',
                              ),
                            ),
                            _buildSectionTitle('موقع الاستلام'),
                            TextFormField(
                              controller: locationController,
                              style: TextStyle(color: textColor),
                              decoration: _getInputDecoration(
                                'الموقع',
                                'حدد موقع استلام السيارة',
                              ),
                              validator: (value) =>
                              value?.isEmpty ?? true ? 'يرجى تحديد الموقع' : null,
                            ),
                          ],
                          const SizedBox(height: 24),
                          if (serviceProvider != null)
                            Container(
                              width: double.infinity,
                              height: 56,
                              margin: const EdgeInsets.only(bottom: 16),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                onPressed: _isLoading ? null : _submitForm,
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                    color: Colors.white)
                                    : const Text(
                                  'إرسال الطلب',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
