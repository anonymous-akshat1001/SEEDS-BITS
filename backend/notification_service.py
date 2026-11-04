import httpx
import google.auth
from google.oauth2 import service_account
from google.auth.transport.requests import Request
from typing import List, Optional
import os
import logging

logger = logging.getLogger("seeds")

# Path to your Firebase service account key JSON file
SERVICE_ACCOUNT_FILE = (
    os.getenv("FIREBASE_SERVICE_ACCOUNT_KEY", "").strip()
    or "./seeds-bits-firebase.json"
)
SCOPES = ['https://www.googleapis.com/auth/firebase.messaging']

class FCMNotificationService:
    def __init__(self):
        self.project_id = None
        self.credentials = None
        self._load_credentials()
    
    def _load_credentials(self):
        """Load Firebase service account credentials"""
        try:
            if os.path.isfile(SERVICE_ACCOUNT_FILE):
                self.credentials = (
                    service_account.Credentials.from_service_account_file(
                        SERVICE_ACCOUNT_FILE,
                        scopes=SCOPES,
                    )
                )
                self.project_id = self.credentials.project_id
            else:
                self.credentials, self.project_id = google.auth.default(
                    scopes=SCOPES,
                )
            
            logger.info("fcm_ready", extra={"event_code": "fcm_ready"})
        except Exception as e:
            logger.error("fcm_credentials_failed", extra={"event_code": "fcm_credentials_failed", "error_type": type(e).__name__})
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
            logger.error("fcm_auth_failed", extra={"event_code": "fcm_auth_failed", "error_type": type(e).__name__})
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
                logger.error("fcm_unavailable", extra={"event_code": "fcm_unavailable"})
                return False
            
            # FCM v1 API endpoint
            url = f"https://fcm.googleapis.com/v1/projects/{self.project_id}/messages:send"
            
            # Construct message
            message = {
                "message": {
                    "token": token,
                    "notification": {
                        "title": "SEEDS update",
                        "body": "Open SEEDS to review your updates."
                    },
                    "android": {
                        "priority": priority,
                        "notification": {
                            "sound": "default",
                            "visibility": "PRIVATE",
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
                message["message"]["data"] = {
                    k: str(v) for k, v in data.items()
                    if k in {"type", "session_id", "quiz_id", "class_id", "subject_id"}
                }
            
            # Send request
            headers = {
                "Authorization": f"Bearer {access_token}",
                "Content-Type": "application/json"
            }
            
            async with httpx.AsyncClient() as client:
                response = await client.post(url, json=message, headers=headers)
                
                if response.status_code == 200:
                    logger.info("fcm_accepted", extra={"event_code": "fcm_accepted"})
                    return True
                else:
                    logger.error("fcm_rejected", extra={"event_code": "fcm_rejected", "status": response.status_code})
                    return False
                    
        except Exception as e:
            logger.error("fcm_send_failed", extra={"event_code": "fcm_send_failed", "error_type": type(e).__name__})
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
        teacher_name: str,
        class_name: str,
        subject_name: str,
    ) -> bool:
        """Send session invitation notification"""
        return await self.send_notification(
            token=token,
            title="Session Invitation",
            body=f"{teacher_name} invited you to {class_name} {subject_name}: '{session_title}'",
            data={
                "type": "session_invitation",
                "session_id": str(session_id),
                "session_title": session_title,
                "teacher_name": teacher_name,
                "class_name": class_name,
                "subject_name": subject_name,
            }
        )

# Global instance
fcm_service = FCMNotificationService()
