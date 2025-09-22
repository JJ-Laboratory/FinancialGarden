<img width="1000" alt="마스터03브로셔표지" src="https://github.com/user-attachments/assets/56a9eee3-5673-44dc-b53a-2e0775f15642" />

<img width="1000"  alt="Group_1321316271" src="https://github.com/user-attachments/assets/d3e22e94-1124-4a12-8360-648f16ec9c4c" />


# 🌱 Fig - Financial Garden

사용자의 소비·지출을 기록·분석하고, 챌린지를 통해 지속적인 금융 습관 개선을 돕는 개인 재무 관리 앱

<br/>

## 🗓️ 프로젝트 기간
2025년 8월 14일 ~ 9월 (현재 진행 중)

<br/>

## 📱 주요 기능

- **직관적인 가계부 관리**
  - 거래일자, 금액, 카테고리, 결제 수단을 통한 간편 등록
  - 23개 기본 카테고리 지원
  - Core Data + iCloud 연동을 통한 안전한 저장 및 기기 간 동기화
  - AI 영수증 촬영을 통한 자동 거래 등록

- **챌린지 시스템**
  - 일주일/한달 단위 개인 맞춤형 소비 목표 설정
  - 카테고리별 지출 한도 챌린지 (무지출, +1만원, +5만원, +10만원)
  - 실시간 진행률 표시 및 성공/실패에 따른 보상 시스템

- **소비 분석 & 시각화**
  - 월별 수입/지출 추이 바차트 (y=0 축 기준 +수입, -지출)
  - 카테고리별 지출 비율 파이차트, 전월 대비 증감 표시
  - Gemini AI 기반 개인 맞춤 소비 MBTI 분석

- **씨앗 & 열매 시스템**
  - 거래 등록 시 씨앗 적립, 챌린지 성공 시 열매 수확
  - Level 0~6 단계별 식물 성장 이미지를 통한 시각적 피드백
  - 열매를 소모하여 AI 소비 MBTI 분석 이용 가능

<br/>

## 🏗️ 아키텍처

### MVVM-C (ReactorKit + Coordinator) 패턴

```
AppCoordinator
└── TabBarCoordinator (탭 기반 메인 화면)
    ├── HomeCoordinator → HomeViewController + HomeReactor
    ├── RecordCoordinator → RecordListViewController + RecordListReactor
    │   └── RecordFormViewController + RecordFormReactor
    ├── ChallengeCoordinator → ChallengeListViewController + ChallengeListReactor
    │   └── ChallengeFormViewController + ChallengeFormReactor
    └── ChartCoordinator → ChartViewController + ChartReactor
        └── AnalysisCoordinator → AnalysisViewController + AnalysisReactor
```

#### 주요 설계 원칙
- **ReactorKit**: 단방향 데이터 플로우 (Action → Mutation → State → View)
- **Coordinator Pattern**: 화면 전환과 의존성 주입 담당
- **ViewControllerFactory**: 의존성 주입을 통한 ViewController 생성 중앙화
- **Repository Pattern**: Core Data와 외부 API 추상화
- **UseCase Pattern**: 비즈니스 로직 중복 제거 및 재사용성 향상

#### 핵심 컴포넌트 역할

**App Layer**
- `AppCoordinator`: 앱 전체 네비게이션 관리
- `TabBarCoordinator`: 메인 탭 화면 관리
- `ViewControllerFactory`: 화면별 ViewController 생성 팩토리

**Data Layer**
- `CoreDataService`: Core Data 스택 관리
- `TransactionRepository`: 거래 데이터 CRUD
- `CategoryRepository`: 카테고리 데이터 관리
- `ChallengeRepository`: 챌린지 데이터 관리
- `GardenRepository`: 씨앗/열매 시스템 데이터 관리

**Domain Layer**
- `Transaction`: 거래 정보 엔티티
- `Category`: 카테고리 정보 엔티티
- `Challenge`: 챌린지 정보 엔티티
- `RecordUseCase`: 거래 관련 비즈니스 로직
- `ChallengeUseCase`: 챌린지 관련 비즈니스 로직

**Presentation Layer**
- `ViewControllers`: 화면 표시 및 사용자 입력 처리
- `Reactors`: 비즈니스 로직 및 상태 관리 (ReactorKit)
- `Custom Components`: FormView, ProgressView, PopupView 등

<br/>


## 📁 프로젝트 구조

```
FIG/
├── App/                          # 앱 설정 및 Coordinator
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   ├── Coordinator/              # 화면 전환 관리
│   └── Factory/                  # ViewController 팩토리
├── Data/                         # 데이터 레이어
│   ├── CoreData/                 # Core Data 관리
│   │   ├── CoreDataService.swift
│   │   ├── Extensions/           # Core Data Entity 확장
│   │   └── FIG.xcdatamodeld/
│   └── Repository/               # 데이터 소스 추상화
├── Domain/                       # 도메인 레이어
│   ├── Models/                   # 도메인 모델
│   ├── RepositoryInterface/      # Repository 프로토콜
│   └── UseCase/                  # 비즈니스 로직
├── Scene/                        # 프레젠테이션 레이어
│   ├── Home/                     # 홈 화면
│   ├── Record/                   # 가계부 관리
│   ├── Challenge/                # 챌린지 시스템
│   ├── Chart/                    # 소비 분석
│   └── Component/                # 공통 UI 컴포넌트
├── Utils/                        # 유틸리티
│   ├── AIMbtiParser.swift        # AI MBTI 분석
│   ├── AIReceiptParser.swift     # AI 영수증 인식
│   ├── ChartDataProcessor.swift  # 차트 데이터 가공
│   └── Extensions/               # Swift 확장
└── Resources/                    # 리소스 파일
    ├── Assets.xcassets
    └── defaultCategories.json
```

<br/>

## 🛠️ 기술 스택
- **Framework**: UIKit
- **Architecture**: MVVM-C (ReactorKit + Coordinator)
- **Reactive**: RxSwift/RxCocoa
- **Layout**: SnapKit, Then
- **Data**: Core Data + iCloud CloudKit
- **AI**: Gemini AI
- **UI Components**: Toast-Swift, UITextView-Placeholder
- **Dependency Management**: SPM

<br/>

## 🔧 핵심 기술적 의사결정

### 1. ReactorKit + MVVM-C 아키텍처
- **선택 이유**: View와 비즈니스 로직의 명확한 분리, 테스트 가능한 구조
- **Coordinator 패턴**: 화면 전환 로직 분리, 의존성 주입 관리

### 2. UseCase 패턴 도입
- **문제**: 홈 화면과 각 탭 간의 비즈니스 로직 중복
- **해결**: RecordUseCase, ChallengeUseCase 도입으로 로직 재사용성 향상

### 3. Core Data + iCloud 연동
- **선택 이유**: 로컬 저장의 안정성과 멀티 디바이스 동기화 제공
- **구현**: CloudKit 연동을 통한 자동 데이터 동기화

### 4. Dynamic Type 지원
- **구현**: iOS 17+ registerForTraitChanges API 활용
- **해결**: UIStackView axis 동적 변경을 통한 접근성 향상

<br/>

## 🏃 역할 분담
|      팀원      | 역할                                                       |
|---------------|------------------------------------------------------------|
|     양지영     | AI 세팅, AI 활용, CoreData+iCloud, Git 활용, UI/UX 개선, 가계부, 기획, 로고 및 아이콘 제작, 아키텍처 설계, 앱 배포, 영수증 인식, 카테고리, 프로젝트 초기 세팅, 홈 |
|     박주하     | AI 활용, Git 활용, UI/UX 개선, 기획, 디자인, 부스이미지 및 브로셔 제작, 소비 패턴 분석, 앱 배포, 차트, 챌린지 |


