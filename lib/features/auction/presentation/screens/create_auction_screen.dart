import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ubel/core/theme/app_colors.dart';
import 'package:ubel/features/auction/presentation/providers/auction_provider.dart';
import 'package:ubel/features/auction/presentation/providers/category_badge_provider.dart';
import 'dart:io';

class CreateAuctionScreen extends ConsumerStatefulWidget {
  const CreateAuctionScreen({super.key});

  @override
  ConsumerState<CreateAuctionScreen> createState() =>
      _CreateAuctionScreenState();
}

class _CreateAuctionScreenState extends ConsumerState<CreateAuctionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  File? _selectedImage;
  DateTime _endTime = DateTime.now().add(const Duration(days: 7));
  String? _selectedCategory; // Starts as null to avoid the Assertion Error

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // --- IMAGE LOGIC ---
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return null;
    try {
      final bytes = await _selectedImage!.readAsBytes();
      final fileName = 'auction_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'auctions/$fileName';
      await Supabase.instance.client.storage
          .from('auction-images')
          .uploadBinary(path, bytes);
      return path;
    } catch (e) {
      debugPrint('Upload error: $e');
      return null;
    }
  }

  // --- DATE LOGIC ---
  Future<void> _selectEndTime() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_endTime),
      );
      if (time != null) {
        setState(() {
          _endTime = DateTime(
              picked.year, picked.month, picked.day, time.hour, time.minute);
        });
      }
    }
  }

  // --- SUBMIT ---
  Future<void> _createAuction() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add an image')),
      );
      return;
    }

    try {
      final imagePath = await _uploadImage();
      await ref.read(auctionControllerProvider.notifier).createAuction(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            startingPrice: double.parse(_priceController.text),
            endTime: _endTime,
            imageUrl: imagePath,
            category: _selectedCategory!,
          );

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Listing Published!'),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final state = ref.watch(auctionControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create Auction',
            style: TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Media",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),

              // Premium Image Picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: AppColors.darkGray.withOpacity(0.1), width: 1),
                    image: _selectedImage != null
                        ? DecorationImage(
                            image: FileImage(_selectedImage!),
                            fit: BoxFit.cover)
                        : null,
                  ),
                  child: _selectedImage == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_outlined,
                                size: 40, color: AppColors.mediumGray),
                            SizedBox(height: 8),
                            Text("Add Item Photo",
                                style: TextStyle(color: AppColors.mediumGray)),
                          ],
                        )
                      : null,
                ),
              ),

              const SizedBox(height: 32),
              const Text("Category",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),

              // LUXURY CATEGORY SELECTION (Replaces Dropdown)
              categoriesAsync.when(
                data: (categories) {
                  final filtered =
                      categories.where((c) => c.id != 'recents').toList();
                  return Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: filtered.map((cat) {
                      final isSelected = _selectedCategory == cat.id;
                      return ChoiceChip(
                        label: Text(cat.name),
                        selected: isSelected,
                        onSelected: (val) => setState(
                            () => _selectedCategory = val ? cat.id : null),
                        selectedColor: AppColors.darkGray,
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color:
                              isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                              color: isSelected
                                  ? AppColors.darkGray
                                  : AppColors.darkGray.withOpacity(0.1)),
                        ),
                        showCheckmark: false,
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text("Error: $e"),
              ),

              const SizedBox(height: 32),
              _buildLabel("Item Details"),
              const SizedBox(height: 12),

              _buildTextField(
                  controller: _titleController,
                  label: "Title",
                  hint: "e.g. Vintage Rolex Submariner"),
              const SizedBox(height: 16),
              _buildTextField(
                  controller: _descriptionController,
                  label: "Description",
                  hint: "Tell us about the history and condition...",
                  maxLines: 4),
              const SizedBox(height: 16),
              _buildTextField(
                  controller: _priceController,
                  label: "Starting Price",
                  hint: "0.00",
                  prefix: "\$ ",
                  isNumber: true),

              const SizedBox(height: 32),
              _buildLabel("Auction Period"),
              const SizedBox(height: 12),

              InkWell(
                onTap: _selectEndTime,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: AppColors.darkGray.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        'Ends: ${_endTime.day}/${_endTime.month}/${_endTime.year} @ ${_endTime.hour}:${_endTime.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      const Icon(Icons.edit_calendar_rounded,
                          color: AppColors.mediumGray, size: 18),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // SUBMIT BUTTON
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: state.isLoading ? null : _createAuction,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.darkGray,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: state.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Publish Listing",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(
                  height: 100), // Space to scroll past the Floating Nav
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600));

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    String? prefix,
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixText: prefix,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.darkGray.withOpacity(0.1))),
      ),
      validator: (v) => v?.isEmpty ?? true ? "$label is required" : null,
    );
  }
}
