# Project Rules

## Local Clone Identity

- 이 clone(`rhwp-my`)은 RHWP 개인 커스텀 실행 환경이다.
- 기본 작업 브랜치는 `local/task179-devel`로 유지한다. `main`은 upstream 동기화 전용이다.
- 로컬 전용 자산: `_docs/`, `mydocs/`, `RHWP_바로가기.lnk`, `tools/rhwp_launcher.*`
- RHWP를 로컬에서 실행하라는 요청이면 이 clone과 이 clone의 바로가기를 우선 기준으로 본다.

## rhwp-my vs rhwp-pr

- `rhwp-my`: 본진. 커스텀 실행, 로컬 문서, 개인 규칙 관리용.
- `rhwp-pr`: upstream PR 전용 worktree. 브랜치는 `pr/task{N}` 패턴으로 운용한다.
- upstream PR 작업은 이 clone에서 직접 하지 말고 `D:\vibe-coding\rhwp-pr` worktree에서 진행한다.

## Changelog

- 이 저장소는 upstream 소유 레포이므로 루트 `CHANGELOG.md`는 수정하지 않는다.
- 커스텀 변경 이력은 루트 `CHANGELOG.local.md`에 기록한다.

## PR / Build Rules

- PR에 포함하지 않는 로컬 전용 파일: `_docs/`, `mydocs/`, `RHWP_바로가기.lnk`, `tools/rhwp_launcher.*`, PWA/로고 자산, `CHANGELOG.md`, `CLAUDE.md`
- PR 전 빌드/검증은 `rhwp-pr` 기준으로 수행한다.
- 사용자에게 수동 실행 테스트를 요청하기 전에는, 사용자가 실제로 실행할 산출물을 최신 상태로 빌드해야 한다.
- `rhwp-my` 바로가기/런처 기준 테스트면 `rhwp-my`에서 WASM 빌드 후 `rhwp-studio` build를 완료한 뒤 요청한다.
- `rhwp-pr` 기준 PR 테스트면 `rhwp-pr`에서 같은 순서로 빌드한 뒤 요청한다.
- 테스트 요청 시 어떤 clone/worktree의 어떤 산출물을 빌드했는지와 빌드 성공 여부를 함께 보고한다.
- 순서:
  1. WSL Ubuntu에서 `D:\vibe-coding\rhwp-pr`의 WASM 빌드: `docker compose --env-file .env.docker run --rm wasm`
  2. Windows에서 `D:\vibe-coding\rhwp-pr\rhwp-studio`의 `npm run build`
  3. 관련 테스트 실행
  4. 사용자 수동 검증
- `rhwp-pr`에 `.env.docker`가 없으면 `.env.docker.example` 기준으로 먼저 맞춘다.

## Document Output

- 사용자가 생성·저장을 요청한 일반 문서는 기본적으로 루트 `_docs/`에 저장한다.
- 별도 저장 위치를 사용하려면 사용자가 명시적으로 경로를 지정해야 한다.
- 기존 `mydocs/`는 레거시 문서와 프로젝트 내부 분류 문서용으로 유지하되, 사용자 요청 문서의 기본 저장 위치로 새로 선택하지 않는다.

## Document Naming

- 사용자 요청 문서는 기본적으로 `YYYYMMDD_NN_한줄요약.md` 형식을 따른다.
- 같은 날짜에 같은 성격의 문서가 이미 있으면 NN을 증가시켜 충돌을 피한다.
