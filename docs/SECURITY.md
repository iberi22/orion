# Security Guidelines

This document outlines the security measures implemented in the Orion voice assistant application and provides guidelines for maintaining security in production.

## 🔒 Security Overview

### Implemented Security Measures

1. **Input Validation and Sanitization**
2. **Secure API Key Management**
3. **Firebase Security Rules**
4. **Browser Permission Security**
5. **Data Validation**
6. **Error Handling Security**

## 🛡️ Input Validation

### InputValidator Class (`lib/utils/input_validator.dart`)

The application implements comprehensive input validation for all user inputs and AI interactions:

#### Audio Data Validation
- **Size Limits**: 1KB minimum, 50MB maximum
- **Format Validation**: Checks for valid audio file signatures
- **Content Validation**: Prevents malicious audio data

#### Text Input Validation
- **Length Limits**: Maximum 10,000 characters for general text, 2,000 for prompts
- **Content Filtering**: Removes potentially dangerous characters and patterns
- **Injection Prevention**: Detects and blocks various injection attempts

#### AI Prompt Security
- **Prompt Injection Detection**: Identifies attempts to manipulate AI behavior
- **System Prompt Protection**: Prevents unauthorized system instruction changes
- **Context Validation**: Limits and validates conversation context

### Validation Patterns Detected

```dart
// Script injection
RegExp(r'<script[^>]*>', caseSensitive: false)
RegExp(r'javascript:', caseSensitive: false)

// SQL injection
RegExp(r'(union|select|insert|update|delete|drop|create|alter)\s+', caseSensitive: false)

// Command injection
RegExp(r'[;&|`$]', caseSensitive: false)

// Prompt injection
RegExp(r'ignore\s+(previous|all)\s+(instructions|prompts)', caseSensitive: false)
```

## 🔑 API Key Management

### Environment Variables
All sensitive credentials are stored in environment variables:

```env
# Required API keys
GEMINI_API_KEY=your_gemini_api_key_here
VERTEX_AI_PROJECT_ID=your-project-id

# Optional service account (for server-side auth)
VERTEX_AI_SERVICE_ACCOUNT_KEY_PATH=path/to/service-account-key.json
```

### Security Best Practices
- ✅ **No Hardcoded Secrets**: All credentials loaded from `.env` files
- ✅ **Git Ignore**: `.env` files excluded from version control
- ✅ **Validation**: Configuration validation on app startup
- ✅ **Debug Protection**: Sensitive data not logged in production

### Firebase Configuration
Firebase API keys in `firebase_options.dart` are **public by design** and safe to include in client applications. They identify your Firebase project but don't grant access to data without proper authentication.

## 🔥 Firebase Security Rules

### Firestore Rules (`firestore.rules`)
Implemented strict security rules for data access:

```javascript
// User data - only authenticated users can access their own data
match /users/{userId} {
  allow read, write: if request.auth != null && request.auth.uid == userId;
}

// Agent memories - user-specific access only
match /agent_memories/{memoryId} {
  allow read, write: if request.auth != null && 
    resource.data.userId == request.auth.uid;
}
```

### Key Security Features
- **Authentication Required**: All data access requires valid authentication
- **User Isolation**: Users can only access their own data
- **Principle of Least Privilege**: Minimal necessary permissions granted
- **Public Data Protection**: Configuration data is read-only

## 🌐 Browser Security

### Permission Management
- **Graceful Requests**: User-friendly microphone permission flow
- **Error Handling**: Secure handling of permission denials
- **Browser Detection**: Optimized security for different browsers

### Web Audio Security
- **Input Validation**: Audio data validated before processing
- **Size Limits**: Prevents memory exhaustion attacks
- **Format Checking**: Validates audio file formats

## 📊 Data Validation

### AI Response Validation
All AI responses are validated for:
- **Content Safety**: Harmful content detection
- **Personal Information**: PII detection and removal
- **Malicious Instructions**: Prevents harmful command suggestions

### Audio Processing Security
- **Format Validation**: Ensures valid audio formats
- **Size Constraints**: Prevents oversized uploads
- **Content Scanning**: Basic audio content validation

## ⚠️ Error Handling Security

### Secure Error Messages
- **Information Disclosure Prevention**: Generic error messages for users
- **Debug Information**: Detailed errors only in debug mode
- **Logging Security**: Sensitive data excluded from logs

### Example Secure Error Handling
```dart
try {
  // Sensitive operation
} catch (e) {
  // Log detailed error (debug only)
  if (kDebugMode) {
    print('Detailed error: $e');
  }
  
  // Return generic user message
  return 'An error occurred. Please try again.';
}
```

## 🚨 Security Checklist

### Pre-Production Security Review

- [ ] **Environment Variables**
  - [ ] All API keys in `.env` files
  - [ ] No hardcoded credentials in code
  - [ ] `.env` files in `.gitignore`

- [ ] **Input Validation**
  - [ ] All user inputs validated
  - [ ] Audio data size limits enforced
  - [ ] AI prompts sanitized

- [ ] **Firebase Security**
  - [ ] Security rules implemented
  - [ ] Authentication required for data access
  - [ ] User data isolation enforced

- [ ] **Browser Security**
  - [ ] Permission requests handled securely
  - [ ] Error messages don't expose sensitive data
  - [ ] HTTPS enforced in production

- [ ] **Code Security**
  - [ ] No sensitive data in logs
  - [ ] Error handling prevents information disclosure
  - [ ] Dependencies regularly updated

## 🔧 Security Configuration

### Production Deployment
1. **HTTPS Required**: All production deployments must use HTTPS
2. **Environment Separation**: Use different API keys for development/production
3. **Regular Updates**: Keep dependencies and Firebase SDK updated
4. **Monitoring**: Implement security monitoring and alerting

### Security Headers (Web Deployment)
```html
<!-- Add to web/index.html for production -->
<meta http-equiv="Content-Security-Policy" content="default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline';">
<meta http-equiv="X-Content-Type-Options" content="nosniff">
<meta http-equiv="X-Frame-Options" content="DENY">
```

## 📞 Security Incident Response

### If Security Issue Detected
1. **Immediate Action**: Disable affected functionality
2. **Assessment**: Evaluate scope and impact
3. **Mitigation**: Implement fixes and security patches
4. **Communication**: Notify users if data was compromised
5. **Review**: Update security measures to prevent recurrence

### Contact Information
- **Security Issues**: Report to development team immediately
- **Emergency Response**: Follow incident response procedures
- **Regular Reviews**: Conduct quarterly security assessments

## 📚 Additional Resources

- [Firebase Security Rules Documentation](https://firebase.google.com/docs/rules)
- [Flutter Security Best Practices](https://docs.flutter.dev/security)
- [OWASP Mobile Security](https://owasp.org/www-project-mobile-security/)
- [Google Cloud Security](https://cloud.google.com/security)

---

**Last Updated**: January 2025  
**Review Schedule**: Quarterly security reviews required
