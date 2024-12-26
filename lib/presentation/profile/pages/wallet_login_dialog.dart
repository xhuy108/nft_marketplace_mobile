// lib/presentation/profile/widgets/wallet_login_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nft_marketplace_mobile/presentation/profile/bloc/profile_bloc.dart';

class WalletLoginDialog extends StatefulWidget {
  const WalletLoginDialog({super.key});

  @override
  State<WalletLoginDialog> createState() => _WalletLoginDialogState();
}

class _WalletLoginDialogState extends State<WalletLoginDialog> {
  final _formKey = GlobalKey<FormState>();
  final _privateKeyController = TextEditingController();
  bool _isObscured = true;

  @override
  void dispose() {
    _privateKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded) {
          Navigator.of(context).pop(); // Close dialog on successful login
        } else if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: AlertDialog(
        title: Text(
          'Connect Wallet',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _privateKeyController,
                obscureText: _isObscured,
                decoration: InputDecoration(
                  hintText: 'Enter private key (0x...)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscured ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscured = !_isObscured;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your private key';
                  }
                  if (!value.startsWith('0x')) {
                    return 'Private key must start with 0x';
                  }
                  if (value.length != 66) {
                    return 'Invalid private key length';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
          BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              return ElevatedButton(
                onPressed: state is ProfileLoading
                    ? null
                    : () {
                        if (_formKey.currentState?.validate() ?? false) {
                          context.read<ProfileBloc>().add(
                                ConnectWallet(
                                  privateKey: _privateKeyController.text,
                                ),
                              );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: state is ProfileLoading
                    ? SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Login',
                        style: TextStyle(color: Colors.white),
                      ),
              );
            },
          ),
        ],
      ),
    );
  }
}
