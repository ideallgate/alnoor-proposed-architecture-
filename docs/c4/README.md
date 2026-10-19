# C4 diagrams

- `workspace.dsl`: Structurizr model for levels 1 to 3 (source of truth). Open it with Structurizr Lite or the Structurizr CLI, which can export PNG or SVG.
- `l1-context.mmd`: the same level 1 diagram in Mermaid, kept for comparison. It renders directly on GitHub if pasted into a Markdown mermaid block.

Run Structurizr Lite in Docker:

    docker run -it --rm -p 8080:8080 -v "$PWD":/usr/local/structurizr structurizr/lite

then open http://localhost:8080.

Components marked "proposed" (mobile, public web) are not yet covered by an ADR.
