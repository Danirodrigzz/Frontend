import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/glassmorphic_card.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../../../shared/widgets/particle_background.dart';
import '../providers/auth_provider.dart';

/// Pantalla de registro de nuevos usuarios.
/// Formulario con validación en tiempo real y animaciones escalonadas.
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _confirmarController = TextEditingController();
  bool _mostrarContrasena = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _contrasenaController.dispose();
    _confirmarController.dispose();
    super.dispose();
  }

  /// Procesa el registro validando todos los campos
  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;

    final exito = await ref.read(authProvider.notifier).registrar(
      nombre: _nombreController.text,
      email: _emailController.text,
      contrasena: _contrasenaController.text,
    );

    if (exito && mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Mostrar errores con snackbar
    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error.withValues(alpha: 0.9),
          ),
        );
        ref.read(authProvider.notifier).limpiarError();
      }
    });

    return Scaffold(
      body: ParticleBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ── Logo Oficial ChinChin ──────────────────────────
                  Image.asset(
                    'assets/images/logo.png',
                    height: 80,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => _buildLogo(),
                  )
                      .animate()
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1, 1),
                        duration: 600.ms,
                        curve: Curves.easeOutBack,
                      )
                      .fadeIn(duration: 400.ms),

                  const SizedBox(height: 12),

                  Text(
                    'Crea tu cuenta profesional',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: 1.1,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 500.ms)
                      .slideY(begin: 0.3, end: 0, delay: 200.ms),

                  const SizedBox(height: 4),

                  Text(
                    'Únete al intercambio de criptomonedas más confiable',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  )
                      .animate()
                      .fadeIn(delay: 350.ms, duration: 500.ms),

                  const SizedBox(height: 32),

                  // ── Formulario ─────────────────────────────
                  GlassmorphicCard(
                    padding: const EdgeInsets.all(28),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Registro',
                            style: AppTypography.h3.copyWith(
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Completa tus datos para crear tu cuenta',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Nombre de usuario
                          _buildTextField(
                            controller: _nombreController,
                            label: 'Nombre de usuario',
                            hint: 'Ej: juan_crypto',
                            icon: Icons.person_outline,
                            validator: Validators.nombreUsuario,
                          ),
                          const SizedBox(height: 14),

                          // Correo electrónico
                          _buildTextField(
                            controller: _emailController,
                            label: 'Correo electrónico',
                            hint: 'tu@email.com',
                            icon: Icons.email_outlined,
                            validator: Validators.email,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 14),

                          // Contraseña
                          _buildTextField(
                            controller: _contrasenaController,
                            label: 'Contraseña',
                            hint: 'Mínimo 8 caracteres',
                            icon: Icons.lock_outline,
                            validator: Validators.contrasena,
                            obscure: !_mostrarContrasena,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _mostrarContrasena
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.onSurfaceVariant,
                                size: 20,
                              ),
                              onPressed: () => setState(() {
                                _mostrarContrasena = !_mostrarContrasena;
                              }),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Confirmar contraseña
                          _buildTextField(
                            controller: _confirmarController,
                            label: 'Confirmar contraseña',
                            hint: 'Repite tu contraseña',
                            icon: Icons.lock_outline,
                            obscure: !_mostrarContrasena,
                            validator: (value) => Validators.confirmarContrasena(
                              value,
                              _contrasenaController.text,
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Botón de registro
                          GradientButton(
                            text: 'Crear Cuenta',
                            icon: Icons.how_to_reg_rounded,
                            isLoading: authState.estaCargando,
                            onPressed: authState.estaCargando
                                ? null
                                : _registrar,
                          ),
                          const SizedBox(height: 16),

                          // Enlace a login
                          Center(
                            child: TextButton(
                              onPressed: () => context.go('/login'),
                              child: RichText(
                                text: TextSpan(
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                  children: [
                                    const TextSpan(text: '¿Ya tienes cuenta? '),
                                    TextSpan(
                                      text: 'Inicia sesión',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 600.ms)
                      .slideY(begin: 0.15, end: 0, delay: 400.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Icon(
        Icons.currency_exchange_rounded,
        color: AppColors.onPrimary,
        size: 40,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          validator: validator,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.onSurface,
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.onSurfaceVariant, size: 20),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
