# PKT Budget Control

VinFast PKT — Kiểm soát Ngân sách & Chi tiêu. A single-file demo: budget
allocation by commitment item, expense tracking, and an early-warning badge
when a commitment item passes 80% of its yearly budget.

Everything lives in [`index.html`](index.html) — no build step. Data is kept
in the browser's `localStorage`; nothing is sent to a server, and each
browser/device holds its own data.

## Running locally

Open `index.html` directly in a browser, or serve the folder with any static
file server, e.g.:

```bash
npx serve .
```

## Publishing

GitHub Pages serves this repository from the `main` branch root — no
workflow or build step needed, since `index.html` is already the entry file.
