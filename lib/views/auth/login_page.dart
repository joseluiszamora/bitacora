import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/blocs/login/login_bloc.dart';
import '../../core/blocs/service_locator.dart';
import '../../core/components/app_snackbar.dart';
import '../../core/components/primary_button.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_defaults.dart';

/// Pantalla de login con Supabase Auth.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LoginBloc>(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == LoginStatus.failure &&
            state.errorMessage.isNotEmpty) {
          AppSnackbar.show(context, message: state.errorMessage, isError: true);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDefaults.paddingLarge,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // === Logo / Icono ===
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.local_shipping_rounded,
                      size: 52,
                      color: AppColors.gold,
                    ),
                  ),
                  const SizedBox(height: AppDefaults.marginMedium),

                  // === Título ===
                  const Text(
                    'BITÁCORA',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'de Transporte',
                    style: TextStyle(
                      color: AppColors.white.withValues(alpha: 0.7),
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppDefaults.marginBig + 10),

                  // === Formulario ===
                  Container(
                    padding: const EdgeInsets.all(AppDefaults.paddingLarge),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(
                        AppDefaults.radiusLarge,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Iniciar Sesión',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ingresa tus credenciales para continuar',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.grey.withValues(alpha: 0.8),
                            ),
                          ),
                          const SizedBox(height: AppDefaults.marginMedium),

                          // Email
                          _buildLabel('Correo electrónico'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _emailController,
                            focusNode: _emailFocusNode,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autocorrect: false,
                            style: const TextStyle(
                              color: AppColors.greyDark,
                              fontSize: 15,
                            ),
                            decoration: _inputDecoration(
                              hint: 'correo@ejemplo.com',
                              icon: Icons.email_outlined,
                            ),
                            onChanged: (value) {
                              context.read<LoginBloc>().add(
                                LoginEmailChanged(value),
                              );
                            },
                            onFieldSubmitted: (_) {
                              _passwordFocusNode.requestFocus();
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ingresa tu correo electrónico';
                              }
                              if (!RegExp(
                                r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,4}$',
                              ).hasMatch(value)) {
                                return 'Ingresa un correo válido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppDefaults.margin),

                          // Contraseña
                          _buildLabel('Contraseña'),
                          const SizedBox(height: 6),
                          BlocBuilder<LoginBloc, LoginState>(
                            buildWhen: (prev, curr) =>
                                prev.isPasswordVisible !=
                                curr.isPasswordVisible,
                            builder: (context, state) {
                              return TextFormField(
                                controller: _passwordController,
                                focusNode: _passwordFocusNode,
                                obscureText: !state.isPasswordVisible,
                                textInputAction: TextInputAction.done,
                                style: const TextStyle(
                                  color: AppColors.greyDark,
                                  fontSize: 15,
                                ),
                                decoration: _inputDecoration(
                                  hint: '••••••••',
                                  icon: Icons.lock_outline,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      state.isPasswordVisible
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: AppColors.grey,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      context.read<LoginBloc>().add(
                                        const LoginPasswordVisibilityToggled(),
                                      );
                                    },
                                  ),
                                ),
                                onChanged: (value) {
                                  context.read<LoginBloc>().add(
                                    LoginPasswordChanged(value),
                                  );
                                },
                                onFieldSubmitted: (_) => _submitForm(),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Ingresa tu contraseña';
                                  }
                                  if (value.length < 6) {
                                    return 'Mínimo 6 caracteres';
                                  }
                                  return null;
                                },
                              );
                            },
                          ),
                          const SizedBox(height: AppDefaults.marginBig),

                          // Botón de login
                          BlocBuilder<LoginBloc, LoginState>(
                            buildWhen: (prev, curr) =>
                                prev.status != curr.status,
                            builder: (context, state) {
                              return PrimaryButton(
                                text: 'Ingresar',
                                icon: Icons.login_rounded,
                                isLoading: state.status == LoginStatus.loading,
                                onPressed: _submitForm,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppDefaults.marginMedium),

                  // === Texto inferior ===
                  Text(
                    '© ${DateTime.now().year} Monval',
                    style: TextStyle(
                      color: AppColors.white.withValues(alpha: 0.4),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: AppDefaults.margin),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      context.read<LoginBloc>().add(const LoginSubmitted());
    }
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.greyDark,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: AppColors.grey.withValues(alpha: 0.6),
        fontSize: 14,
      ),
      prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDefaults.padding,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDefaults.radiusSmall + 4),
        borderSide: const BorderSide(color: AppColors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDefaults.radiusSmall + 4),
        borderSide: BorderSide(color: AppColors.grey.withValues(alpha: 0.35)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDefaults.radiusSmall + 4),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDefaults.radiusSmall + 4),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDefaults.radiusSmall + 4),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    );
  }
}
