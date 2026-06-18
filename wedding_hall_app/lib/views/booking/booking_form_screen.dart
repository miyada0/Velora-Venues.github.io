import 'package:flutter/material.dart';
import 'package:wedding_hall_booking_app/services/api_service.dart';
import '../../models/hall_model.dart';
import '../../services/booking_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/validators.dart';
import 'booking_success_screen.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class BookingFormScreen extends StatefulWidget {
  final HallModel hall;
  final DateTime selectedDate;

  const BookingFormScreen({
    super.key,
    required this.hall,
    required this.selectedDate,
  });

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final BookingService bookingService = BookingService();
  DateTime? selectedDate;

  // Controllers
  late TextEditingController fullNameController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  late TextEditingController startTimeController;
  late TextEditingController endTimeController;
  late TextEditingController guestCountController;
  late TextEditingController specialRequestsController;
  late Razorpay _razorpay;

  // Form fields
  String selectedEventType = "wedding";
  bool cateringRequired = false;
  bool decorationRequired = false;
  bool photographyRequired = false;

  double hallPrice = 0;
  double advanceAmount = 0;
  double totalAmount = 0;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    hallPrice = widget.hall.price;
    totalAmount = hallPrice;
    advanceAmount = hallPrice * 0.2;
    fullNameController = TextEditingController();
    phoneController = TextEditingController();
    emailController = TextEditingController();
    startTimeController = TextEditingController();
    endTimeController = TextEditingController();
    guestCountController = TextEditingController();
    specialRequestsController = TextEditingController();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
  }

  @override
  void dispose() {
    fullNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
    guestCountController.dispose();
    specialRequestsController.dispose();
    _razorpay.clear();
    super.dispose();
  }

  Future<String> _submitBooking() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      throw Exception("Validation failed");
    }

    setState(() {
      isLoading = true;
    });

    try {
      final bookingData = {
        "hallId": widget.hall.id,
        "date": widget.selectedDate.toIso8601String(),
        "fullName": fullNameController.text,
        "phone": phoneController.text,
        "email": emailController.text,
        "eventType": selectedEventType,
        "startTime": startTimeController.text,
        "endTime": endTimeController.text,
        "numberOfGuests": int.parse(guestCountController.text),
        "totalAmount": totalAmount,
        "advanceAmount": advanceAmount,
        "specialRequests": specialRequestsController.text,
        "cateringRequired": cateringRequired,
        "decorationRequired": decorationRequired,
        "photographyRequired": photographyRequired,
        "paymentMethod": "card",
      };

      final response = await bookingService.createBooking(bookingData);
      return response["bookingId"];
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Booking failed: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }

      throw Exception("Booking failed"); // ✅ REQUIRED
    }
  }

  Future<void> _startPayment() async {
    try {
      setState(() => isLoading = true);

      final order = await ApiService.createOrder(totalAmount.toInt());

      var options = {
        'key': 'rzp_test_SVAikeknpdHHks', // ✅ Updated with new test key
        'amount': (totalAmount * 100).toInt(),
        'order_id': order['id'],
        'name': 'Wedding Hall Booking',
        'description': 'Hall Booking',
        'prefill': {
          'contact': phoneController.text,
          'email': emailController.text,
        },
      };

      _razorpay.open(options);
    } catch (e) {
      setState(() => isLoading = false);
      print(e);
    }
  }

  // ✅ HANDLE PAYMENT SUCCESS - Safe null handling
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print(
        "💳 Payment Success - ID: ${response.paymentId}, Order: ${response.orderId}");

    // ✅ FIX: Safe null handling - use ?? instead of !
    final paymentId = response.paymentId ?? "";
    final orderId = response.orderId ?? "";
    final signature = response.signature ?? "";

    // ✅ Validate payment ID exists
    if (paymentId.isEmpty) {
      _showPaymentError("Payment ID missing - cannot verify payment");
      return;
    }

    setState(() => isLoading = true);

    try {
      // ✅ Step 1: Submit booking to backend with payment details
      final bookingId = await _submitBooking();
      print("✅ Booking created: $bookingId");

      // ✅ Step 2: Verify payment on backend
      final verifyResponse = await bookingService.verifyPayment(
        bookingId: bookingId,
        paymentId: paymentId,
        orderId: orderId,
        signature: signature,
      );

      print("✅ Payment verified: $verifyResponse");

      // ✅ Step 3: Check if verification was successful
      if (!mounted) return;

      if (verifyResponse['success'] == true) {
        // ✅ Navigate to success screen
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BookingSuccessScreen(
              hallName: widget.hall.name,
              bookingDate: widget.selectedDate, // ✅ Safe: from widget property
              totalAmount: totalAmount,
              advanceAmount: advanceAmount,
              customerName: fullNameController.text,
              bookingId: bookingId,
            ),
          ),
        );
      } else {
        // ✅ Payment verification failed
        _showPaymentError(
          verifyResponse['message'] ?? "Payment verification failed",
        );
      }
    } on Exception catch (e) {
      print("❌ Payment Error: $e");
      if (!mounted) return;
      _showPaymentError("Payment processing failed: $e");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // ✅ HANDLE PAYMENT ERROR
  void _handlePaymentError(PaymentFailureResponse response) {
    print("❌ Payment Error [${response.code}]: ${response.message}");

    if (!mounted) return;

    setState(() => isLoading = false);

    // ✅ Safe error handling
    final errorCode = response.code?.toString() ?? "unknown";
    final errorMessage = response.message ?? "Payment failed";

    _showPaymentError("Payment Failed [$errorCode]: $errorMessage");
  }

  // ✅ HELPER: Show payment error
  void _showPaymentError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: "Retry",
          textColor: Colors.white,
          onPressed: () {
            setState(() => isLoading = false);
          },
        ),
      ),
    );
  }

  void _updateTotalAmount() {
    double total = hallPrice;

    // Add extra charges for services (optional - can be configured)
    if (photographyRequired) {
      total += 5000; // Example: ₹5000 for photography
    }
    if (decorationRequired) {
      total += 10000; // Example: ₹10000 for decoration
    }
    if (cateringRequired) {
      total += 15000; // Example: ₹15000 for catering
    }

    setState(() {
      totalAmount = total;
      advanceAmount = total * 0.2;
    });
  }

  Future<void> _selectTime(TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        controller.text = picked.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Booking Form"),
        elevation: 0,
      ),
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF87CEFA),
              Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// HALL INFO CARD
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.hall.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              widget.hall.location,
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 6),
                          Text(
                            widget.selectedDate.toString().split(' ')[0],
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.currency_rupee,
                              size: 16, color: AppTheme.primary),
                          const SizedBox(width: 6),
                          Text(
                            "₹${widget.hall.price.toStringAsFixed(0)} per day",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primary,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                /// FORM SECTION: PERSONAL DETAILS
                Text(
                  "Personal Details",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),

                /// Full Name
                TextFormField(
                  controller: fullNameController,
                  decoration: InputDecoration(
                    labelText: "Full Name *",
                    hintText: "Enter your full name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return "Full name is required";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                /// Phone
                TextFormField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: "Phone Number *",
                    hintText: "10-digit mobile number",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (!Validators.isValidPhone(value)) {
                      return "Enter valid 10-digit phone number";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                /// Email
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Email *",
                    hintText: "your@email.com",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (!Validators.isValidEmail(value)) {
                      return "Enter valid email address";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                /// EVENT DETAILS
                Text(
                  "Event Details",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),

                /// Event Type
                DropdownButtonFormField<String>(
                  initialValue: selectedEventType,
                  decoration: InputDecoration(
                    labelText: "Event Type",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.celebration),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: "wedding",
                      child: Text("Wedding"),
                    ),
                    DropdownMenuItem(
                      value: "corporate",
                      child: Text("Corporate Event"),
                    ),
                    DropdownMenuItem(
                      value: "birthday",
                      child: Text("Birthday Party"),
                    ),
                    DropdownMenuItem(
                      value: "anniversary",
                      child: Text("Anniversary"),
                    ),
                    DropdownMenuItem(
                      value: "other",
                      child: Text("Other"),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedEventType = value ?? "wedding";
                    });
                  },
                ),
                const SizedBox(height: 12),

                /// Start Time
                TextFormField(
                  controller: startTimeController,
                  decoration: InputDecoration(
                    labelText: "Start Time *",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.access_time),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.schedule),
                      onPressed: () => _selectTime(startTimeController),
                    ),
                  ),
                  readOnly: true,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return "Start time is required";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                /// End Time
                TextFormField(
                  controller: endTimeController,
                  decoration: InputDecoration(
                    labelText: "End Time *",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.access_time),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.schedule),
                      onPressed: () => _selectTime(endTimeController),
                    ),
                  ),
                  readOnly: true,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return "End time is required";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                /// Number of Guests
                TextFormField(
                  controller: guestCountController,
                  decoration: InputDecoration(
                    labelText: "Number of Guests *",
                    hintText: "e.g., 100",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.people),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return "Number of guests is required";
                    }
                    if (int.tryParse(value!) == null) {
                      return "Enter valid number";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                /// ADD-ON SERVICES
                Text(
                  "Additional Services",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),

                /// Catering
                CheckboxListTile(
                  title: const Text("Catering Required"),
                  subtitle: const Text("Add ₹15,000"),
                  value: cateringRequired,
                  onChanged: (value) {
                    setState(() {
                      cateringRequired = value ?? false;
                      _updateTotalAmount();
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),

                /// Decoration
                CheckboxListTile(
                  title: const Text("Decoration Required"),
                  subtitle: const Text("Add ₹10,000"),
                  value: decorationRequired,
                  onChanged: (value) {
                    setState(() {
                      decorationRequired = value ?? false;
                      _updateTotalAmount();
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),

                /// Photography
                CheckboxListTile(
                  title: const Text("Photography/Videography"),
                  subtitle: const Text("Add ₹5,000"),
                  value: photographyRequired,
                  onChanged: (value) {
                    setState(() {
                      photographyRequired = value ?? false;
                      _updateTotalAmount();
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),

                const SizedBox(height: 24),

                /// SPECIAL REQUESTS
                Text(
                  "Special Requests",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: specialRequestsController,
                  decoration: InputDecoration(
                    labelText: "Special Requests (Optional)",
                    hintText: "Any special arrangements needed?",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.note),
                  ),
                  maxLines: 3,
                ),

                const SizedBox(height: 24),

                /// PRICING SUMMARY
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.gold, width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Price Summary",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Hall Base Price:"),
                          Text(
                            "₹${hallPrice.toStringAsFixed(0)}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (cateringRequired)
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Catering:"),
                            Text(
                              "₹15,000",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      if (decorationRequired)
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Decoration:"),
                            Text(
                              "₹10,000",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      if (photographyRequired)
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Photography:"),
                            Text(
                              "₹5,000",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      const SizedBox(height: 12),
                      const Divider(thickness: 2),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total Amount:",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "₹${totalAmount.toStringAsFixed(0)}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.gold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Advance Amount (20%):",
                            style: TextStyle(fontSize: 14),
                          ),
                          Text(
                            "₹${advanceAmount.toStringAsFixed(0)}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                /// SUBMIT BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _startPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.gold,
                      disabledBackgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            "Book & Pay Now",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
