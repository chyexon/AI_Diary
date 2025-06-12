# 💬 감정 분석 일기 앱 (Emotion Diary App)

AI 기반 감정 분석 일기 앱은 사용자의 일기를 분석하여 감정을 파악하고, 감정에 맞는 힐링 콘텐츠와 피드백을 제공하는 개인 맞춤형 감정 관리 앱입니다.

## 📌 프로젝트 개요

이 앱은 다음과 같은 기능을 제공합니다:

- AI 감정 분석: 사용자가 작성한 일기를 ChatGPT 기반 AI가 분석해 감정을 추출합니다.
- 맞춤형 조언 제공: 감정 분석 결과에 따라 개인화된 조언 또는 메시지를 제공합니다.
- 감정 변화 시각화: 일기를 바탕으로 감정 상태를 수치화하고, 기간별 그래프를 통해 시각화합니다.
- 힐링 콘텐츠 추천: 감정에 어울리는 음악과 명언 등 다양한 콘텐츠를 추천합니다.
- 일정 관리 기능: 감정 기록과 일정을 달력에서 함께 관리할 수 있습니다.

## 👥 팀원 구성

> **강다은**  
>  [@kkangdaeun](https://github.com/kkangdaeun)

> **김서원**  
>  [@ksw2003](https://github.com/ksw2003)

> **이다경**  
>  [@dakyung427](https://github.com/dakyung427)

> **장채현**  
>  [@chyexon](https://github.com/chyexon)


## 🖥 주요 UI 및 세부 기능

---

###  프로필 입력
- 이름, 생년월일, MBTI 유형을 입력하여 개인화된 환경을 제공합니다.  
- MBTI에 벗어나는 문자를 입력할 경우, 하단에 경고 문구가 표시됩니다.

---

###  달력 기반 감정 기록
- 달력 UI에서 일정을 직관적으로 확인할 수 있습니다.  
- 캘린더 화면 하단에는 사용자의 감정 탐색을 유도하는 **랜덤 질문**이 제공됩니다.

---

### ✍ 일기 작성 및 답변 제공
- 일기를 작성하면 **AI가 자동으로 응답**을 생성합니다.  
- 응답은 사용자의 **MBTI 성격 유형에 맞춰 감정에 공감하고 조언**을 제공합니다.  
- AI 답변과 함께 **추천 음악**도 제공되어 감정 회복에 도움을 줍니다.

---

###  감정 그래프
- 사용자의 감정 상태를 **시간 흐름에 따라 그래프로 시각화**합니다.  
- 원하는 기간을 설정해 감정의 변화 추이를 확인할 수 있습니다.

---

###  설정 기능
- **폰트 변경, 개인정보 변경** 등 사용자 환경을 최적화할 수 있는 설정 기능을 제공합니다.




## 🛠 사용 기술

###  Frontend  
<img src="./flutter.png" width="60"/> <img src="./dart.png" width="60"/>

###  AI Backend  
<img src="./chatgpt.png" width="60"/>

###  개발 환경  

<img src="./vscode.png" width="60"/>

## ⚙ 설치 및 실행 방법

```bash
# 프로젝트 클론
git clone https://github.com/your-username/emotion-diary-app.git
cd emotion-diary-app

# 패키지 설치
flutter pub get

# 에뮬레이터 또는 디바이스 실행
flutter run
```

## 📁 프로젝트 구조

```
flutter_application_1/
├── android/
├── build/
├── ios/
├── lib/
│   ├── main.dart
│   ├── screens/
│   │   ├── calendar_screen.dart
│   │   ├── diary_input_screen.dart
│   │   └── profile_screen.dart
│   ├── services/
│   │   ├── emotion_analysis.dart
│   │   └── gpt_api_service.dart
│   ├── widgets/
│   │   ├── custom_button.dart
│   │   ├── diary_tile.dart
│   │   └── emotion_chart.dart
├── test/
│   └── widget_test.dart
├── .gitignore
├── .metadata
├── analysis_options.yaml
├── google-services.json
├── pubspec.lock
├── pubspec.yaml
└── README.md
```
