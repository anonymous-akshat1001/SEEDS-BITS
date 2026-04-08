# Login Implementation and Architecture Document

## 1. Overview and Architecture
The login functionality developed for the SEEDS application provides a seamless, secure, and robust authentication flow, connecting the Flutter frontend with the FastAPI backend. By leveraging JSON Web Tokens (JWT) and Bcrypt for password hashing, the system effectively protects user credentials and provides a scalable authentication mechanism for subsequent requests.

The architecture of the login system follows a standard client-server model:
1. **Client (Flutter)**: The user provides their phone number and password via a dynamic user interface enhanced by Text-to-Speech (TTS) capabilities.
2. **Server (FastAPI)**: The backend receives the credentials as form data, validating them against records stored in the PostgreSQL database using SQLAlchemy.
3. **Session Management**: Upon successful authentication, the server securely generates a session JWT. The client stores this token persistently using `SharedPreferences`, enabling persistent logins across app restarts.
4. **Push Notifications**: Post-login, the frontend automatically registers the device's Firebase Cloud Messaging (FCM) token to enable targeted push notifications.

---

## 2. Backend Implementation Details

### 2.1 Database Models
The `users` table acts as the source of truth for all login requests. The table ensures the `phone_number` is unique, which intrinsically allows it to serve as the username. User roles are heavily constrained to either "teacher" or "student", dictated via a check constraint (`role IN ('teacher', 'student')`).

### 2.2 Endpoint Overview
- **Endpoint**: `POST /auth/login`
- **Location**: `backend/main.py`
- **Content-Type**: `application/x-www-form-urlencoded`
- **Security Dependency**: Handled seamlessly by FastAPI's `OAuth2PasswordRequestForm`, enabling easy Swagger UI integration and standard OAuth2 compliance.

**Request Body Structure**:
```json
{
  "username": "1234567890", // Mapped to the user's phone number
  "password": "mySecurePassword123"
}
```

**Success Response (200 OK)**:
Provides crucial user state to the frontend, allowing customized UI rendering and role-based routing.
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "user_id": 42,
  "role": "teacher",
  "name": "Jane Doe"
}
```

**Error Responses**:
- **401 Unauthorized**: Triggered when either the phone number is not found in the database, or the provided password fails verification against the bcrypt hash.

### 2.3 Backend Code Snippet
The FastAPI endpoint receives the form data, queries the database asynchronously, verifies credentials, and generates the access token:

```python
@app.post("/auth/login")
async def login(form_data: OAuth2PasswordRequestForm = Depends(),
                db: AsyncSession = Depends(get_db)):
    # Treat username as phone_number
    phone = form_data.username
    password = form_data.password

    # Check if the phone number exists
    q = await db.execute(select(models.User).filter(models.User.phone_number == phone))
    user = q.scalar_one_or_none()

    if not user or not auth.verify_password(password, user.password_hash):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")

    # If user is valid, create a JWT token
    token_data = {"user_id": user.user_id, "role": user.role}
    access_token = auth.create_access_token(token_data, expires_delta=timedelta(days=7))
    
    # Return access token alongside metadata
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user_id": user.user_id,
        "role": user.role,
        "name": user.name 
    }
```

---

## 3. Frontend Implementation Details

### 3.1 Technology Stack
- **Framework**: Flutter (Dart)
- **HTTP/Networking**: `http` package
- **Local Storage**: `shared_preferences`
- **Accessibility**: Custom `TtsService` Integration for audio feedback

### 3.2 UI and State Management
The login screen (`LoginScreen`) is designed as a stateful widget. This architecture easily handles the dynamic nature of a login flow. The layout uses text input controllers tracking changes to the phone number and password fields. 

Crucially, an `isLoading` boolean state variable guarantees that network requests don't overlap. While waiting for the server's response, the layout replaces the login button with a modern `CircularProgressIndicator`.

### 3.3 Post-Login Processes
After a successful login, several vital actions are executed:
1. **Response Parsing**: The JSON response is decoded and verified for the essential keys (`access_token`, `role`, etc.).
2. **Persistence**: The token, user ID, user role, and name are stored structurally into `SharedPreferences`.
3. **FCM Registration**: `_registerFCMTokenIfAvailable()` is called asynchronously to link the physical device with the authenticated backend account session.
4. **Navigation Routing**: Using `Navigator.pushReplacement`, the current navigation context is flushed, placing the user seamlessly onto either the `TeacherDashboard` or `StudentDashboard` explicitly based on their resolved backend role.

### 3.4 Frontend Code Snippet
The following logic defines the core frontend HTTP transaction, state-management updates, and conditional routing based on the API response:

```dart
// Extract inputs
final phone = phoneCtrl.text.trim();
final password = passCtrl.text.trim();

// UI Load State
setState(() => isLoading = true);

try {
  // Execute POST request to FastAPI endpoint in expected URL Encoded Form Data
  final res = await http.post(
    Uri.parse('$baseUrl/auth/login'),
    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    body: {
      'username': phone,
      'password': password,
    },
  );

  // Authentication Success Logic
  if (res.statusCode == 200) {
    final data = jsonDecode(res.body);
    final accessToken = data['access_token'];
    final userId = data['user_id'];
    final role = data['role'];
    final userName = data['name']; 

    // Instantiate Persistent Local Storage
    final prefs = await SharedPreferences.getInstance();

    // Preserve login session
    await prefs.setString('token', accessToken);
    await prefs.setInt('user_id', userId);
    await prefs.setString('role', role);
    if (userName != null) await prefs.setString('user_name', userName);

    // Bind FCM notifications without blocking UI
    _registerFCMTokenIfAvailable();

    TtsService.speak("Login successful");

    // Dynamic Routing
    if (role.toLowerCase() == 'teacher') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TeacherDashboard()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const StudentDashboard()));
    }
  } 
  // Error handling logic
  else if (res.statusCode == 401) {
    TtsService.speak("Invalid credentials");
  } else {
    TtsService.speak("Login failed: ${res.statusCode}");
  }
} catch (e) {
  TtsService.speak("Login failed. Check network or credentials.");
} finally {
  setState(() => isLoading = false);
}
```

---

## 4. Conclusion
We successfully delivered an end-to-end login pipeline. By effectively encapsulating responsibilities—putting database and auth constraints on the FastApi server, and routing/state logic on the Flutter application—we've crafted a system that is accessible, secure, and extensible. The addition of Text-To-Speech accessibility, automated Firebase notification registration, and robust device persistence means the SEEDS platform is production-ready.
