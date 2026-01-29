#!/usr/bin/env python3
"""
Скрипт для создания тестовой трубы с QR-кодом через API
"""
import requests
import sys
import uuid

def create_test_pipe(api_url="http://localhost:8000", company="COMPANY", qr_code=None):
    """
    Создает тестовую трубу через API
    
    Args:
        api_url: URL API сервера
        company: Название компании
        qr_code: QR-код (если None, генерируется автоматически)
    """
    # Генерация QR-кода если не указан
    if qr_code is None:
        pipe_uuid = str(uuid.uuid4())
        qr_code = f"PL-{company.upper()}-{pipe_uuid}"
    
    # Данные для создания трубы
    pipe_data = {
        "company": company,
        "qr_code": qr_code,
        "manufacturer": "Test Manufacturer",
        "material": "Steel",
        "diameter_mm": 100,
        "wall_thickness_mm": 5.0,
        "length_meters": 100.0,
    }
    
    # API ключ для авторизации
    headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer dev-api-key-12345"
    }
    
    try:
        print(f"🔗 Подключение к API: {api_url}")
        print(f"📝 Создание трубы с QR-кодом: {qr_code}")
        print()
        
        # Создание трубы
        response = requests.post(
            f"{api_url}/api/v1/pipes",
            json=pipe_data,
            headers=headers,
            timeout=10
        )
        
        if response.status_code == 201:
            pipe = response.json()
            print("✅ Труба успешно создана!")
            print(f"   ID: {pipe.get('id')}")
            print(f"   QR-код: {pipe.get('qr_code')}")
            print(f"   Производитель: {pipe.get('manufacturer')}")
            print(f"   Материал: {pipe.get('material')}")
            print()
            print(f"📱 Теперь можно отсканировать QR-код в мобильном приложении:")
            print(f"   {qr_code}")
            return pipe
        else:
            print(f"❌ Ошибка создания трубы:")
            print(f"   Status: {response.status_code}")
            print(f"   Response: {response.text}")
            return None
            
    except requests.exceptions.ConnectionError:
        print(f"❌ Не удалось подключиться к серверу: {api_url}")
        print()
        print("💡 Убедитесь, что:")
        print("   1. Backend сервер запущен (make up или docker-compose up)")
        print("   2. Сервер доступен по адресу:", api_url)
        print("   3. Порт 8000 открыт")
        return None
    except Exception as e:
        print(f"❌ Ошибка: {e}")
        return None

if __name__ == "__main__":
    import argparse
    
    parser = argparse.ArgumentParser(description="Создать тестовую трубу с QR-кодом")
    parser.add_argument("--api-url", default="http://localhost:8000", help="URL API сервера")
    parser.add_argument("--company", default="COMPANY", help="Название компании")
    parser.add_argument("--qr-code", default=None, help="QR-код (если не указан, генерируется автоматически)")
    
    args = parser.parse_args()
    
    print("🔲 Создание тестовой трубы")
    print("=" * 50)
    create_test_pipe(args.api_url, args.company, args.qr_code)
