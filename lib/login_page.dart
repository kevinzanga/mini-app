import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'formulario_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool isLogin = true;
  bool _loading = false;
  bool _obscurePassword = true;

  final Color primaryColor = const Color(0xFF5B49F7);
  final Color secondaryColor = const Color(0xFF5CD1FF);

  void _autenticarUsuario() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() => _loading = true);

    try {
      if (isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const FormularioPage()),
      );
    } on FirebaseAuthException catch (e) {
      _mostrarDialogo('Error', e.message ?? 'Error desconocido');
    } catch (e) {
      _mostrarDialogo('Error', e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _mostrarDialogo(String titulo, String mensaje) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(titulo),
        content: Text(mensaje),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Parte superior con gradiente y logo
          Container(
            height: MediaQuery.of(context).size.height * 0.35,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
              gradient: LinearGradient(
                colors: [primaryColor, secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.flutter_dash, size: 80, color: Colors.white),
                  const SizedBox(height: 10),
                  const Text(
                    "STORE MOF",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                child: Card(
                  elevation: 10,
                  // ignore: deprecated_member_use
                  shadowColor: primaryColor.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 30),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isLogin ? 'Iniciar Sesión' : 'Registrarse',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 25),
                          TextFormField(
                            controller: _emailController,
                            enabled: !_loading,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Correo electrónico',
                              prefixIcon:
                                  Icon(Icons.email, color: primaryColor),
                              filled: true,
                              fillColor: Colors.grey[100],
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide(color: primaryColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide:
                                    BorderSide(color: Colors.deepPurpleAccent),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, ingresa tu correo';
                              }
                              final emailRegex =
                                  RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$');
                              if (!emailRegex.hasMatch(value)) {
                                return 'Correo inválido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _passwordController,
                            enabled: !_loading,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              prefixIcon: Icon(Icons.lock, color: primaryColor),
                              filled: true,
                              fillColor: Colors.grey[100],
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide(color: primaryColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide:
                                    BorderSide(color: Colors.deepPurpleAccent),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: primaryColor,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, ingresa tu contraseña';
                              }
                              if (value.length < 6) {
                                return 'Mínimo 6 caracteres';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),
                          const SizedBox(height: 20),
                          _loading
                              ? const CircularProgressIndicator(
                                  color: Color(0xFF5B49F7),
                                )
                              : SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: primaryColor),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 15),
                                    ),
                                    onPressed: _autenticarUsuario,
                                    child: Text(
                                      isLogin
                                          ? 'Iniciar sesión'
                                          : 'Registrarse',
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isLogin
                                    ? '¿No tienes cuenta? '
                                    : '¿Ya tienes cuenta? ',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                              TextButton(
                                onPressed: _loading
                                    ? null
                                    : () {
                                        setState(() => isLogin = !isLogin);
                                      },
                                child: Text(
                                  isLogin ? 'Regístrate' : 'Inicia sesión',
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
