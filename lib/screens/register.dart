import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unsplash_clone/screens/verify_otp.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool isVendor = false;

  final TextEditingController firstController = TextEditingController();
  final TextEditingController secondController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (response.user != null) {
        if (!mounted) return;

        // Alihkan ke halaman verifikasi OTP setelah pendaftaran berhasil
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => VerifyOtpPage(email: emailController.text.trim()),
          ),
        );
      } else {
        throw Exception("Gagal mendaftar");
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal daftar: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome to',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const Text(
                  'Unsplash Clone',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Silahkan daftar untuk membuat akun.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 24),

                // Toggle Customer / Vendor
                Center(
                  child: ToggleButtons(
                    isSelected: [!isVendor, isVendor],
                    onPressed: (index) {
                      setState(() {
                        isVendor = index == 1;
                        clearForm();
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    borderWidth: 1.5,
                    selectedBorderColor: const Color.fromARGB(255, 41, 41, 41),
                    selectedColor: Colors.white,
                    fillColor: const Color.fromARGB(255, 41, 41, 41),
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        child: Text('Customer'),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        child: Text('Vendor'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                ...buildFormFields(),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 41, 41, 41),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _isLoading ? null : _register,
                    child:
                        _isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text(
                              'Sign Up',
                              style: TextStyle(color: Colors.white70),
                            ),
                  ),
                ),

                const SizedBox(height: 16),
                const Text(
                  'Dengan mendaftar, kamu menyetujui syarat & ketentuan kami.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Sudah punya akun? "),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> buildFormFields() {
    return [
      inputField("Nama Depan", firstController),
      inputField("Nama Belakang", secondController),
      inputField(
        "Email",
        emailController,
        type: TextInputType.emailAddress,
        validator: (value) {
          if (value == null || value.isEmpty) return 'Email wajib diisi';
          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
            return 'Format email tidak valid';
          }
          return null;
        },
      ),
      inputField("Nomor Telepon", phoneController, type: TextInputType.phone),
      inputField("Alamat", addressController),
      inputField("Kota", cityController),
      inputField(
        "Kata Sandi",
        passwordController,
        obscure: true,
        validator: (value) {
          if (value == null || value.isEmpty) return 'Password wajib diisi';
          if (value.length < 6) return 'Minimal 6 karakter';
          return null;
        },
      ),
      inputField(
        "Konfirmasi Kata Sandi",
        confirmPasswordController,
        obscure: true,
        validator: (value) {
          if (value != passwordController.text) return 'Password tidak sama';
          return null;
        },
      ),
    ];
  }

  Widget inputField(
    String label,
    TextEditingController controller, {
    TextInputType type = TextInputType.text,
    bool obscure = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: type,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color.fromARGB(255, 41, 41, 41)),
          ),
        ),
      ),
    );
  }

  void clearForm() {
    firstController.clear();
    secondController.clear();
    emailController.clear();
    phoneController.clear();
    addressController.clear();
    cityController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
  }
}
