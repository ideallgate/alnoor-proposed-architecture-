# C4 diagrams

Two versions are kept on purpose:

- **Structurizr (source of truth):** `workspace.dsl`, levels 1 to 3 from one model. Open it with Structurizr Lite or the Structurizr CLI, which can export PNG or SVG.
- **Mermaid (renders on GitHub):** `01-context.md`, `02-containers.md`, `03-api-components.md`, plus `l1-context.mmd` (a standalone level 1 sample).

When the two differ, the Structurizr model wins. Keep names the same in both.

Run Structurizr Lite in Docker from this folder:

    docker run -it --rm -p 8080:8080 -v "$PWD":/usr/local/structurizr structurizr/lite

then open http://localhost:8080.

To check the Structurizr model: `structurizr.sh validate -workspace workspace.dsl` (Structurizr CLI), or open it in Structurizr Lite.
