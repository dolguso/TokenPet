# TokenPet

TokenPet은 OpenAI API 사용량을 작은 메뉴바 펫으로 보여주는 macOS companion app입니다.

## 왜 만드는가

정확한 비용과 usage 확인은 OpenAI 공식 대시보드가 가장 좋습니다. TokenPet은 그보다 한 단계 위의 질문에 답하려고 합니다.

- 오늘 OpenAI를 많이 썼나?
- 이번 주 사용 흐름이 평소와 비교해 어떤가?
- 지금 신경 써야 할 정도인가?

즉, 브라우저 탭을 열기 전에 메뉴바에서 한눈에 usage 상태를 확인하는 도구입니다.

## MVP 범위

- 메뉴바 중심 앱, 메인 윈도우 없음
- clone 직후 바로 볼 수 있는 demo mode
- macOS Keychain 기반 API 키 저장
- 최근 usage snapshot 로컬 캐시
- 사용량을 펫 상태로 바꾸는 작은 mood engine
- 팝오버에서 표시할 최소 정보:
  - 오늘 사용량
  - 이번 주 사용량
  - 가장 많이 쓴 모델
  - 최근 7일 미니 차트

## 현재 저장소 상태

이 starter repo는 실제로 동작하는 macOS 메뉴바 셸과 demo data 흐름을 포함합니다.

- `DemoUsageProvider`는 바로 사용할 수 있습니다.
- `OpenAIUsageClient`는 live 경로를 분리해둔 상태이며, 최종 endpoint 계약이 정리되면 이어서 붙일 수 있습니다.

이렇게 해두면 오늘 바로 push 가능한 starter repo가 되면서도, 다음 단계에서 live OpenAI usage 연동을 깔끔하게 이어갈 수 있습니다.

## 프로젝트 구조

```text
Sources/TokenPet
├─ App/
├─ Models/
├─ Persistence/
├─ Services/
└─ UI/
```

## 로컬 실행

현재 이 맥은 전체 Xcode가 아니라 Command Line Tools 중심 환경이라, 우선 Swift Package 기반 starter로 구성했습니다.

```bash
cd TokenPet
swift run
```

나중에 전체 Xcode를 설치하면 패키지를 Xcode에서 열어 네이티브 macOS 앱처럼 계속 발전시킬 수 있습니다.

## 로드맵

### v1
- live OpenAI usage endpoint 연결
- launch-at-login 추가
- 펫 상태 애니메이션 개선

### v1.1
- 예산 threshold 경고
- OpenAI dashboard 바로가기 개선
- compact text mode 추가

### v2
- Anthropic API provider 추가
- multi-provider mood engine
- 더 자세한 history drill-down
