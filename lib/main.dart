import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Login App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login() async {
    final response = await http.post(
      Uri.parse('https://wallet-api-7m1z.onrender.com/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': _usernameController.text,
        'password': _passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      final token = json.decode(response.body)['token'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login successful. Token: $token')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserInfoPage(token: token),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('Login'),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterPage()),
                );
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _register() async {
    final response = await http.post(
      Uri.parse('https://wallet-api-7m1z.onrender.com/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': _usernameController.text,
        'password': _passwordController.text,
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration successful')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}

class UserInfoPage extends StatefulWidget {
  final String token;

  UserInfoPage({required this.token});

  @override
  _UserInfoPageState createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  String _userId = ''; // New variable to hold user ID
  String _username = '';
  String _firstName = '';
  String _lastName = '';
  final _newFirstNameController = TextEditingController();
  final _newLastNameController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
  final response = await http.get(
    Uri.parse('https://wallet-api-7m1z.onrender.com/user/information'),
    headers: {'Authorization': 'Bearer ${widget.token}'},
  );

  if (response.statusCode == 200) {
    final userInfo = json.decode(response.body);
    print(userInfo); // เพิ่มบรรทัดนี้เพื่อดู response ที่ได้รับ
    setState(() {
      _userId = userInfo['_id'] ?? ''; // ปรับให้ตรงกับ key ใน response ของ API
      _username = userInfo['username'];
      _firstName = userInfo['fname'] ?? '';
      _lastName = userInfo['lname'] ?? '';
      _newFirstNameController.text = _firstName;
      _newLastNameController.text = _lastName;
    });
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to fetch user information')),
    );
  }
}

  Future<void> _updateUserInfo() async {
    final response = await http.post(
      Uri.parse('https://wallet-api-7m1z.onrender.com/user/set/profile'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json'
      },
      body: json.encode({
        'fname': _newFirstNameController.text,
        'lname': _newLastNameController.text,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        _firstName = _newFirstNameController.text;
        _lastName = _newLastNameController.text;
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User information updated successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update user information')),
      );
    }
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
      if (_isEditing) {
        _newFirstNameController.text = _firstName;
        _newLastNameController.text = _lastName;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Information')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('User ID: $_userId', style: TextStyle(fontSize: 18)), // Display user ID
            Text('Username: $_username', style: TextStyle(fontSize: 18)),
            Text('First Name: $_firstName', style: TextStyle(fontSize: 18)),
            Text('Last Name: $_lastName', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _toggleEditing,
              child: Text(_isEditing ? 'Cancel' : 'Edit'),
            ),
            SizedBox(height: 10),
            if (_isEditing) ...[
              TextField(
                controller: _newFirstNameController,
                decoration: InputDecoration(labelText: 'New First Name'),
              ),
              TextField(
                controller: _newLastNameController,
                decoration: InputDecoration(labelText: 'New Last Name'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _updateUserInfo,
                child: Text('Update User Information'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}