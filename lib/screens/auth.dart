import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../db/app_db.dart';
import '../widgets/common.dart';
import 'shell.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool loading = false, hide = true, remember = true;

  final email = TextEditingController();
  final pass = TextEditingController();

  String? err;
  bool errIsOk = false;

  Future<void> go() async {
    if (email.text.trim().isEmpty || pass.text.length < 4) {
      setState(() {
        err = 'Enter valid details (password min 4 characters).';
        errIsOk = false;
      });
      return;
    }

    setState(() => loading = true);

    try {
      final user = await AppDb.i.login(email.text, pass.text);
      if (!mounted) return;

      if (user == null) {
        setState(() {
          err = 'Invalid email or password.';
          errIsOk = false;
        });
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('login', remember);
        await prefs.setString(
          'admin_name',
          (user['name'] as String?) ?? 'Coach',
        );
        await prefs.setString(
          'admin_email',
          (user['email'] as String?) ?? email.text.trim(),
        );
        await prefs.setString('admin_id', '${user['id'] ?? ''}');
        await prefs.setString('admin_phone', (user['phone'] as String?) ?? '');

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Shell()),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          err = e.toString().replaceFirst('Exception: ', '');
          errIsOk = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  void dispose() {
    email.dispose();
    pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        // ==========================================================
        // BACKGROUND IMAGE
        // ==========================================================
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/login_gym_bg.png'),
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),

        // ==========================================================
        // DARK OVERLAY
        // Keeps the login form readable over the gym photo.
        // ==========================================================
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black.withValues(alpha: 0.38),

          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
                child: Column(
                  children: [
                    const BigLogo(),

                    const SizedBox(height: 26),

                    const Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Welcome Back, Owner',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),

                    const SizedBox(height: 4),

                    const Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Access your gym management hub',
                        style: TextStyle(color: Colors.white60),
                      ),
                    ),

                    const SizedBox(height: 18),

                    const SizedBox(height: 14),

                    // ==================================================
                    // LOGIN FORM
                    // ==================================================
                    Container(
                      padding: const EdgeInsets.fromLTRB(18, 6, 18, 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ============================================
                          // EMAIL
                          // ============================================
                          const FieldLabel('Email Address'),

                          TextField(
                            controller: email,
                            keyboardType: TextInputType.emailAddress,
                            decoration: fieldDeco(
                              hint: 'manager@thepowercave.com',
                              icon: Icons.mail_outline,
                            ),
                          ),

                          // ============================================
                          // PASSWORD
                          // ============================================
                          const FieldLabel('Password'),

                          TextField(
                            controller: pass,
                            obscureText: hide,
                            decoration: fieldDeco(
                              hint: '••••••••••',
                              icon: Icons.lock_outline,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    hide = !hide;
                                  });
                                },
                                icon: Icon(
                                  hide
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: muted,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),

                          // ============================================
                          // FORGOT PASSWORD
                          // ============================================
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => snack(
                                context,
                                'Contact your administrator to reset your password.',
                              ),
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: orange,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),

                          // ============================================
                          // REMEMBER DEVICE
                          // ============================================
                          InkWell(
                            onTap: () {
                              setState(() {
                                remember = !remember;
                              });
                            },
                            child: Row(
                              children: [
                                Checkbox(
                                  value: remember,
                                  activeColor: orange,
                                  checkColor: ink,
                                  onChanged: (v) {
                                    setState(() {
                                      remember = v ?? true;
                                    });
                                  },
                                ),
                                const Text(
                                  'Remember this device',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),

                          // ============================================
                          // ERROR / SUCCESS MESSAGE
                          // ============================================
                          if (err != null)
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: 10,
                                top: 4,
                              ),
                              child: Text(
                                err!,
                                style: TextStyle(
                                  color: errIsOk ? okGreen : warnRed,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                          const SizedBox(height: 6),

                          // ============================================
                          // LOGIN BUTTON
                          // ============================================
                          PrimaryButton(
                            'Sign In',
                            icon: Icons.arrow_forward_rounded,
                            busy: loading,
                            onPressed: go,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ==================================================
                    // SECURITY FOOTER
                    // ==================================================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.verified_user_outlined,
                          color: Colors.white54,
                          size: 16,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Sign in with your gym account',
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
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
