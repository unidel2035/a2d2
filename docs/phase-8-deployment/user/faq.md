# DOC-USER-004 / SUPP-004: Frequently Asked Questions (FAQ)

**Version**: 1.0
**Last Updated**: 2025-10-28

## General

### What is A2D2?
A2D2 (Automation to Automation Delivery) is an intelligent automation platform that uses AI agents to automate business processes, document processing, and data analysis.

### Who can use A2D2?
A2D2 is designed for businesses of all sizes looking to automate repetitive tasks, process documents, and leverage AI for decision-making.

### Is A2D2 available in Russian?
Yes, A2D2 fully supports Russian language and complies with Russian legislation (ФЗ-152, ГОСТ requirements).

### Do I need VPN to access A2D2?
No, A2D2 is accessible from Russia and CIS countries without VPN.

## Account & Access

### How do I get access?
Contact your system administrator or sales team at sales@example.com

### I forgot my password. How do I reset it?
Click "Forgot Password" on the login page and follow instructions sent to your email.

### How do I enable Two-Factor Authentication (2FA)?
1. Go to Profile Settings
2. Click Security tab
3. Enable 2FA
4. Scan QR code with authenticator app
5. Enter verification code

### Can I use A2D2 on mobile?
Yes, A2D2 is fully responsive and works on mobile browsers. Native apps are coming soon.

## Documents

### What file formats are supported?
- Documents: PDF, DOCX, DOC, TXT, RTF
- Spreadsheets: XLSX, XLS, CSV
- Images: JPG, PNG, TIFF, BMP
- Archives: ZIP (auto-extracts)

### What's the maximum file size?
Default: 100 MB per file. Contact admin for larger files.

### How long are documents stored?
Documents are stored indefinitely unless deleted. Archived documents can be configured for auto-deletion based on retention policy.

### Can A2D2 process scanned documents?
Yes, A2D2 includes OCR (Optical Character Recognition) to extract text from scanned documents and images.

### How accurate is OCR?
Typically >95% for clear scans. Accuracy depends on scan quality, language, and document structure.

### Can I process documents in bulk?
Yes, use Bulk Upload feature to upload multiple documents at once.

### How do I search within documents?
Use the search bar at the top. A2D2 indexes full document content for searching.

## Processes & Automation

### What is a process?
A process is an automated workflow that performs tasks without manual intervention using AI agents.

### How do I create a process?
1. Go to Automation → Create Process
2. Choose a template or build from scratch
3. Configure triggers and actions
4. Test and activate

### Can processes run automatically?
Yes, set triggers like:
- Schedule (daily, weekly, monthly)
- Document upload
- Email arrival
- API webhook
- Manual start

### What happens if a process fails?
You'll receive a notification. Check execution history for error details. Failed processes can be retried.

### Can I pause a process?
Yes, go to My Processes → Select process → Click Pause

### How many processes can I run simultaneously?
Depends on your subscription plan. Check Settings → Subscription.

## AI Agents

### What are AI Agents?
AI Agents are intelligent workers that analyze, transform, validate, and report on data automatically.

### How accurate are AI Agents?
Typically >95% accuracy for most tasks. Agents improve over time through machine learning and your feedback.

### Can I trust Agent decisions?
Agents are designed to assist, not replace human judgment. Review critical decisions and provide feedback to improve accuracy.

### How do I provide feedback to Agents?
After an Agent completes a task, click the Feedback button and rate the result (👍/👎) with optional comments.

### Which LLM models does A2D2 use?
A2D2 supports multiple models through a unified API:
- OpenAI: GPT-4, GPT-4 Turbo
- Anthropic: Claude 3
- DeepSeek: DeepSeek Chat
- Google: Gemini Pro
- xAI: Grok
- Mistral: Mistral Large

Administrators can configure which models to use for different tasks.

### Are my documents sent to external AI services?
Only if configured by your administrator. A2D2 can use local models or on-premise AI services for data privacy.

## Integrations

### What systems does A2D2 integrate with?
- ERP: SAP, 1C, Oracle
- CRM: Salesforce, Bitrix24, HubSpot
- Cloud Storage: Google Drive, OneDrive, Yandex.Disk
- Communication: Slack, Teams, Telegram
- Email: Gmail, Outlook, Yandex Mail

### How do I connect an integration?
1. Go to Settings → Integrations
2. Click Add Integration
3. Select service and authorize
4. Configure sync settings

### Can I create custom integrations?
Yes, use the REST API or GraphQL API. See [API Documentation](api-guide.md).

### Are integrations secure?
Yes, all integrations use OAuth 2.0 or API keys with encrypted storage. Data transmission is encrypted with TLS 1.3.

## Security & Privacy

### Is my data secure?
Yes, A2D2 implements:
- AES-256 encryption at rest
- TLS 1.3 encryption in transit
- Role-based access control
- Audit logging
- Regular security audits

### Where is my data stored?
Data location depends on your deployment. Contact your administrator for specifics.

### Is A2D2 compliant with regulations?
Yes:
- **Russia**: ФЗ-152 (Personal Data Law)
- **International**: GDPR-compliant architecture
- **Standards**: ГОСТ Р ИСО/МЭК 27001

### Can I export my data?
Yes, use Export features in Documents and Reports sections. Full data export available upon request.

### Who can see my documents?
Only users with explicit permissions. Admins can manage access controls.

## Billing & Subscription

### What payment methods are accepted?
- Bank cards (Visa, Mastercard, МИР)
- Bank transfer (for organizations)
- Cryptocurrency (Bitcoin, Ethereum, USDT)

### Can I pay in Rubles?
Yes, all pricing is available in RUB.

### How is usage calculated?
Based on:
- Number of active users
- Document processing volume
- AI Agent usage (API calls)
- Storage used

### Can I upgrade/downgrade my plan?
Yes, contact your administrator or sales team.

### Is there a free trial?
Yes, 14-day free trial available. Sign up at https://a2d2.example.com/trial

## Performance

### Why is processing slow?
Common causes:
- Large file size
- Complex documents
- High system load
- Network latency

Try uploading smaller files or contact support if issues persist.

### How do I improve performance?
- Use bulk operations for multiple files
- Schedule heavy processing during off-peak hours
- Optimize document quality (clear scans, proper formatting)
- Clear browser cache

### What are the system requirements?
**Minimum**:
- Modern browser (Chrome, Firefox, Safari, Edge)
- Internet connection: 5 Mbps
- Screen resolution: 1280x720

**Recommended**:
- Latest browser version
- Internet connection: 10+ Mbps
- Screen resolution: 1920x1080

## Troubleshooting

### "Session Expired" error
Re-login to the platform. Sessions expire after 30 minutes of inactivity for security.

### Upload fails
Check:
- File size (<100 MB)
- File format (supported types)
- Internet connection
- Available storage quota

### Process stuck in "Processing"
Wait a few minutes. If still stuck after 10 minutes, contact support with process ID.

### Can't find my document
- Check search filters
- Verify document was successfully uploaded
- Check Archive section
- Contact support if document is missing

### Agent returned incorrect results
Provide feedback (👎) with details. The agent will learn and improve.

## Support

### How do I get help?
- **In-app help**: Click ? icon
- **Email**: support@example.com
- **Phone**: +7 (XXX) XXX-XX-XX (9 AM - 6 PM MSK)
- **Live chat**: Available in application
- **GitHub**: https://github.com/unidel2035/a2d2/issues

### What information should I include in support requests?
- Your username/email
- Screenshot of error (if applicable)
- Steps to reproduce issue
- Browser and OS version
- Error message (if any)

### How quickly will I get a response?
- **Critical issues**: <2 hours
- **High priority**: <4 hours
- **Normal**: <24 hours
- **Low priority**: <48 hours

### Is training available?
Yes, check with your administrator for:
- Onboarding sessions
- Video tutorials
- User guides
- Webinars

## Updates & Roadmap

### How often is A2D2 updated?
- **Security patches**: As needed
- **Minor updates**: Monthly
- **Major releases**: Quarterly

### How do I know about new features?
- **Changelog**: Available in application
- **Email notifications**: Sent to administrators
- **Blog**: https://a2d2.example.com/blog

### Can I request features?
Yes! Submit feature requests:
- GitHub Discussions: https://github.com/unidel2035/a2d2/discussions
- Email: feedback@example.com
- In-app feedback button

---

**Can't find your question?**
- Search the [User Guide](user-guide.md)
- Contact [Support](#support)
- Visit [GitHub Discussions](https://github.com/unidel2035/a2d2/discussions)

**Document Version**: 1.0
**Last Updated**: 2025-10-28
