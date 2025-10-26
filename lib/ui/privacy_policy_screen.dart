import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Política de Privacidad',
          style: GoogleFonts.lato(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<String>(
        future: _loadPrivacyPolicy(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar la política de privacidad',
                    style: GoogleFonts.lato(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Volver'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  snapshot.data ?? '',
                  style: GoogleFonts.lato(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 32),
                Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
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
                      'Entendido',
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<String> _loadPrivacyPolicy() async {
    try {
      return await rootBundle.loadString('assets/privacy_policy.md');
    } catch (e) {
      return _getDefaultPrivacyPolicy();
    }
  }

  String _getDefaultPrivacyPolicy() {
    return '''
# Política de Privacidad - Orion

**Última actualización: Enero 2025**

## Introducción

Bienvenido a Orion, tu compañero de bienestar impulsado por IA. Esta Política de Privacidad explica cómo recopilamos, usamos, divulgamos y protegemos tu información cuando usas nuestra aplicación móvil.

## Información que Recopilamos

### Información Personal
- **Información de Cuenta**: Dirección de email, nombre e información de perfil cuando creas una cuenta
- **Datos de Voz**: Grabaciones de audio para la funcionalidad de chat por voz (procesadas localmente y no almacenadas permanentemente)
- **Datos de Bienestar**: Sesiones de meditación, seguimiento del estado de ánimo y objetivos de bienestar que elijas compartir

### Información Recopilada Automáticamente
- **Datos de Uso**: Patrones de uso de la app, interacciones con funciones y duración de sesiones
- **Información del Dispositivo**: Tipo de dispositivo, sistema operativo, versión de la app e identificadores únicos del dispositivo
- **Datos de Rendimiento**: Reportes de fallos y métricas de rendimiento para mejorar la estabilidad de la app

## Cómo Usamos tu Información

Usamos tu información para:
- Proporcionar recomendaciones de bienestar personalizadas con IA
- Procesar comandos de voz y proporcionar funciones de IA conversacional
- Rastrear tu progreso y objetivos de bienestar
- Mejorar la funcionalidad y experiencia de usuario de la app
- Enviar actualizaciones importantes y notificaciones
- Proporcionar soporte al cliente

## Almacenamiento y Seguridad de Datos

### Almacenamiento Local
- Las grabaciones de voz se procesan localmente en tu dispositivo
- Los datos personales de bienestar se almacenan de forma segura en tu dispositivo
- Los datos sensibles se cifran usando cifrado estándar de la industria

### Almacenamiento en la Nube
- La información de cuenta se almacena de forma segura en Firebase
- Los datos de progreso de bienestar pueden sincronizarse entre tus dispositivos
- Todos los datos en la nube se cifran en tránsito y en reposo

## Tus Derechos y Opciones

Tienes derecho a:
- Acceder a tus datos personales
- Corregir información inexacta
- Eliminar tu cuenta y datos
- Optar por no recibir comunicaciones no esenciales
- Exportar tus datos

## Contacto

Si tienes preguntas sobre esta Política de Privacidad o nuestras prácticas de datos, contáctanos:

- **Email**: privacy@orion-wellness.com
- **Sitio Web**: https://orion-wellness.com/privacy
- **En la App**: Usa la función "Contactar Soporte" en la configuración de la app

## Consentimiento

Al usar Orion, consientes la recopilación y uso de tu información como se describe en esta Política de Privacidad.

---

*Esta política de privacidad está diseñada para ser transparente y completa. Estamos comprometidos a proteger tu privacidad y proporcionarte control sobre tu información personal.*
    ''';
  }
}
