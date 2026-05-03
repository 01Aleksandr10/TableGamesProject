import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nickname = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _nickname.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Регистрация')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _nickname,
                  decoration: const InputDecoration(labelText: 'Никнейм'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _email,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _password,
                  decoration: const InputDecoration(labelText: 'Пароль'),
                  obscureText: true,
                ),
                if (authState.error != null) ...[
                  const SizedBox(height: 12),
                  Text(authState.error!, style: const TextStyle(color: Colors.redAccent)),
                ],
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: authState.isLoading
                      ? null
                      : () async {
                          final ok = await ref.read(authProvider.notifier).register(
                                _nickname.text,
                                _email.text,
                                _password.text,
                              );
                          if (!mounted || !ok) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Аккаунт создан. Теперь можно войти.')),
                          );
                          Navigator.pop(context);
                        },
                  child: authState.isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Зарегистрироваться'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
