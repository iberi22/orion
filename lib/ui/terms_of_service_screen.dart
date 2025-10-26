import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Términos de Servicio',
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
        future: _loadTermsOfService(),
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
                    'Error al cargar los términos de servicio',
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
                      'Aceptar',
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

  Future<String> _loadTermsOfService() async {
    try {
      return await rootBundle.loadString('assets/terms_of_service.md');
    } catch (e) {
      return _getDefaultTermsOfService();
    }
  }

  String _getDefaultTermsOfService() {
    return '''
# Términos de Servicio - Orion

**Última actualización: Enero 2025**

## Aceptación de Términos

Al descargar, instalar o usar la aplicación móvil Orion ("App"), aceptas estar sujeto a estos Términos de Servicio ("Términos"). Si no aceptas estos Términos, no uses la App.

## Descripción del Servicio

Orion es un compañero de bienestar impulsado por IA que proporciona:
- Recomendaciones de bienestar personalizadas
- Conversaciones de IA activadas por voz
- Guía de meditación y mindfulness
- Seguimiento del estado de ánimo e insights de bienestar
- Monitoreo de progreso y establecimiento de objetivos

## Cuentas de Usuario

### Creación de Cuenta
- Debes proporcionar información precisa y completa
- Eres responsable de mantener la seguridad de la cuenta
- Debes tener al menos 13 años para crear una cuenta
- Se permite una cuenta por persona

### Responsabilidades de la Cuenta
- Mantén seguras tus credenciales de inicio de sesión
- Notifícanos inmediatamente de cualquier acceso no autorizado
- Eres responsable de todas las actividades bajo tu cuenta
- No compartas tu cuenta con otros

## Uso Aceptable

### Puedes
- Usar la App para bienestar personal y automejora
- Compartir tu progreso con proveedores de atención médica
- Proporcionar comentarios para mejorar el servicio
- Exportar tus datos personales

### No Puedes
- Usar la App para propósitos ilegales o dañinos
- Intentar hacer ingeniería inversa o hackear la App
- Compartir contenido inapropiado a través de funciones de voz
- Violar la privacidad o derechos de otros
- Usar la App para proporcionar consejos médicos a otros

## Descargo de Responsabilidad Médica

**IMPORTANTE**: Orion no es un dispositivo médico y no proporciona consejos médicos, diagnóstico o tratamiento.

- La App es solo para propósitos de bienestar y educativos
- Siempre consulta a profesionales de la salud para preocupaciones médicas
- No uses la App como sustituto de atención médica profesional
- En caso de emergencia, contacta a los servicios de emergencia inmediatamente

## Propiedad Intelectual

### Nuestros Derechos
- Poseemos todos los derechos de la App, incluyendo diseño, código y modelos de IA
- Nuestras marcas comerciales y logos están protegidos
- Los comentarios de usuarios pueden usarse para mejorar el servicio

### Tus Derechos
- Mantienes la propiedad de tus datos personales
- Nos otorgas licencia para usar tus datos como se describe en nuestra Política de Privacidad
- Puedes solicitar la eliminación de datos en cualquier momento

## Limitación de Responsabilidad

EN LA MÁXIMA MEDIDA PERMITIDA POR LA LEY:
- No somos responsables de daños indirectos, incidentales o consecuentes
- Nuestra responsabilidad total se limita a la cantidad que pagaste por el servicio
- No garantizamos que la App esté libre de errores o ininterrumpida
- Usas la App bajo tu propio riesgo

## Terminación

### Por Ti
- Puedes eliminar tu cuenta en cualquier momento
- Cancelar la suscripción detiene la facturación futura
- Algunos datos pueden retenerse según lo requerido por la ley

### Por Nosotros
- Podemos terminar cuentas por violaciones de los Términos
- Podemos discontinuar el servicio con aviso razonable
- Los datos se manejarán según nuestra Política de Privacidad

## Información de Contacto

Para preguntas sobre estos Términos:
- **Email**: legal@orion-wellness.com
- **Sitio Web**: https://orion-wellness.com/terms
- **En la App**: Usa la función "Contactar Soporte"

---

*Al usar Orion, reconoces que has leído, entendido y aceptas estar sujeto a estos Términos de Servicio.*
    ''';
  }
}
