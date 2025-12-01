import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter/foundation.dart';
import 'support_service.dart';

class WebSocketService {
  static io.Socket? _socket;
  static String? _currentUserId;
  
  // Callback для новых сообщений
  static Function(Map<String, dynamic>)? onNewMessage;
  
  // Подключение к чату
  static void connectToChat(String userId) {
    // Отключаемся от предыдущего чата если есть
    disconnect();
    
    _currentUserId = userId;
    
    // Получаем URL сервера из SupportService
    final serverUrl = SupportService.baseUrl;
    
    // Создаем соединение
    _socket = io.io(
      serverUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .build(),
    );
    
    // Обработка подключения
    _socket!.onConnect((_) {
      debugPrint('✅ WebSocket подключен к $serverUrl');
      
      // Присоединяемся к чату пользователя
      _socket!.emit('join_chat', {'user_id': userId});
    });
    
    // Обработка отключения
    _socket!.onDisconnect((_) {
      debugPrint('❌ WebSocket отключен');
    });
    
    // Обработка ошибок
    _socket!.onError((error) {
      debugPrint('❌ Ошибка WebSocket: $error');
    });
    
    // Обработка новых сообщений
    _socket!.on('new_message', (data) {
      debugPrint('📨 Новое сообщение через WebSocket: $data');
      if (onNewMessage != null && data is Map<String, dynamic>) {
        onNewMessage!(data);
      }
    });
    
    // Подтверждение подключения
    _socket!.on('joined', (data) {
      debugPrint('✅ Подключен к чату: $data');
    });
    
    // Подключение
    _socket!.connect();
  }
  
  // Отключение от чата
  static void disconnect() {
    if (_socket != null && _currentUserId != null) {
      _socket!.emit('leave_chat', {'user_id': _currentUserId});
      _socket!.disconnect();
      _socket = null;
      _currentUserId = null;
      debugPrint('🔌 WebSocket отключен');
    }
  }
  
  // Проверка подключения
  static bool get isConnected => _socket?.connected ?? false;
  
  // Получить текущий userId
  static String? get currentUserId => _currentUserId;
}

