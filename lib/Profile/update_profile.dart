
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:creation_edge/utils/constance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class UpdateProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const UpdateProfileScreen({super.key, required this.userData});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _dobController;
  late TextEditingController _bioController;

  File? _profileImage;
  File? _bannerImage;

  void _handleImageSelection(File image, bool isProfile) async {
    try {
      // Compress the image and handle orientation
      File? compressedFile = (await FlutterImageCompress.compressAndGetFile(
        image.path,
        image.path.replaceAll('.jpg', '_compressed.jpg'),
        quality: 85,
        rotate: 0,
        // Handle orientation automatically
        autoCorrectionAngle: true,
      )) as File?;

      setState(() {
        if (isProfile) {
          _profileImage = compressedFile ?? image;
        } else {
          _bannerImage = compressedFile ?? image;
        }
      });

      // Clean up compressed file if needed
      if (compressedFile != null && compressedFile.path != image.path) {
        image.delete();
      }
    } catch (e) {
      print('Error processing image: $e');
      // Fallback to original image if processing fails
      setState(() {
        if (isProfile) {
          _profileImage = image;
        } else {
          _bannerImage = image;
        }
      });
    }
  }

  final String apiUrl = "https://girlsparadisebd.com/api/v1/update_profile";

  String? _selectedGender;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData['name'] ?? '');
    _emailController = TextEditingController(text: widget.userData['email'] ?? '');
    _phoneController = TextEditingController(text: widget.userData['phone_number'] ?? '');
    _addressController = TextEditingController(text: widget.userData['address'] ?? '');
    _dobController = TextEditingController(text: widget.userData['dob'] ?? '');
    _bioController = TextEditingController(text: widget.userData['bio'] ?? '');
    _selectedGender = widget.userData['gender'] ?? 'Male';
  }
  Future<void> _pickImage(BuildContext context, bool isProfile) async {
    final picker = ImagePicker();

    // Show bottom sheet with options
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 50,
                    preferredCameraDevice: CameraDevice.rear
                  );
                  if (image != null) {
                    _handleImageSelection(File(image.path), isProfile);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 50,
                      preferredCameraDevice: CameraDevice.rear
                  );
                  if (image != null) {
                    _handleImageSelection(File(image.path), isProfile);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
  // void _handleImageSelection(File image, bool isProfile) {
  //   setState(() {
  //     if (isProfile) {
  //       _profileImage = image;
  //     } else {
  //       _bannerImage = image;
  //     }
  //   });
  // }



  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _dobController.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final request = http.MultipartRequest('POST', Uri.parse(apiUrl));
    request.headers['Authorization'] = 'Bearer $accessToken'; // Replace with actual token

    request.fields['name'] = _nameController.text;
    request.fields['email'] = _emailController.text;
    request.fields['phone_number'] = _phoneController.text;
    request.fields['address'] = _addressController.text;
    request.fields['gender'] = _selectedGender ?? '';
    request.fields['dob'] = _dobController.text;
    request.fields['bio'] = _bioController.text;

    if (_profileImage != null) {
      request.files.add(await http.MultipartFile.fromPath('photo', _profileImage!.path));
    }

    if (_bannerImage != null) {
      request.files.add(await http.MultipartFile.fromPath('banner', _bannerImage!.path));
    }

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully!")),
        );
        Navigator.pop(context, true); // Return success to previous screen
      } else {
        final errorData = await response.stream.bytesToString();
        final errorResponse = json.decode(errorData);
        setState(() {
          _errorMessage = errorResponse['message'] ?? "An unknown error occurred.";
          log("reee_${_errorMessage}");
        });
      }
    } catch (error) {
      setState(() {
        Get.snackbar(
          "Error",
          "Image was too large",
          backgroundColor: Colors.red,
          colorText: Colors.white
        );
        _errorMessage = "Failed to update profile: $error";
        print("reee_${_errorMessage}");

      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFFdc1212),
        surfaceTintColor: Color(0xFFdc1212),
        title: const Text("Update Profile", style: TextStyle(color: Colors.white,fontSize: 16),),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [


              Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: GestureDetector(
                          onTap: () => _pickImage(context, false),
                          child: Container(
                            height: 170,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: _bannerImage != null
                                ? Image.file(_bannerImage!, fit: BoxFit.cover)
                                : widget.userData['banner'] != ""
                                ? CachedNetworkImage(imageUrl: "${ImagebaseUrl}${widget.userData['banner']}", fit: BoxFit.cover)
                                : const Icon(Icons.camera_alt, size: 40, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => _pickImage(context, true),
                        child: Padding(
                          padding: EdgeInsets.only(left: MediaQuery.of(context).size.width/2-50,top: 110),

                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: _profileImage != null
                                ? FileImage(_profileImage!)
                                : widget.userData['photo'] != null && widget.userData['photo'].isNotEmpty
                                ? NetworkImage("${ImagebaseUrl}${widget.userData['photo']}") as ImageProvider
                                : null,
                            backgroundColor: Colors.grey[400],
                            child: _profileImage == null && (widget.userData['photo'] == null || widget.userData['photo'].isEmpty)
                                ? const Icon(Icons.person, size: 40, color: Colors.white)
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Name", border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? "Name is required" : null,
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? "Email is required" : null,
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: "Phone Number", border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? "Phone number is required" : null,
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: "Address", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 18),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                items: const [
                  DropdownMenuItem(value: "Male", child: Text("Male")),
                  DropdownMenuItem(value: "Female", child: Text("Female")),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
                decoration: const InputDecoration(labelText: "Gender", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _dobController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: "Date of Birth",
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(labelText: "Bio", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFdc1212),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Update Profile',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
