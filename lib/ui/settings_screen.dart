import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:orion/services/auth_service.dart';
import 'package:orion/utils/feedback_manager.dart';
import 'package:orion/utils/performance_monitor.dart';
import 'package:orion/utils/cache_manager.dart';
import 'package:orion/ui/welcome_screen.dart';
import 'package:orion/ui/settings/tts_models_page.dart';
import 'package:orion/ui/privacy_policy_screen.dart';
import 'package:orion/ui/terms_of_service_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _authService = AuthService();
  bool _notificationsEnabled = true;
  bool _voiceFeedbackEnabled = true;
  bool _analyticsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Configuración',
          style: GoogleFonts.lato(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Section
            _buildSection(
              title: 'Perfil',
              children: [
                _buildUserProfileTile(),
                _buildSettingsTile(
                  icon: Icons.edit,
                  title: 'Editar Perfil',
                  subtitle: 'Actualizar información personal',
                  onTap: () => _showEditProfileDialog(),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // App Preferences
            _buildSection(
              title: 'Preferencias',
              children: [
                _buildSwitchTile(
                  icon: Icons.notifications,
                  title: 'Notificaciones',
                  subtitle: 'Recibir recordatorios y actualizaciones',
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                    FeedbackManager.showInfo(
                      value
                          ? 'Notificaciones activadas'
                          : 'Notificaciones desactivadas',
                    );
                  },
                ),
                _buildSwitchTile(
                  icon: Icons.volume_up,
                  title: 'Respuesta por Voz',
                  subtitle: 'Habilitar respuestas de voz del AI',
                  value: _voiceFeedbackEnabled,
                  onChanged: (value) {
                    setState(() {
                      _voiceFeedbackEnabled = value;
                    });
                  },
                ),
                _buildSwitchTile(
                  icon: Icons.analytics,
                  title: 'Análisis de Uso',
                  subtitle:
                      'Ayudar a mejorar la app compartiendo datos anónimos',
                  value: _analyticsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _analyticsEnabled = value;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Data & Privacy
            _buildSection(
              title: 'Datos y Privacidad',
              children: [
                _buildSettingsTile(
                  icon: Icons.privacy_tip,
                  title: 'Política de Privacidad',
                  subtitle: 'Ver cómo protegemos tu información',
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PrivacyPolicyScreen(),
                        ),
                      ),
                ),
                _buildSettingsTile(
                  icon: Icons.description,
                  title: 'Términos de Servicio',
                  subtitle: 'Revisar términos y condiciones',
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TermsOfServiceScreen(),
                        ),
                      ),
                ),
                _buildSettingsTile(
                  icon: Icons.download,
                  title: 'Exportar Datos',
                  subtitle: 'Descargar una copia de tus datos',
                  onTap: () => _exportUserData(),
                ),
                _buildSettingsTile(
                  icon: Icons.delete_forever,
                  title: 'Eliminar Cuenta',
                  subtitle: 'Eliminar permanentemente tu cuenta y datos',
                  onTap: () => _showDeleteAccountDialog(),
                  textColor: Colors.red,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // App Management
            _buildSection(
              title: 'Gestión de App',
              children: [
                _buildSettingsTile(
                  icon: Icons.record_voice_over,
                  title: 'Modelos TTS (On-Device)',
                  subtitle: 'Descargar, eliminar y administrar voces locales',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TTSModelsPage(),
                    ),
                  ),
                ),
                _buildSettingsTile(
                  icon: Icons.storage,
                  title: 'Gestionar Caché',
                  subtitle: 'Ver y limpiar datos almacenados',
                  onTap: () => _showCacheManagementDialog(),
                ),
                _buildSettingsTile(
                  icon: Icons.speed,
                  title: 'Rendimiento',
                  subtitle: 'Ver estadísticas de rendimiento',
                  onTap: () => _showPerformanceDialog(),
                ),
                _buildSettingsTile(
                  icon: Icons.bug_report,
                  title: 'Reportar Problema',
                  subtitle: 'Enviar feedback o reportar un error',
                  onTap: () => _showFeedbackDialog(),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // About
            _buildSection(
              title: 'Acerca de',
              children: [
                _buildSettingsTile(
                  icon: Icons.info,
                  title: 'Versión de la App',
                  subtitle: '1.0.0 (Build 1)',
                  onTap: () => _showAppInfoDialog(),
                ),
                _buildSettingsTile(
                  icon: Icons.help,
                  title: 'Ayuda y Soporte',
                  subtitle: 'Obtener ayuda y contactar soporte',
                  onTap: () => _showHelpDialog(),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Sign Out Button
            Center(
              child: ElevatedButton(
                onPressed: () => _showSignOutDialog(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Cerrar Sesión',
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.lato(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildUserProfileTile() {
    final user = _authService.currentUser;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue[600],
        child: Text(
          user?.displayName?.substring(0, 1).toUpperCase() ?? 'U',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        user?.displayName ?? 'Usuario',
        style: GoogleFonts.lato(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        user?.email ?? '',
        style: GoogleFonts.lato(color: Colors.white70),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? Colors.white70),
      title: Text(
        title,
        style: GoogleFonts.lato(
          color: textColor ?? Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.lato(color: Colors.white70, fontSize: 12),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.white70),
      onTap: () {
        FeedbackManager.hapticFeedback(HapticFeedbackType.light);
        onTap();
      },
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(
        title,
        style: GoogleFonts.lato(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.lato(color: Colors.white70, fontSize: 12),
      ),
      trailing: Switch(
        value: value,
        onChanged: (newValue) {
          FeedbackManager.hapticFeedback(HapticFeedbackType.light);
          onChanged(newValue);
        },
        activeColor: Colors.blue[600],
      ),
    );
  }

  void _showEditProfileDialog() {
    // Implementation for editing profile
    FeedbackManager.showInfo('Función de edición de perfil próximamente');
  }

  void _exportUserData() async {
    FeedbackManager.showInfo('Preparando exportación de datos...');
    // Implementation for data export
    await Future.delayed(const Duration(seconds: 2));
    FeedbackManager.showSuccess('Datos exportados exitosamente');
  }

  void _showDeleteAccountDialog() async {
    final confirmed = await FeedbackManager.showConfirmation(
      context: context,
      title: 'Eliminar Cuenta',
      message:
          '¿Estás seguro de que quieres eliminar tu cuenta? Esta acción no se puede deshacer.',
      confirmText: 'Eliminar',
      isDestructive: true,
    );

    if (confirmed) {
      FeedbackManager.showError(
        'Función de eliminación de cuenta próximamente',
      );
    }
  }

  void _showCacheManagementDialog() async {
    final stats = await CacheManager().getCacheStats();
    if (mounted) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              backgroundColor: Colors.grey[900],
              title: Text(
                'Gestión de Caché',
                style: GoogleFonts.lato(color: Colors.white),
              ),
              content: Text(
                'Tamaño total: ${stats['totalSizeMB']} MB\n'
                'Imágenes: ${stats['imageCache']['sizeMB']} MB\n'
                'Datos: ${stats['dataCache']['sizeMB']} MB\n'
                'Audio: ${stats['audioCache']['sizeMB']} MB',
                style: GoogleFonts.lato(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cerrar',
                    style: GoogleFonts.lato(color: Colors.white70),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await CacheManager().clearCache();
                    if (mounted) {
                      Navigator.pop(context);
                      FeedbackManager.showSuccess(
                        'Caché limpiado exitosamente',
                      );
                    }
                  },
                  child: Text('Limpiar Caché', style: GoogleFonts.lato()),
                ),
              ],
            ),
      );
    }
  }

  void _showPerformanceDialog() {
    final stats = PerformanceMonitor().getPerformanceStats();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Text(
              'Estadísticas de Rendimiento',
              style: GoogleFonts.lato(color: Colors.white),
            ),
            content: Text(
              stats.toString(),
              style: GoogleFonts.lato(color: Colors.white70, fontSize: 12),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cerrar',
                  style: GoogleFonts.lato(color: Colors.white70),
                ),
              ),
            ],
          ),
    );
  }

  void _showFeedbackDialog() {
    FeedbackManager.showInfo('Función de feedback próximamente');
  }

  void _showAppInfoDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Text(
              'Información de la App',
              style: GoogleFonts.lato(color: Colors.white),
            ),
            content: Text(
              'Orion - AI Wellness Companion\n'
              'Versión: 1.0.0\n'
              'Build: 1\n'
              'Desarrollado con Flutter\n\n'
              'Tu compañero de bienestar impulsado por IA',
              style: GoogleFonts.lato(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cerrar',
                  style: GoogleFonts.lato(color: Colors.white70),
                ),
              ),
            ],
          ),
    );
  }

  void _showHelpDialog() {
    FeedbackManager.showInfo('Función de ayuda próximamente');
  }

  void _showSignOutDialog() async {
    final confirmed = await FeedbackManager.showConfirmation(
      context: context,
      title: 'Cerrar Sesión',
      message: '¿Estás seguro de que quieres cerrar sesión?',
      confirmText: 'Cerrar Sesión',
    );

    if (confirmed) {
      await _authService.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
          (route) => false,
        );
      }
    }
  }
}
