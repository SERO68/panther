import 'package:flutter/material.dart';
import 'package:panther/data/services/socket/socket_service.dart';
import 'dart:async';

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({super.key});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isConnecting = false;
  String _errorMessage = '';
  final SocketService _socketService = SocketService();
  bool _passwordVisible = false;
  StreamSubscription? _messageSubscription;
  
  // Track password attempts
  int _passwordAttempts = 0;
  bool _passwordDialogOpen = false;

  @override
  void initState() {
    super.initState();
    // Initialize global message listener
    _setupGlobalMessageListener();
  }

 void _setupGlobalMessageListener() {
  _messageSubscription = _socketService.messageStream.listen(
    (Map<String, dynamic> message) {
      print('Got message: $message');
      
      // Handle login success message at global level to ensure we don't miss it
      if (message['type'] == 'message') {
        String content = message['content'].toString();
        
        if (content.contains('Login successful')) {
          // Reset password attempts on successful login
          _passwordAttempts = 0;
          
          // Close dialog if open
          if (_passwordDialogOpen && mounted) {
            Navigator.of(context).pop();
            _passwordDialogOpen = false;
          }
          
          // Navigate to home screen on successful login
          if (mounted) {
            // Add a small delay to ensure UI updates properly
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Login successful! Connecting...')),
                );
                Navigator.pushReplacementNamed(context, '/home');
              }
            });
          }
        } else if (content.contains('Invalid password. Try again.')) {
          // Increment failed password attempts
          _passwordAttempts++;
          
          // Close current dialog if open
          if (_passwordDialogOpen && mounted) {
            Navigator.of(context).pop();
            _passwordDialogOpen = false;
          }
          
          if (_passwordAttempts < 3) {
            // Show password dialog again with error message after a short delay
            Future.delayed(const Duration(milliseconds: 100), () {
              if (mounted && !_passwordDialogOpen) {
                _showPasswordDialog(errorMessage: 'Invalid password. Try again.');
              }
            });
          } else {
            // Too many attempts
            setState(() {
              _isConnecting = false;
              _errorMessage = 'Too many failed attempts. Connection closed.';
            });
            _socketService.disconnect();
          }
        } else if (content.contains('Too many failed attempts. Connection closed.')) {
          // Close dialog if open
          if (_passwordDialogOpen && mounted) {
            Navigator.of(context).pop();
            _passwordDialogOpen = false;
          }
          
          setState(() {
            _isConnecting = false;
            _errorMessage = 'Too many failed attempts. Connection closed.';
          });
          _socketService.disconnect();
        }
      } else if (message.containsKey('type')) {
        if (message['type'] == 'connectionSuccess') {
          // Navigate to home screen on successful connection
          Navigator.pushReplacementNamed(context, '/home');
        } else if (message['type'] == 'connectionError') {
          setState(() {
            _isConnecting = false;
            _errorMessage = message['message'] ?? 'Connection failed';
          });
        } else if (message['type'] == 'passwordRequired') {
          // Reset password attempts when a new password dialog is shown
          _passwordAttempts = 0;
          // Show password dialog when prompted by server
          _showPasswordDialog();
        }
      }
    },
    onError: (error) {
      setState(() {
        _errorMessage = 'Error: $error';
        _isConnecting = false;
      });
    },
  );
}
  
  // Show a dialog to request password from user
  Future<bool> _showPasswordDialog({String? errorMessage}) async {

     // Reset password controller for new input
  _passwordController.clear();
  
  bool dialogClosed = false;
  _passwordDialogOpen = true;
  
  // Use a local variable for password visibility in dialog
  bool localPasswordVisible = false;
  
 
    
    await showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to close dialog
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
        builder: (BuildContext context, StateSetter setDialogState) {
          return AlertDialog(
            title: const Text('Password Required'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    errorMessage ?? 'Please enter your password to continue:',
                    style: TextStyle(
                      color: errorMessage != null ? Colors.red : null,
                      fontWeight: errorMessage != null ? FontWeight.bold : null,
                    ),
                  ),
                  if (errorMessage != null) 
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Attempts remaining: ${3 - _passwordAttempts}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: !localPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter password (test123)',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          localPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          // Use setDialogState instead of setState
                          setDialogState(() {
                            localPasswordVisible = !localPasswordVisible;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      errorText: errorMessage != null ? ' ' : null,
                      errorStyle: const TextStyle(height: 0),
                    ),
                    autofocus: true,
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        // Send password to server
                        _socketService.sendMessage(value);
                        // Close dialog
                        dialogClosed = true;
                        _passwordDialogOpen = false;
                        Navigator.of(dialogContext).pop();
                        // Log the password submission
                        print('Password submitted via Enter: $value');
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  // Disconnect and close dialog
                  _socketService.disconnect();
                  setState(() {
                    _isConnecting = false;
                    _errorMessage = 'Connection cancelled';
                  });
                  dialogClosed = false;
                  _passwordDialogOpen = false;
                  Navigator.of(dialogContext).pop();
                },
              ),
              TextButton(
                child: const Text('Submit'),
                onPressed: () {
                  final password = _passwordController.text;
                  if (password.isNotEmpty) {
                    // Send password to server
                    _socketService.sendMessage(password);
                    // Close dialog
                    dialogClosed = true;
                    _passwordDialogOpen = false;
                    Navigator.of(dialogContext).pop();
                    // Log the password submission
                    print('Password submitted: $password');
                  }
                },
              ),
            ],
          );
        },
      );
    },
  );
  
  _passwordDialogOpen = false;
  return dialogClosed;
      
    
    
  }

  Future<void> _testConnection() async {
    final ip = _ipController.text.trim();
    final name = _nameController.text.trim();

    if (ip.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter an IP address';
      });
      return;
    }

    if (name.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your name';
      });
      return;
    }
    
    setState(() {
      _isConnecting = true;
      _errorMessage = '';
    });

    try {
      await _socketService.connect(ip);

      if (mounted) {
        // Send name to server
        _socketService.sendMessage(name);
        
        // Wait for server to acknowledge name
        await Future.delayed(const Duration(milliseconds: 500));
        
        // After name is sent, show password dialog
        final bool dialogClosed = await _showPasswordDialog();
        
        // If dialog was dismissed but we're not already on home screen
        if (!dialogClosed && mounted) {
          _socketService.disconnect();
          setState(() {
            _errorMessage = 'Connection cancelled';
            _isConnecting = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Connection failed: $e';
        _isConnecting = false;
      });
    }
    
    // Set a timeout for connection attempt
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted && _isConnecting) {
        setState(() {
          _isConnecting = false;
          _errorMessage = 'Connection timed out';
        });
      }
    });
  }

  @override
  void dispose() {
    _ipController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _messageSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo or app name
               Image.asset("images/blacklogo.png",width: 50,height: 150,),             
               const SizedBox(height: 24),
                const Text(
                  'Connect to Your Device',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter the IP address and your credentials to connect',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),
                // IP Address field
                TextField(
                  controller: _ipController,
                  decoration: InputDecoration(
                    labelText: 'IP Address',
                    hintText: 'e.g. 192.168.1.100',
                    prefixIcon: const Icon(Icons.computer),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                // Name field
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Your Name',
                    hintText: 'Enter your name',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const SizedBox(height: 24),
                // Error message
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                // Connect button
                ElevatedButton(
                  onPressed: _isConnecting ? null : _testConnection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: _isConnecting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Connect',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}