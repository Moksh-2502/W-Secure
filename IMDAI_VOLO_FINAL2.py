import torch
import torch.nn as nn
import torch.optim as optim
from torchvision import datasets, transforms
from timm import create_model
from torch.utils.data import DataLoader
import requests
import joblib
from geopy.distance import geodesic
import threading
import time

transform = transforms.Compose([
    transforms.Resize((224, 224)),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.5, 0.5, 0.5], std=[0.5, 0.5, 0.5])
])

train_dataset = datasets.ImageFolder(root='data/train', transform=transform)
val_dataset = datasets.ImageFolder(root='data/val', transform=transform)
train_loader = DataLoader(train_dataset, batch_size=32, shuffle=True)
val_loader = DataLoader(val_dataset, batch_size=32, shuffle=False)

class MultiTaskVOLO(nn.Module):
    def __init__(self, pretrained=True):
        super(MultiTaskVOLO, self).__init__()
        self.backbone = create_model('volo_d1', pretrained=pretrained, num_classes=0)
        self.gender_head = nn.Linear(self.backbone.num_features, 2)
        self.emotion_head = nn.Linear(self.backbone.num_features, 7)

    def forward(self, x):
        features = self.backbone(x)
        gender_out = self.gender_head(features)
        emotion_out = self.emotion_head(features)
        return gender_out, emotion_out

model = MultiTaskVOLO(pretrained=True).cuda()
gender_criterion = nn.CrossEntropyLoss()
emotion_criterion = nn.CrossEntropyLoss()
optimizer = optim.Adam(model.parameters(), lr=1e-4)

for epoch in range(10):
    model.train()
    for images, labels in train_loader:
        images = images.cuda()
        gender_labels = labels[:, 0].cuda()
        emotion_labels = labels[:, 1].cuda()
        gender_out, emotion_out = model(images)
        gender_loss = gender_criterion(gender_out, gender_labels)
        emotion_loss = emotion_criterion(emotion_out, emotion_labels)
        loss = gender_loss + emotion_loss
        optimizer.zero_grad()
        loss.backward()
        optimizer.step()

joblib.dump(model, 'volo_model.joblib')

registered_devices = {}

def register_device(device_id, fcm_token, location):
    registered_devices[device_id] = {"fcm_token": fcm_token, "location": location}

def devices_within_radius(alert_location, radius_km=1):
    nearby_devices = []
    for device_id, data in registered_devices.items():
        distance = geodesic(alert_location, data["location"]).km
        if distance <= radius_km:
            nearby_devices.append(data["fcm_token"])
    return nearby_devices

def send_alert(alert_location, radius_km=1):
    nearby_tokens = devices_within_radius(alert_location, radius_km)
    if not nearby_tokens:
        return
    fcm_server_key = "YOUR_FCM_SERVER_KEY"
    fcm_endpoint = "https://fcm.googleapis.com/fcm/send"
    alert_message = {
        "title": "Safety Alert",
        "body": "Potential threat detected nearby. Stay alert and safe!"
    }
    for token in nearby_tokens:
        payload = {
            "to": token,
            "notification": alert_message
        }
        headers = {
            "Authorization": f"key={fcm_server_key}",
            "Content-Type": "application/json"
        }
        requests.post(fcm_endpoint, json=payload, headers=headers)

def trigger_alarm(gender_pred, emotion_pred, alert_location):
    if gender_pred == 1 and emotion_pred == 4:
        send_alert(alert_location=alert_location, radius_km=1)

def monitor_suspicious_activity():
    while True:
        test_image = torch.randn(1, 3, 224, 224).cuda()
        model.eval()
        with torch.no_grad():
            gender_out, emotion_out = model(test_image)
            gender_pred = torch.argmax(gender_out, dim=1).item()
            emotion_pred = torch.argmax(emotion_out, dim=1).item()
            trigger_alarm(gender_pred, emotion_pred, alert_location=(28.7041, 77.1025))
        time.sleep(2)

background_thread = threading.Thread(target=monitor_suspicious_activity)
background_thread.start()
