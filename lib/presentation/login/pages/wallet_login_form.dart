import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:nft_marketplace_mobile/presentation/profile/bloc/profile_bloc.dart';

class WalletLoginForm extends StatefulWidget {
  const WalletLoginForm({super.key});

  @override
  State<WalletLoginForm> createState() => _WalletLoginFormState();
}

class _WalletLoginFormState extends State<WalletLoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _privateKeyController = TextEditingController();
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return Form(
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
                onPressed: () => setState(() => _isObscured = !_isObscured),
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
          Gap(16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ),
              Gap(8.w),
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
                            'Connect',
                            style: TextStyle(color: Colors.white),
                          ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _privateKeyController.dispose();
    super.dispose();
  }
}
