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

/// Pantalla de inicio de sesión.
/// Presenta un formulario glassmorphic sobre un fondo de partículas animadas
/// con efectos de parallax, staggered animations y micro-interacciones.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _contrasenaController = TextEditingController();
  bool _mostrarContrasena = false;

  @override
  void dispose() {
    _emailController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  /// Procesa el inicio de sesión validando el formulario
  Future<void> _iniciarSesion() async {
    if (!_formKey.currentState!.validate()) return;

    final exito = await ref.read(authProvider.notifier).iniciarSesion(
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
    final screenSize = MediaQuery.of(context).size;

    // Escuchar errores para mostrar feedback visual
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
                    color: Colors.white,
                    colorBlendMode: BlendMode.srcIn,
                    errorBuilder: (_, __, ___) => const Text('CHINCHIN',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 28,
                        letterSpacing: 2,
                      ),
                    ),
                  )
                      .animate()
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1, 1),
                        duration: 600.ms,
                        curve: Curves.easeOutBack,
                      )
                      .fadeIn(duration: 400.ms),

                  const SizedBox(height: 8),

                  Text(
                    'Intercambio seguro y profesional',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                      letterSpacing: 1.1,
                    ),
                    textAlign: TextAlign.center,
                  )
                      .animate()
                      .fadeIn(delay: 350.ms, duration: 500.ms),

                  const SizedBox(height: 40),

                  // ── Formulario ─────────────────────────────
                  GlassmorphicCard(
                    padding: const EdgeInsets.all(28),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Iniciar Sesión',
                            style: AppTypography.h3.copyWith(
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Ingresa tus credenciales para acceder',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Campo de email
                          _buildTextField(
                            controller: _emailController,
                            label: 'Correo electrónico',
                            hint: 'tu@email.com',
                            icon: Icons.email_outlined,
                            validator: Validators.email,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),

                          // Campo de contraseña
                          _buildTextField(
                            controller: _contrasenaController,
                            label: 'Contraseña',
                            hint: '••••••••',
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
                          const SizedBox(height: 28),

                          // Botón de iniciar sesión
                          GradientButton(
                            text: 'Iniciar Sesión',
                            icon: Icons.login_rounded,
                            isLoading: authState.estaCargando,
                            onPressed: authState.estaCargando
                                ? null
                                : _iniciarSesion,
                          ),
                          const SizedBox(height: 16),

                          // Enlace a registro
                          Center(
                            child: TextButton(
                              onPressed: () => context.go('/register'),
                              child: RichText(
                                text: TextSpan(
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                  children: [
                                    const TextSpan(text: '¿No tienes cuenta? '),
                                    TextSpan(
                                      text: 'Regístrate',
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

  /// Construye el logo de la app con efecto de glow pulsante
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

  /// Construye un campo de texto estilizado con icono y validación
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
