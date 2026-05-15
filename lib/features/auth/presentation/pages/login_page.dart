import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../providers/auth_provider.dart';

/// Pantalla de inicio de sesión premium.
/// Layout de dos columnas: panel decorativo izquierdo + formulario derecho.
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

  Future<void> _iniciarSesion() async {
    if (!_formKey.currentState!.validate()) return;
    final exito = await ref.read(authProvider.notifier).iniciarSesion(
      email: _emailController.text,
      contrasena: _contrasenaController.text,
    );
    if (exito && mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 1200;

    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.error!),
          backgroundColor: AppColors.error.withValues(alpha: 0.9),
        ));
        ref.read(authProvider.notifier).limpiarError();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Orbes de colores animados que se mueven suavemente al fondo
          _buildBackgroundOrbs(),

          // Contenedor principal centrado con efecto de cristal (glassmorphism)
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 820, 
                maxHeight: isWide ? 540 : size.height,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
                    ),
                    child: isWide
                        ? Row(children: [
                            // Panel lateral con la marca y el diseño de rejilla decorativa
                            Expanded(child: _buildBrandPanel()),
                            // Línea vertical sutil para separar los paneles
                            Container(
                              width: 1,
                              color: Colors.white.withValues(alpha: 0.05),
                            ),
                            // Sección derecha con los campos de texto para el acceso
                            SizedBox(width: 340, child: _buildFormPanel(authState)),
                          ])
                        : SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(height: 100, child: _buildBrandPanel(isMobile: true)),
                                Divider(height: 1, color: Colors.white.withValues(alpha: 0.05)),
                                _buildFormPanel(authState),
                              ],
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ).animate()
           .fadeIn(duration: 700.ms)
           .scale(begin: const Offset(0.96, 0.96), end: const Offset(1, 1), duration: 800.ms, curve: Curves.easeOutCubic),
        ],
      ),
    );
  }

  /// Panel izquierdo decorativo con logo, grid y estadísticas
  Widget _buildBrandPanel({bool isMobile = false}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.06),
            Colors.transparent,
            AppColors.primary.withValues(alpha: 0.03),
          ],
        ),
      ),
      child: Stack(
        children: [
          // El fondo de puntitos
          Positioned.fill(
            child: CustomPaint(painter: _DotGridPainter()),
          ),

          // Un brillito detrás del logo
          Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.15),
                    AppColors.primary.withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Información y logo dentro del panel
          Center(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 10 : 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo con color correcto
                  SvgPicture.asset(
                    'assets/images/logo-2.svg',
                    height: isMobile ? 32 : 64,
                    colorFilter: const ColorFilter.mode(
                      AppColors.primary,
                      BlendMode.srcIn,
                    ),
                    placeholderBuilder: (_) => Icon(
                      Icons.currency_exchange_rounded,
                      size: isMobile ? 32 : 64,
                      color: AppColors.primary,
                    ),
                  ).animate(onPlay: (c) => c.repeat(reverse: true))
                   .scale(
                     begin: const Offset(0.97, 0.97),
                     end: const Offset(1.03, 1.03),
                     duration: 2500.ms,
                     curve: Curves.easeInOut,
                   ),

                  SizedBox(height: isMobile ? 8 : 20),

                  // Nombre
                  Text(
                    'CHINCHIN',
                    style: TextStyle(
                      color: AppColors.onSurface,
                      fontSize: isMobile ? 14 : 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'INTERCAMBIO',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: isMobile ? 8 : 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 4,
                    ),
                  ),

                  if (!isMobile) const SizedBox(height: 28),

                  // Mini stats (Solo en desktop o si hay espacio)
                  if (!isMobile)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _miniStat('24/7', 'Mercado'),
                        _miniStatDivider(),
                        _miniStat('10+', 'Criptos'),
                        _miniStatDivider(),
                        _miniStat('0%', 'Comisión'),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: TextStyle(
          color: AppColors.primary,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        )),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(
          color: AppColors.onSurfaceMuted,
          fontSize: 8,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        )),
      ],
    );
  }

  Widget _miniStatDivider() {
    return Container(
      width: 1,
      height: 24,
      margin: const EdgeInsets.symmetric(horizontal: 18),
      color: AppColors.border.withValues(alpha: 0.4),
    );
  }

  /// Panel del formulario (lado derecho)
  Widget _buildFormPanel(AuthState authState) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Título
            Text(
              'Bienvenido',
              style: TextStyle(
                color: AppColors.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Ingresa tus credenciales para continuar',
              style: TextStyle(
                color: AppColors.onSurfaceMuted,
                fontSize: 11,
              ),
            ),

            const SizedBox(height: 24),

            // Email
            _buildField(
              controller: _emailController,
              label: 'Correo electrónico',
              hint: 'Email',
              icon: Icons.email_outlined,
              validator: Validators.email,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 14),

            // Contraseña
            _buildField(
              controller: _contrasenaController,
              label: 'Contraseña',
              hint: 'Contraseña',
              icon: Icons.lock_outline,
              validator: Validators.contrasena,
              obscure: !_mostrarContrasena,
              suffixIcon: IconButton(
                icon: Icon(
                  _mostrarContrasena ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppColors.onSurfaceMuted, size: 16,
                ),
                onPressed: () => setState(() => _mostrarContrasena = !_mostrarContrasena),
              ),
            ),

            const SizedBox(height: 22),

            // Botón
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: authState.estaCargando ? null : _iniciarSesion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  disabledBackgroundColor: AppColors.surfaceVariant,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  elevation: 0,
                ),
                child: authState.estaCargando
                    ? const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onPrimary),
                      )
                    : const Text('INGRESAR', style: TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 1.2,
                      )),
              ),
            ),

            const SizedBox(height: 16),

            // Registro
            Center(
              child: InkWell(
                onTap: () => context.go('/register'),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 11),
                      children: [
                        TextSpan(text: '¿No tienes cuenta? ', style: TextStyle(color: AppColors.onSurfaceMuted)),
                        TextSpan(text: 'Regístrate', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
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
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label.toUpperCase(), style: TextStyle(
          color: AppColors.onSurfaceMuted, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.6,
        )),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(color: AppColors.onSurface, fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.onSurfaceMuted.withValues(alpha: 0.4), fontSize: 13),
            prefixIcon: Icon(icon, color: AppColors.onSurfaceMuted, size: 16),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.surfaceVariant.withValues(alpha: 0.3),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.4)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.4)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            errorStyle: const TextStyle(fontSize: 9, height: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildBackgroundOrbs() {
    return Stack(
      children: [
        Positioned(top: -100, left: -50,
          child: _orb(250, AppColors.primary.withValues(alpha: 0.12))),
        Positioned(bottom: 100, right: -100,
          child: _orb(300, const Color(0xFF00A688).withValues(alpha: 0.1))),
        Positioned(top: 200, right: 100,
          child: _orb(150, const Color(0xFF00D4AA).withValues(alpha: 0.08))),
      ],
    );
  }

  Widget _orb(double size, Color color) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0.4), Colors.transparent],
        ),
      ),
    );
  }
}

/// Pinta un grid de puntos decorativos en el panel izquierdo
class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    const spacing = 24.0;
    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
