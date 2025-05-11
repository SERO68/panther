import 'package:flutter/material.dart';
import 'package:panther/connection/wifi.dart';
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
        if (message['type'] == 'message' && 
            message['content'].toString().contains('Login successful')) {
          // Navigate to home screen on successful login
          if (mounted) {
            // Add a small delay to ensure UI updates properly
            Future.delayed(const Duration(milliseconds: 300), () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Login successful! Connecting...')),
              );
              Navigator.pushReplacementNamed(context, '/home');
            });
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

  Future<void> _testConnection() async {
    setState(() {
      _isConnecting = true;
      _errorMessage = '';
    });

    try {
      await _socketService.connect(_ipController.text);

      if (mounted) {
        // Send name to server
        _socketService.sendMessage(_nameController.text);
        
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
  }

  Future<bool> _showPasswordDialog() async {
    _passwordController.clear(); // Clear previous password
    _passwordVisible = false; // Reset password visibility
    int passwordAttempts = 0;
    const int maxAttempts = 3;
    
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        bool isVerifying = false;
        String errorText = '';
        String serverResponseText = '';
        
        // Create a local subscription for password-related messages
        StreamSubscription? localSubscription;

        return StatefulBuilder(
          builder: (dialogContext, setState) {
            // Set up local listener for server responses during password verification
            if (localSubscription == null) {
              localSubscription = _socketService.messageStream.listen((message) {
                if (message['type'] == 'message') {
                  final content = message['content'] as String;
                  setState(() {
                    serverResponseText = content;
                    
                    if (content.contains('Invalid password')) {
                      passwordAttempts++;
                      errorText = 'Invalid password. Try again (${maxAttempts - passwordAttempts} attempts left)';
                      isVerifying = false;
                      
                      if (passwordAttempts >= maxAttempts) {
                        // Reset connection after 3 failed attempts
                        _socketService.disconnect();
                        // Close the dialog
                        localSubscription?.cancel();
                        Navigator.of(dialogContext).pop(false);
                      }
                    } else if (content.contains('Login successful')) {
                      // Password verification succeeded
                      // Close dialog and let the global listener handle navigation
                      localSubscription?.cancel();
                      Navigator.of(dialogContext).pop(true);
                    } else if (content.contains('Received')) {
                      // This is just an acknowledgment, not a final response
                      serverResponseText = 'Server received your input';
                    }
                  });
                }
              });
            }

            return AlertDialog(
              title: const Text('Security Verification'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Please enter the server password'),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: !_passwordVisible,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: const OutlineInputBorder(),
                      errorText: errorText.isNotEmpty ? errorText : null,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible ? Icons.visibility : Icons.visibility_off,
                          color: Theme.of(dialogContext).primaryColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                    ),
                    onSubmitted: (_) {
                      if (!isVerifying) {
                        setState(() {
                          isVerifying = true;
                          errorText = '';
                          serverResponseText = '';
                        });
                        _socketService.sendMessage(_passwordController.text);
                      }
                    },
                  ),
                  if (serverResponseText.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        serverResponseText,
                        style: TextStyle(
                          color: serverResponseText.contains('Invalid') 
                              ? Colors.red 
                              : Theme.of(dialogContext).primaryColor,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isVerifying
                      ? null 
                      : () {
                          localSubscription?.cancel();
                          Navigator.of(dialogContext).pop(false);
                        },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isVerifying
                      ? null
                      : () {
                          setState(() {
                            isVerifying = true;
                            errorText = '';
                            serverResponseText = '';
                          });
                          
                          // Send password to server
                          _socketService.sendMessage(_passwordController.text);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00ADDA),
                  ),
                  child: isVerifying
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Verify'),
                ),
              ],
            );
          },
        );
      },
    );

    return result ?? false;
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
    // Get current orientation
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isLandscape 
              ? _buildLandscapeLayout()
              : _buildPortraitLayout(),
        ),
      ),
    );
  }

  Widget _buildPortraitLayout() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          _buildLogo(),
          const SizedBox(height: 24),
          _buildTitle(),
          const SizedBox(height: 32),
          _buildIpField(),
          const SizedBox(height: 16),
          _buildNameField(),
          const SizedBox(height: 24),
          _buildConnectButton(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout() {
    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left side with logo
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLogo(),
                const SizedBox(height: 16),
                _buildTitle(),
              ],
            ),
          ),
          
          // Right side with form
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildIpField(),
                  const SizedBox(height: 16),
                  _buildNameField(),
                  const SizedBox(height: 24),
                  _buildConnectButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final radius = isLandscape ? screenWidth * 0.08 : screenWidth * 0.15;
    
    return CircleAvatar(
      backgroundColor: Colors.white,
      backgroundImage: const AssetImage("images/blacklogo.png"),
      radius: radius,
    );
  }

  Widget _buildTitle() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final fontSize = isLandscape ? screenWidth * 0.03 : screenWidth * 0.06;
    
    return Text(
      'Server Connection Setup',
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildIpField() {
    return TextField(
      controller: _ipController,
      decoration: InputDecoration(
        labelText: 'Server IP Address',
        hintText: 'Enter server IP (e.g., 192.168.1.10)',
        border: const OutlineInputBorder(),
        errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
      ),
    );
  }

  Widget _buildNameField() {
    return TextField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: 'Your Name',
        hintText: 'Enter your name',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildConnectButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isConnecting ? null : _testConnection,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00ADDA),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isConnecting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Connect',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }
}