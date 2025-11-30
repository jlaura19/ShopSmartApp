# Security Policy

## Reporting Security Vulnerabilities

If you discover a security vulnerability in SmartShop, please email **jlaura19@github.com** with:
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if any)

**Do NOT open a public GitHub issue for security vulnerabilities.**

## Security Best Practices

### Firebase Credentials
- **NEVER** commit `lib/firebase_options.dart` to version control
- Always use `lib/firebase_options.dart.example` as a template
- Regenerate credentials if accidentally exposed
- Use FlutterFire CLI (`flutterfire configure`) to safely generate options

### Google API Keys
- Keep API keys private
- Rotate compromised keys immediately in Firebase Console
- Restrict key permissions to minimum required
- Use separate keys for development and production

### Android Configuration
- Keep `google-services.json` private
- Don't commit to public repositories
- Restrict Firebase rules to authenticated users only

### iOS Configuration
- Keep `GoogleService-Info.plist` private
- Use App Attest for additional security

### GitHub Secrets Scanning
- Enable GitHub's secret scanning for your repository
- Review and rotate any exposed credentials
- Monitor commit history for sensitive data

## Dependency Security

- Keep Flutter SDK updated
- Regularly update Firebase packages
- Review pub.dev security advisories
- Use `flutter pub outdated` to check for updates

## Environment Configuration

Use environment variables for sensitive data:
```bash
# DO NOT HARDCODE credentials in code
export FIREBASE_PROJECT_ID="your-project-id"
export FIREBASE_API_KEY="your-api-key"
```

## Rotating Compromised Credentials

If credentials are exposed:

1. **Firebase API Key:**
   - Go to Firebase Console → Project Settings
   - Click "Generate New Key" for the exposed key
   - Update `lib/firebase_options.dart` with the new key
   - Delete the old key

2. **google-services.json:**
   - Re-download from Firebase Console → Project Settings
   - Replace in `android/app/google-services.json`

3. **Force push (if committed to git):**
   ```bash
   git rm --cached lib/firebase_options.dart
   git commit -m "Remove exposed firebase credentials"
   git push -f
   ```

## Security Checklist

- [ ] `lib/firebase_options.dart` is in `.gitignore`
- [ ] No API keys in code comments
- [ ] No credentials in environment variables (use safe config files)
- [ ] Firebase rules set to require authentication
- [ ] Database rules restrict access appropriately
- [ ] No sensitive data logged to console
- [ ] Dependencies regularly updated
- [ ] Code reviewed before merging to master

## Third-Party Security Tools

### GitHub Secret Scanning
- Enable in repository settings
- Review any detected secrets immediately
- Rotate compromised credentials

### Snyk (Optional)
```bash
npm install -g snyk
snyk test
```

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Nov 30, 2025 | Initial security policy |

## Contact

For security inquiries: **jlaura19@github.com**

---

**Last Updated:** November 30, 2025
