---
title: HOP와 rhwp-desktop 데스크톱앱 비교분석
created: 2026-04-25 11:50

session_id: codex:019db8c4-06aa-7753-8685-c6f31cfa3b4f
session_path: C:/Users/ahnbu/.codex/sessions/2026/04/23/rollout-2026-04-23T14-15-47-019db8c4-06aa-7753-8685-c6f31cfa3b4f.jsonl


ai: codex
---

# HOP와 rhwp-desktop 데스크톱앱 비교분석

## 발단: 사용자 요청

사용자는 기존 데스크톱앱으로 보고 있던 `runableapp/rhwp-desktop`과 [HOP](https://golbin.github.io/hop/)를 비교해, 실사용 제품성과 향후 데스크톱앱 방향성 측면에서 어느 쪽이 더 참고 가치가 큰지 정리해 달라고 요청했다.

이번 문서의 비교 대상은 다음 두 프로젝트다.

- 기존 데스크톱앱: [runableapp/rhwp-desktop](https://github.com/runableapp/rhwp-desktop)
- 비교 대상: [golbin/hop](https://github.com/golbin/hop)

## 작업 상세내역

먼저 `rhwp-desktop`을 단순 기능표로만 보지 않고, "실사용 제품으로서 얼마나 완성도가 있는가"와 "내 프로젝트가 장기적으로 닮아야 할 구조인가"라는 두 축으로 다시 정리했다.

이후 HOP 쪽은 README, 개발 문서, Tauri 설정, 릴리스 워크플로우, `commands.rs`, `updates.rs`, 릴리스 자산을 확인했고, `rhwp-desktop` 쪽은 README, Electron `main.ts`/`preload.ts`, 패키지 설정, 릴리스 워크플로우, 릴리스 자산을 확인했다.

핵심 비교 포인트는 아래 다섯 가지였다.

- 설치와 실행이 얼마나 소비자 앱에 가까운가
- 저장, 내보내기, 업데이트처럼 실사용에 직접 닿는 데스크톱 기능이 있는가
- upstream `rhwp`와의 연결 방식이 장기 유지보수에 유리한가
- 파일 저장 경로가 단순 write 수준인지, staged save/상태 추적까지 다루는지
- 릴리스와 배포 체계가 제품 운영 수준으로 설계되어 있는가

## 의사결정 기록

### 1) 실사용 제품성 비교

| 사용자 기준 | `rhwp-desktop` | `HOP` | 판단 |
|---|---|---|---|
| 설치와 시작 | ⚠️ Windows `.exe`, macOS arm64 `.dmg`, Linux `AppImage` 1회 릴리스 | ✅ macOS arm64/x64 `.dmg`, Windows `.msi`/`.exe`, `latest.json` 배포 | `HOP` 우위 |
| 앱 크기 | ❌ Windows 설치 파일 약 `128MB` | ✅ Windows `.exe` 약 `24MB`, `.msi` 약 `26MB` | `HOP` 우위 |
| 일상 기능 | 열기/저장/외부 링크 열기 중심 | ✅ 열기, 저장, 다른 이름 저장, PDF 내보내기, 인쇄, drag & drop, 파일 연결, 여러 창 | `HOP` 우위 |
| 저장 안정성 | ⚠️ Save dialog 후 바이트를 바로 쓰는 구조 | ✅ staged save 준비, 외부 수정 확인, 세션 revision 관리 | `HOP` 우위 |
| 업데이트 경험 | ❌ 앱 내 업데이트 흐름 확인되지 않음 | ✅ startup update check, 다운로드 진행률, 재시작 적용 경로 존재 | `HOP` 우위 |
| macOS 완성도 | ⚠️ arm64 `.dmg`만 확인됨 | ✅ arm64/x64 모두 제공, README에 signed/notarized 명시 | `HOP` 우위 |
| Linux 제공 일관성 | ✅ v1.0.0에 `AppImage` 자산 존재 | ⚠️ 워크플로우는 Linux `AppImage`/`.deb`/`.rpm` 지원, 최신 `v0.1.8` 자산에는 Linux 패키지가 보이지 않음 | `rhwp-desktop` 실자산 기준 우세 |

> 정렬 기준: 설치 후 실제로 문서를 열고 저장하고 다시 업데이트하는 흐름에 영향이 큰 항목부터 배치했다.

### 2) 구조와 유지보수 비교

| 구조 기준 | `rhwp-desktop` | `HOP` | 판단 |
|---|---|---|---|
| 앱 셸 | Electron | ✅ Tauri 2 | `HOP` 우위 |
| upstream 관계 | ❌ `core/pkg/`와 `ui/`를 버전 스냅샷으로 복사 | ✅ `third_party/rhwp` submodule + overlay 구조 | `HOP` 우위 |
| 제품 경계 | Electron 래퍼 중심 | ✅ `apps/desktop`와 `apps/studio-host`에 제품 레이어를 분리 | `HOP` 우위 |
| 파일 I/O 설계 | `ipcMain`에서 open/save dialog 후 직접 read/write | ✅ Rust 세션 관리 + staged save + 외부 변경 확인 | `HOP` 우위 |
| 릴리스 운영 | ❌ 단순 빌드·업로드 중심 | ✅ 플랫폼 선택, 서명/노타리제이션, updater 자산, `SHA256SUMS`까지 포함 | `HOP` 우위 |

> 정렬 기준: 내 프로젝트가 나중에 데스크톱앱으로 커질 때 재사용 가치가 큰 설계 항목을 먼저 두었다.

### 3) 성숙도 신호 비교

| 신호 | `rhwp-desktop` | `HOP` | 판단 |
|---|---|---|---|
| GitHub star/fork | `24` / `3` | ✅ `997` / `197` | `HOP` 우위 |
| 최근 코드 푸시 | `2026-04-17` | ✅ `2026-04-24` | `HOP` 우위 |
| 릴리스 횟수 | `v1.0.0` 1회 | ✅ `v0.1.0`~`v0.1.8` 8회 | `HOP` 우위 |
| 제품 운영 신호 | 래퍼 성격이 강함 | ✅ 데스크톱 제품으로 계속 다듬는 흐름이 명확 | `HOP` 우위 |

> 정렬 기준: 단기 데모가 아니라 지속적으로 운영할 프로젝트인지 판단하는 데 직접 도움이 되는 지표를 위에 뒀다.

- 결정: 향후 데스크톱앱 기준점은 `rhwp-desktop`보다 `HOP`에 두는 것이 맞다.
- 근거: `HOP`는 단순 포장본이 아니라 저장·업데이트·배포·OS 통합까지 포함한 제품 레이어를 갖췄고, upstream과의 경계도 더 건강하다.
- 트레이드오프: `HOP`도 아직 완성형은 아니다. HWPX 저장, autosave/recovery, Linux 배포 일관성은 아직 보강이 필요하다.

### 최종 권장안

| 선택지 | 추천도 | 판단 |
|---|---:|---|
| `rhwp-desktop`을 기준 아키텍처로 삼는다 | ❌ | 빠른 Electron 래퍼 참고용 이상으로는 한계가 크다 |
| `HOP`를 기준 아키텍처로 삼는다 | ✅✅✅ | 제품 경계, 저장 설계, 배포 체계가 더 성숙하다 |
| `rhwp-desktop` 요소를 부분 참고한다 | ✅ | 초기 Electron 프로토타입, 간단한 IPC 구조 정도는 참고 가능 |

> 정렬 기준: 내 프로젝트가 앞으로 어떤 구조를 닮아야 하는지에 대한 직접적인 의사결정 기준으로 배치했다.

## 검증계획과 실행결과

| 검증 항목 | 검증 방법 | 결과 | 비고 |
|-----------|-----------|------|------|
| 저장소 기본 메타데이터 | GitHub API로 star, fork, default branch, 최근 push 확인 | ✅ 완료 | `golbin/hop`, `runableapp/rhwp-desktop` 비교 |
| 릴리스 현황 | `gh release list`와 `gh release view --json assets` 확인 | ✅ 완료 | 자산 종류와 파일 크기 확인 |
| 사용자 기능 범위 | 두 저장소의 README 확인 | ✅ 완료 | 열기, 저장, PDF, 인쇄, 파일 연결 등 비교 |
| 앱 셸과 저장 구조 | `Cargo.toml`, `tauri.conf.json`, `main.ts`, `preload.ts`, `commands.rs`, `updates.rs` 확인 | ✅ 완료 | Tauri/Electron, staged save, updater 경로 비교 |
| 배포 성숙도 | GitHub Actions workflow 비교 | ✅ 완료 | 서명, 노타리제이션, updater manifest 여부 확인 |

## 리스크 및 미해결 이슈

- `HOP`는 구조적으로 더 낫지만 아직 beta 성격이 강하다. `docs/DEVELOPMENT.md` 기준으로 HWPX 저장, autosave/recovery, 외부 파일 변경 감지는 미완이다.
- `HOP` README는 Linux AppImage와 `.deb`/`.rpm` 패키지를 안내하지만, 최신 `v0.1.8` 릴리스 자산에서는 Linux 패키지가 확인되지 않았다. README와 실제 배포 자산 사이에 시점 차가 있을 수 있다.
- `rhwp-desktop`은 README에서 MIT 상속을 말하지만 `desktop/package.json`은 `ISC`로 표기되어 있어 메타데이터 정합성 점검이 필요하다.

## 다음 액션

- 내 프로젝트 데스크톱앱을 설계할 때는 `upstream submodule + thin overlay + native file service`를 기본 방향으로 잡는다.
- 저장 경로는 `HOP`처럼 staged save와 revision 검사를 우선 고려하고, 단순 Electron byte write 패턴은 프로토타입 범위로만 제한한다.
- Electron을 계속 검토하더라도 `rhwp-desktop`을 통째로 닮기보다 HOP 수준의 제품 경계와 릴리스 체계를 목표로 잡는다.

## 참고 자료

| 출처 | 용도 |
|------|------|
| [HOP 사이트](https://golbin.github.io/hop/) | 사용자-facing 제품 소개 확인 |
| [golbin/hop README](https://github.com/golbin/hop/blob/main/README.md) | 기능 범위, 다운로드 방식, macOS 서명 안내 확인 |
| [golbin/hop 개발 문서](https://github.com/golbin/hop/blob/main/docs/DEVELOPMENT.md) | upstream 경계, 미완 기능, 제품 레이어 설명 확인 |
| [golbin/hop Cargo.toml](https://github.com/golbin/hop/blob/main/apps/desktop/src-tauri/Cargo.toml) | Tauri 2, updater plugin, `third_party/rhwp` 연결 확인 |
| [golbin/hop tauri.conf.json](https://github.com/golbin/hop/blob/main/apps/desktop/src-tauri/tauri.conf.json) | file association, updater endpoint, 번들 정책 확인 |
| [golbin/hop commands.rs](https://github.com/golbin/hop/blob/main/apps/desktop/src-tauri/src/commands.rs) | staged save, external modification, PDF export, print 경로 확인 |
| [golbin/hop updates.rs](https://github.com/golbin/hop/blob/main/apps/desktop/src-tauri/src/updates.rs) | update check, download/apply 흐름 확인 |
| [golbin/hop workflow](https://github.com/golbin/hop/blob/main/.github/workflows/hop-desktop.yml) | 서명, 노타리제이션, updater manifest 포함 릴리스 체계 확인 |
| [runableapp/rhwp-desktop README](https://github.com/runableapp/rhwp-desktop/blob/main/README.md) | `rhwp 0.7.2` 스냅샷, Electron 포장 성격 확인 |
| [runableapp/rhwp-desktop package.json](https://github.com/runableapp/rhwp-desktop/blob/main/desktop/package.json) | Electron 기반, 릴리스 타깃, 라이선스 표기 확인 |
| [runableapp/rhwp-desktop main.ts](https://github.com/runableapp/rhwp-desktop/blob/main/desktop/src/main.ts) | open/save dialog와 단순 fs write 구조 확인 |
| [runableapp/rhwp-desktop preload.ts](https://github.com/runableapp/rhwp-desktop/blob/main/desktop/src/preload.ts) | renderer bridge 범위 확인 |
| [runableapp/rhwp-desktop workflow](https://github.com/runableapp/rhwp-desktop/blob/main/.github/workflows/release-desktop.yml) | 단순 패키징/업로드 수준의 릴리스 체계 확인 |

---

## 실행계획 원문

이번 작업에는 별도 plan 문서가 없었고, 세션 내부 `update_plan`만 사용했다. 아래는 당시 계획 원문이다.

1. 문서 저장 경로와 파일명이 확정된다
2. 비교분석 문서가 규칙에 맞게 저장된다
3. 문서가 세션 기준으로 검수되고 보완된다
4. 문서 변경이 커밋된다
