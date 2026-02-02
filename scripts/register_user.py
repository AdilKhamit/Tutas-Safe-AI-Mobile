#!/usr/bin/env python3
"""
Скрипт для регистрации пользователя через API
"""
import sys
import requests
import json
from typing import Optional

API_BASE_URL = "http://localhost:8000"


def register_user(email: str, password: str, full_name: Optional[str] = None) -> bool:
    """Регистрация нового пользователя"""
    url = f"{API_BASE_URL}/api/v1/auth/register"
    
    data = {
        "email": email,
        "password": password,
    }
    
    if full_name:
        data["full_name"] = full_name
    
    try:
        response = requests.post(url, json=data)
        
        if response.status_code == 201:
            user_data = response.json()
            print(f"✅ Пользователь успешно зарегистрирован!")
            print(f"   Email: {user_data.get('email')}")
            print(f"   ID: {user_data.get('id')}")
            print(f"   Имя: {user_data.get('full_name', 'Не указано')}")
            return True
        else:
            error_data = response.json()
            print(f"❌ Ошибка регистрации: {error_data.get('detail', 'Unknown error')}")
            return False
            
    except requests.exceptions.ConnectionError:
        print(f"❌ Не удалось подключиться к API: {API_BASE_URL}")
        print("   Убедитесь, что backend сервер запущен:")
        print("   cd backend && poetry run uvicorn app.main:app --reload")
        return False
    except Exception as e:
        print(f"❌ Ошибка: {e}")
        return False


def login_user(email: str, password: str) -> Optional[dict]:
    """Вход пользователя и получение токенов"""
    url = f"{API_BASE_URL}/api/v1/auth/login"
    
    data = {
        "email": email,
        "password": password,
    }
    
    try:
        response = requests.post(url, json=data)
        
        if response.status_code == 200:
            token_data = response.json()
            print(f"✅ Успешный вход!")
            print(f"   Access Token: {token_data.get('access_token', '')[:50]}...")
            return token_data
        else:
            error_data = response.json()
            print(f"❌ Ошибка входа: {error_data.get('detail', 'Unknown error')}")
            return None
            
    except requests.exceptions.ConnectionError:
        print(f"❌ Не удалось подключиться к API: {API_BASE_URL}")
        return None
    except Exception as e:
        print(f"❌ Ошибка: {e}")
        return None


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Использование:")
        print("  python scripts/register_user.py <email> <password> [full_name]")
        print("")
        print("Пример:")
        print("  python scripts/register_user.py test@tutas.ai test123456 'Test User'")
        sys.exit(1)
    
    email = sys.argv[1]
    password = sys.argv[2]
    full_name = sys.argv[3] if len(sys.argv) > 3 else None
    
    print(f"📝 Регистрация пользователя: {email}")
    print("=" * 50)
    
    # Регистрация
    if register_user(email, password, full_name):
        print("\n" + "=" * 50)
        print("🔐 Тестирование входа...")
        
        # Тестирование входа
        token_data = login_user(email, password)
        if token_data:
            print("\n✅ Все работает! Теперь можно использовать в мобильном приложении.")
        else:
            print("\n⚠️  Регистрация прошла успешно, но вход не удался.")
    else:
        sys.exit(1)
