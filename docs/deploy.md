# HelpFlow — 배포 가이드

---

## 사전 준비

```bash
# Firebase CLI 설치
npm install -g firebase-tools

# Flutter SDK 확인
flutter --version  # 3.x 이상

# Firebase 로그인
firebase login
```

---

## 1. Firebase 보안 규칙 & 인덱스 배포

Firestore 보안 규칙과 인덱스를 변경했을 때 배포합니다.

```bash
cd helpflow

# 보안 규칙 + 인덱스 함께 배포
firebase deploy --only firestore

# 결과 확인
# ✓ firestore: released rules firestore.rules
# ✓ firestore: released indexes firestore.indexes.json
```

### 주요 파일
- `helpflow/firestore.rules` — 역할별 읽기/쓰기 권한
- `helpflow/firestore.indexes.json` — 복합 인덱스 (notifications, tickets)

---

## 2. Flutter 웹 빌드 & Firebase Hosting 배포

```bash
cd helpflow/helpflow

# 웹 빌드 (최적화)
flutter build web --release

# 빌드 결과물 위치
# helpflow/helpflow/build/web/

# Firebase Hosting 배포 (firebase.json 설정 필요)
cd ..
firebase deploy --only hosting
```

### firebase.json 설정 예시

```json
{
  "hosting": {
    "public": "helpflow/build/web",
    "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ]
  }
}
```

> go_router를 사용하므로 SPA 라우팅을 위해 모든 경로를 `index.html`로 rewrites 처리합니다.

---

## 3. Android APK 빌드

```bash
cd helpflow/helpflow

# 디버그 APK (테스트용)
flutter build apk --debug

# 릴리즈 APK (배포용)
flutter build apk --release

# 결과물 위치
# helpflow/helpflow/build/app/outputs/flutter-apk/app-release.apk
```

### 서명 설정 (릴리즈 배포 시)

```bash
# 키스토어 생성 (최초 1회)
keytool -genkey -v -keystore upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload

# android/key.properties 파일 생성
storePassword=<비밀번호>
keyPassword=<비밀번호>
keyAlias=upload
storeFile=<키스토어 경로>
```

> `upload-keystore.jks`와 `key.properties`는 `.gitignore`에 포함되어 있어 커밋하지 않습니다.

---

## 4. 전체 배포 순서

```
1. flutter analyze → 오류 0개 확인
2. flutter build web --release
3. firebase deploy --only firestore  (규칙/인덱스 변경 시)
4. firebase deploy --only hosting    (웹 앱 배포)
5. flutter build apk --release       (Android 배포 시)
```

---

## 5. 환경 설정 파일 (보안)

다음 파일은 `.gitignore`에 포함되어 **절대 커밋하지 않습니다**.

| 파일 | 역할 |
|------|------|
| `lib/firebase_options.dart` | Firebase 프로젝트 설정 |
| `android/app/google-services.json` | Android Firebase 연동 |
| `ios/Runner/GoogleService-Info.plist` | iOS Firebase 연동 |

새 환경에서 개발 시작할 때:

```bash
# FlutterFire CLI로 재생성
dart pub global activate flutterfire_cli
flutterfire configure --project=<firebase-project-id>
```

---

## 6. Firebase 프로젝트 확인

| 서비스 | 콘솔 경로 |
|--------|----------|
| Authentication | Firebase Console > Authentication > Users |
| Firestore | Firebase Console > Firestore Database |
| Storage | Firebase Console > Storage |
| Hosting | Firebase Console > Hosting |
