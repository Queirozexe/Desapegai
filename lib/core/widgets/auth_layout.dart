import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Moldura reutilizável das três telas de autenticação.
class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.showBrand = false,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final bool showBrand;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showBrand ? null : AppBar(title: const Text('desapegaí')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (showBrand) const _BrandHeader(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF233A2F),
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(subtitle, style: const TextStyle(color: AppColors.muted)),
                        const SizedBox(height: 24),
                        child,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 50, 24, 36),
      decoration: const BoxDecoration(
        color: AppColors.green,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: AppColors.gold,
                child: Icon(Icons.eco_outlined, color: Color(0xFF214D36)),
              ),
              const SizedBox(width: 12),
              Text(
                'desapegaí',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Doe o que você não usa mais e dê\numa nova vida para quem precisa.',
            style: TextStyle(color: Colors.white, height: 1.5),
          ),
        ],
      ),
    );
  }
}
