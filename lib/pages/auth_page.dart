import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/auth.dart';

enum AuthMode { Signup, Login }

class AuthPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Scrollbar(
          child: SingleChildScrollView(
            child: SafeArea(
              minimum: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 32,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'ShopApp',
                      style: Theme.of(context)
                          .textTheme
                          .headline4
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 32),
                    AuthForm(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AuthForm extends StatefulWidget {
  const AuthForm({
    Key key,
  }) : super(key: key);

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();

  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };

  bool _isLoading = false;
  final _passwordController = TextEditingController();

  AnimationController _animationController;
  Animation<double> _heightAnimation;
  Animation<double> _opacityAnimation;

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 250),
        reverseDuration: const Duration(milliseconds: 200));

    _heightAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0, 0.5, curve: Curves.easeInOut),
    );

    _opacityAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.5, 1),
    );

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();

    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) {
      return;
    }

    _formKey.currentState.save();

    setState(() {
      _isLoading = true;
    });

    try {
      if (_authMode == AuthMode.Login) {
        await Provider.of<Auth>(context, listen: false).login(
          email: _authData['email'],
          password: _authData['password'],
        );
      } else {
        await Provider.of<Auth>(context, listen: false).signUp(
          email: _authData['email'],
          password: _authData['password'],
        );
      }
    } on HttpException catch (error) {
      if (error.message.contains('EMAIL_EXISTS')) {
        _showErrorAlert(
          title: 'Email already used',
          content: 'The email address is already in use by another account',
        );
      } else if (error.message.contains('INVALID_EMAIL')) {
        _showErrorAlert(
          title: 'Invalid email',
          content: 'The email address is badly formatted',
        );
      } else if (error.message.contains('WEAK_PASSWORD')) {
        _showErrorAlert(
          title: 'Weak password',
          content: 'The password must be 6 characters long or more',
        );
      } else if (error.message.contains('EMAIL_NOT_FOUND')) {
        _showErrorAlert(
          title: 'Email not found',
          content:
              'There is no user record corresponding to this identifier. The user may have been deleted',
        );
      } else if (error.message.contains('INVALID_PASSWORD')) {
        _showErrorAlert(
          title: 'Invalid password',
          content:
              'The password is invalid or the user does not have a password',
        );
      } else if (error.message.contains('TOO_MANY_ATTEMPTS')) {
        _showErrorAlert(
          title: 'Too many attempts',
          content:
              'Too many unsuccessful login attempts. Please try again later',
        );
      } else if (error.message.contains('USER_DISABLED')) {
        _showErrorAlert(
          title: 'Disabled account',
          content: 'The user account has been disabled by an administrator',
        );
      } else {
        _showErrorAlert(
          title: 'Authentication failed',
          content: 'Authentication failed by an unknown error',
        );
      }
    } catch (error) {
      _showErrorAlert(
        content: 'Couldn\'t authenticate you. Please try again later',
      );
    } finally {
      //Navigator.of(context);
    }

    setState(() {
      _isLoading = false;
    });
  }

  _showErrorAlert({
    String title,
    @required String content,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title ?? 'Error'),
          content: Text(content),
          actions: [
            FlatButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
      _animationController.forward();
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextFormField(
            decoration: InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value.isEmpty || !value.contains('@')) {
                return 'Invalid email!';
              } else {
                return null;
              }
            },
            onSaved: (value) {
              _authData['email'] = value.trim();
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            decoration: InputDecoration(labelText: 'Password'),
            obscureText: true,
            controller: _passwordController,
            validator: (value) {
              if (value.isEmpty || value.length < 5) {
                return 'Password is too short';
              } else {
                return null;
              }
            },
            onSaved: (value) {
              _authData['password'] = value;
            },
          ),
          SizeTransition(
            sizeFactor: _heightAnimation,
            axis: Axis.vertical,
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: TextFormField(
                  enabled: _authMode == AuthMode.Signup,
                  decoration: InputDecoration(labelText: 'Confirm Password'),
                  obscureText: true,
                  validator: _authMode == AuthMode.Signup
                      ? (value) {
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          } else {
                            return null;
                          }
                        }
                      : null,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Flexible(
                        fit: FlexFit.tight,
                        child: RaisedButton(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 100),
                            switchInCurve: const Interval(0.5, 1),
                            switchOutCurve: const Interval(0.5, 1),
                            child: Text(
                              _authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP',
                              key: UniqueKey(),
                            ),
                          ),
                          onPressed: _submit,
                          textColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        fit: FlexFit.tight,
                        child: FlatButton(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 100),
                            switchInCurve: const Interval(0.5, 1),
                            switchOutCurve: const Interval(0.5, 1),
                            child: Text(
                              '${_authMode == AuthMode.Login ? 'SIGN UP' : 'LOGIN'} INSTEAD',
                              key: UniqueKey(),
                            ),
                          ),
                          onPressed: _switchAuthMode,
                          textColor: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
