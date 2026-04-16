# Test Progress

Date: 2026-04-06

## Newly installed apps

1. `plantuml` (Start UML)
2. `r-base` (R)

## Test folder

- Container path: `/test`
- Workspace path: `D:\Crack\DockerFullApp\combined-image\test`

## App test results

1. `plantuml`
- Version check: pass (`plantuml_test.txt`)
- Output image generation: pass (`uml-sample.png`)
- Screenshot artifact: `plantuml.png`

2. `r-base`
- Version check: pass (`r-base_test.txt`)
- Script execution: pass (`1+1` output logged in `r-base_test.txt`)
- Screenshot artifact: `r-base.png`

## Regression check

- Playwright suite: pass (`3 passed`)
