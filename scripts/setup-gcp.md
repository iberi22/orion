# GCP CLI Setup Instructions

## Install Google Cloud CLI

### Windows Installation
1. Download the Google Cloud CLI installer from: https://cloud.google.com/sdk/docs/install
2. Run the installer and follow the setup wizard
3. Restart your terminal/command prompt

### Alternative: Using Chocolatey (Windows)
```bash
choco install gcloudsdk
```

### Alternative: Using Scoop (Windows)
```bash
scoop bucket add extras
scoop install gcloud
```

## Authentication Setup

### 1. Authenticate with Service Account
```bash
# Set the service account key file
gcloud auth activate-service-account --key-file=aetheria-d1229-firebase-adminsdk-fbsvc-bbcc1b44e9.json

# Set the default project
gcloud config set project aetheria-d1229
```

### 2. Verify Authentication
```bash
# Check current authentication
gcloud auth list

# Check current project
gcloud config get-value project

# Test Firebase access
gcloud firestore databases list
```

## Firebase Integration

### 1. Deploy Firestore Rules and Indexes
```bash
# Deploy Firestore rules
firebase deploy --only firestore:rules

# Deploy Firestore indexes
firebase deploy --only firestore:indexes

# Deploy all Firebase features
firebase deploy
```

### 2. Enable Required APIs
```bash
# Enable Firestore API
gcloud services enable firestore.googleapis.com

# Enable Firebase AI API
gcloud services enable firebase.googleapis.com

# Enable Cloud Functions API (if using functions)
gcloud services enable cloudfunctions.googleapis.com
```

## Verification Commands

```bash
# Check project status
gcloud projects describe aetheria-d1229

# List Firebase apps
gcloud firebase apps list

# Check Firestore status
gcloud firestore databases describe --database="(default)"
```

## Environment Variables

Add to your `.env` file:
```
GOOGLE_APPLICATION_CREDENTIALS=aetheria-d1229-firebase-adminsdk-fbsvc-bbcc1b44e9.json
GCLOUD_PROJECT=aetheria-d1229
```

## Troubleshooting

### Common Issues:
1. **Permission Denied**: Ensure the service account has the necessary roles
2. **Project Not Found**: Verify the project ID is correct
3. **API Not Enabled**: Enable required APIs using the commands above

### Required IAM Roles for Service Account:
- Firebase Admin SDK Administrator Service Agent
- Cloud Datastore User
- Firebase Rules Admin
- Cloud Functions Developer (if using functions)
