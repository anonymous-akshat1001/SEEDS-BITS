import json
import httpx
from google.oauth2 import service_account
from google.auth.transport.requests import Request
from typing import List, Optional
import os

# Path to your Firebase service account key JSON file
SERVICE_ACCOUNT_FILE = os.getenv("FIREBASE_SERVICE_ACCOUNT_KEY", "./seeds-bits-firebase.json")
SCOPES = ['https://www.googleapis.com/auth/firebase.messaging']

class FCMNotificationService:
    def __init__(self):
        self.project_id = None
        self.credentials = None
        self._load_credentials()
    
    def _load_credentials(self):
        """Load Firebase service account credentials"""
        try:
            self.credentials = service_account.Credentials.from_service_account_file(
                SERVICE_ACCOUNT_FILE,
                scopes=SCOPES
            )
            
            # Extract project ID from service account file
            with open(SERVICE_ACCOUNT_FILE, 'r') as f:
                service_account_info = json.load(f)
                self.project_id = service_account_info.get('project_id')
            
            print(f"[FCM] Loaded credentials for project: {self.project_id}")
        except Exception as e:
            print(f"[FCM] Error loading credentials: {e}")
            self.credentials = None
    
    def _get_access_token(self) -> Optional[str]:
        """Get OAuth2 access token for FCM v1 API"""
        try:
            if not self.credentials:
                return None
            
            # Refresh the token
            self.credentials.refresh(Request())
            return self.credentials.token
        except Exception as e:
            print(f"[FCM] Error getting access token: {e}")
            return None
    
    async def send_notification(
        self,
        token: str,
        title: str,
        body: str,
        data: dict = None,
        priority: str = "high"
    ) -> bool:
        """
        Send push notification using FCM v1 API
        
        Args:
            token: Device FCM token
            title: Notification title
            body: Notification body
            data: Additional data payload
            priority: Message priority ('high' or 'normal')
        """
        try:
            access_token = self._get_access_token()
            if not access_token:
                print("[FCM] No access token available")
                return False
            
            # FCM v1 API endpoint
            url = f"https://fcm.googleapis.com/v1/projects/{self.project_id}/messages:send"
            
            # Construct message
            message = {
                "message": {
                    "token": token,
                    "notification": {
                        "title": title,
                        "body": body
                    },
                    "android": {
                        "priority": priority,
                        "notification": {
                            "sound": "default",
                            "click_action": "FLUTTER_NOTIFICATION_CLICK"
                        }
                    },
                    "apns": {
                        "headers": {
                            "apns-priority": "10" if priority == "high" else "5"
                        },
                        "payload": {
                            "aps": {
                                "sound": "default",
                                "badge": 1
                            }
                        }
                    },
                    "webpush": {
                        "notification": {
                            "icon": "/icons/Icon-192.png",
                            "badge": "/icons/Icon-192.png"
                        }
                    }
                }
            }
            
            # Add data payload if provided
            if data:
                message["message"]["data"] = {k: str(v) for k, v in data.items()}
            
            # Send request
            headers = {
                "Authorization": f"Bearer {access_token}",
                "Content-Type": "application/json"
            }
            
            async with httpx.AsyncClient() as client:
                response = await client.post(url, json=message, headers=headers)
                
                if response.status_code == 200:
                    print(f"[FCM] Notification sent successfully to {token[:20]}...")
                    return True
                else:
                    print(f"[FCM] Error sending notification: {response.status_code} - {response.text}")
                    return False
                    
        except Exception as e:
            print(f"[FCM] Exception sending notification: {e}")
            return False
    
    async def send_to_multiple(
        self,
        tokens: List[str],
        title: str,
        body: str,
        data: dict = None
    ) -> dict:
        """
        Send notification to multiple devices
        Returns: {"success": int, "failure": int}
        """
        results = {"success": 0, "failure": 0}
        
        for token in tokens:
            success = await self.send_notification(token, title, body, data)
            if success:
                results["success"] += 1
            else:
                results["failure"] += 1
        
        return results
    
    async def send_session_invitation(
        self,
        token: str,
        session_id: int,
        session_title: str,
        teacher_name: str
    ) -> bool:
        """Send session invitation notification"""
        return await self.send_notification(
            token=token,
            title="Session Invitation",
            body=f"{teacher_name} invited you to join '{session_title}'",
            data={
                "type": "session_invitation",
                "session_id": str(session_id),
                "session_title": session_title,
                "teacher_name": teacher_name
            }
        )

# Global instance
fcm_service = FCMNotificationService()