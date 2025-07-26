import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unsplash_clone/screens/home.dart';
import 'package:unsplash_clone/models/user_model.dart';
import 'package:unsplash_clone/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:unsplash_clone/utils/auth_storage.dart';

class VerifyOtpPage extends StatefulWidget {
  final String email;

  const VerifyOtpPage({super.key, required this.email});

  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  final _otpController = TextEditingController();
  bool _isLoading = false;
  bool _resending = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    setState(() => _isLoading = true);

    try {
      final res = await Supabase.instance.client.auth.verifyOTP(
        token: _otpController.text.trim(),
        type: OtpType.signup,
        email: widget.email,
      );

      if (res.session != null) {
        await saveAuthToken(res.session!.accessToken);

        final user = UserModel(
          id: res.user!.id,
          email: res.user!.email ?? '',
          displayName:
              res.user!.userMetadata?['displayName'] ?? res.user!.email ?? '',
        );

        Provider.of<UserProvider>(context, listen: false).setUser(user);

        if (!mounted) return; // Pastikan widget masih aktif
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => HomePage()),
          (route) => false,
        );
      } else {
        _showError("Kode OTP salah atau sudah kadaluarsa.");
      }
    } catch (e) {
      _showError("Gagal verifikasi: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendOtp() async {
    setState(() => _resending = true);
    try {
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: widget.email,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kode OTP baru telah dikirim.")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal kirim ulang OTP: $e")));
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verifikasi OTP')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Masukkan kode OTP yang dikirim ke email: ${widget.email}"),
            const SizedBox(height: 16),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Kode OTP',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 41, 41, 41),
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Verifikasi"),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: _resending ? null : _resendOtp,
                child:
                    _resending
                        ? const CircularProgressIndicator()
                        : const Text("Kirim ulang kode OTP"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
