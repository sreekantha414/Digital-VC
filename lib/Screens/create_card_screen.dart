import 'package:flutter/material.dart';
import 'package:visiting_card_app/Screens/dashboard/dashboard_screen.dart';
import 'package:visiting_card_app/Screens/splash_screen.dart';
import '../Database/database.dart';
import '../Model/user_profile.dart';
import '../Theme/theme.dart';
import '../Widgets/cutom_textfiled_widget.dart';
import '../utils/alert_utils.dart';
import '../utils/stream_builder.dart';

class CreateCardScreen extends StatefulWidget {
  final bool? isUser;
  final VisitingCard? existingCard;
  const CreateCardScreen({super.key, this.existingCard, this.isUser});

  @override
  State<CreateCardScreen> createState() => _CreateCardScreenState();
}

class _CreateCardScreenState extends State<CreateCardScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for all fields
  final _fullNameController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _companyController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();
  final _addressController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _hoursController = TextEditingController();
  final _facebookController = TextEditingController();
  final _instagramController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _youtubeController = TextEditingController();
  final _twitterController = TextEditingController();
  final _catalogController = TextEditingController();
  final _tagsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingCard != null) {
      final fields = widget.existingCard!.fields;
      _fullNameController.text = fields['name'] ?? '';
      _jobTitleController.text = fields['jobTitle'] ?? '';
      _companyController.text = fields['company'] ?? '';
      _phoneController.text = fields['phone'] ?? '';
      _emailController.text = fields['email'] ?? '';
      _websiteController.text = fields['website'] ?? '';
      _addressController.text = fields['address'] ?? '';
      _categoryController.text = fields['category'] ?? '';
      _descriptionController.text = fields['description'] ?? '';
      _hoursController.text = fields['hours'] ?? '';
      _facebookController.text = fields['facebook'] ?? '';
      _instagramController.text = fields['instagram'] ?? '';
      _linkedinController.text = fields['linkedin'] ?? '';
      _youtubeController.text = fields['youtube'] ?? '';
      _twitterController.text = fields['twitter'] ?? '';
      _catalogController.text = fields['catalog'] ?? '';
      _tagsController.text = fields['tags'] ?? '';
    }
  }

  void _createOrUpdateCard() async {
    if (_formKey.currentState!.validate()) {
      final fields = {
        "name": _fullNameController.text.trim(),
        "jobTitle": _jobTitleController.text.trim(),
        "company": _companyController.text.trim(),
        "phone": _phoneController.text.trim(),
        "email": _emailController.text.trim(),
        "website": _websiteController.text.trim(),
        "address": _addressController.text.trim(),
        "category": _categoryController.text.trim(),
        "description": _descriptionController.text.trim(),
        "hours": _hoursController.text.trim(),
        "facebook": _facebookController.text.trim(),
        "instagram": _instagramController.text.trim(),
        "linkedin": _linkedinController.text.trim(),
        "youtube": _youtubeController.text.trim(),
        "twitter": _twitterController.text.trim(),
        "catalog": _catalogController.text.trim(),
        "tags": _tagsController.text.trim(),
      };

      final card = VisitingCard(
        type: widget.isUser == true ? CardType.user : CardType.other,
        id: widget.existingCard?.id,
        fields: fields,
        extras: widget.existingCard?.extras ?? [],
        qrData: widget.existingCard?.qrData,
      );

      try {
        if (widget.existingCard != null) {
          await DBService.updateVisitingCard(card);
          Navigator.pop(context, true);
          AlertUtils.showSnackbarSuccess(context, 'Card updated successfully!');
        } else {
          await DBService.insertVisitingCard(card);
          AlertUtils.showSnackbarSuccess(context, 'Card created successfully!');
          if (widget.isUser == true) {
            await pref?.setBool('login', true);
            await Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => DashboardScreen()), (route) => false);
            StreamUtil.dashboardBottomSubject.add(0);
          } else {
            Navigator.pop(context, true);
          }
        }
      } catch (e) {
        AlertUtils.showSnackbarWarning(context, 'Failed to save card: $e');
      }
    } else {
      AlertUtils.showSnackbarWarning(context, 'Please correct the highlighted errors.');
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _jobTitleController.dispose();
    _companyController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _addressController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _hoursController.dispose();
    _facebookController.dispose();
    _instagramController.dispose();
    _linkedinController.dispose();
    _youtubeController.dispose();
    _twitterController.dispose();
    _catalogController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  bool _shouldShowField(TextEditingController controller) {
    // Show all fields for new card, only non-empty ones for update
    return widget.existingCard == null || controller.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: AppColors.white),
        ),
        title: Text(widget.existingCard != null ? 'Update Card' : 'Create Card', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.lightPurple,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(color: AppColors.cream),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_shouldShowField(_fullNameController))
                      CustomTextField(
                        label: "Full Name",
                        hint: "e.g., John Doe",
                        controller: _fullNameController,
                        validator: (val) => val == null || val.isEmpty ? "Full Name is required" : null,
                      ),
                    if (_shouldShowField(_jobTitleController))
                      CustomTextField(label: "Job Title", hint: "e.g., Product Manager", controller: _jobTitleController),
                    if (_shouldShowField(_companyController))
                      CustomTextField(label: "Company", hint: "e.g., Acme Inc.", controller: _companyController),
                    if (_shouldShowField(_addressController))
                      CustomTextField(label: "Business Address", hint: "e.g., 123 Main St, City", controller: _addressController),

                    const SizedBox(height: 12),
                    const Text("Contact Information", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

                    if (_shouldShowField(_phoneController))
                      CustomTextField(
                        label: "Phone Number",
                        hint: "e.g., +1 234 567 890",
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        validator: (val) => val == null || val.isEmpty ? "Phone number required" : null,
                      ),
                    if (_shouldShowField(_emailController))
                      CustomTextField(
                        label: "Email",
                        hint: "e.g., john.doe@example.com",
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) {
                          if (val == null || val.isEmpty) return "Email required";
                          if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$").hasMatch(val)) {
                            return "Enter a valid email";
                          }
                          return null;
                        },
                      ),
                    if (_shouldShowField(_websiteController))
                      CustomTextField(
                        label: "Website",
                        hint: "e.g., https://www.example.com",
                        controller: _websiteController,
                        keyboardType: TextInputType.url,
                      ),

                    const SizedBox(height: 12),
                    const Text("Additional Details", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

                    if (_shouldShowField(_categoryController))
                      CustomTextField(label: "Business Category", hint: "e.g., IT Services", controller: _categoryController),
                    if (_shouldShowField(_descriptionController))
                      CustomTextField(
                        label: "Business Description",
                        hint: "Short description of your business",
                        controller: _descriptionController,
                      ),
                    if (_shouldShowField(_hoursController))
                      CustomTextField(label: "Business Hours", hint: "e.g., Mon-Fri 9am-6pm", controller: _hoursController),
                    if (_shouldShowField(_catalogController))
                      CustomTextField(label: "Catalog", hint: "Link to catalog or description", controller: _catalogController),
                    if (_shouldShowField(_tagsController))
                      CustomTextField(label: "Labels / Tags", hint: "e.g., software, development, design", controller: _tagsController),

                    const SizedBox(height: 12),
                    const Text("Social Media", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

                    if (_shouldShowField(_facebookController))
                      CustomTextField(
                        label: "Facebook",
                        hint: "e.g., https://facebook.com/username",
                        controller: _facebookController,
                        keyboardType: TextInputType.url,
                      ),
                    if (_shouldShowField(_instagramController))
                      CustomTextField(
                        label: "Instagram",
                        hint: "e.g., https://instagram.com/username",
                        controller: _instagramController,
                        keyboardType: TextInputType.url,
                      ),
                    if (_shouldShowField(_linkedinController))
                      CustomTextField(
                        label: "LinkedIn",
                        hint: "e.g., https://linkedin.com/in/username",
                        controller: _linkedinController,
                        keyboardType: TextInputType.url,
                      ),
                    if (_shouldShowField(_youtubeController))
                      CustomTextField(
                        label: "YouTube",
                        hint: "e.g., https://youtube.com/user/username",
                        controller: _youtubeController,
                        keyboardType: TextInputType.url,
                      ),
                    if (_shouldShowField(_twitterController))
                      CustomTextField(
                        label: "Twitter",
                        hint: "e.g., https://twitter.com/username",
                        controller: _twitterController,
                        keyboardType: TextInputType.url,
                      ),

                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkPurple,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          _createOrUpdateCard();
                        },
                        child: Text(
                          widget.existingCard != null ? "Update Card" : "Create Card",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.white),
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
    );
  }
}
