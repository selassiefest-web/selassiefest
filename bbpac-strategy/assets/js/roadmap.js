/* ==========================================================================
   roadmap.js — interactive layer for roadmap.html
   ==========================================================================
   Renders the Start-to-Yes Mermaid flowchart, then layers two things on top:
   1. Click-to-cycle status (not started / in progress / done) on every
      trackable step, persisted in localStorage — this is a status TRACKER,
      not just a picture.
   2. A "Quick links" panel below the diagram mapping each step to its
      tailored deck elsewhere in this system (or the matching phase in the
      public bbpac/organization/documents library), so the roadmap is a real
      entry point into the rest of the site rather than a dead end.

   TO ADD/EDIT A STEP: edit the NODES array below (id must match the node id
   used in DIAGRAM_SOURCE) and, if you change DIAGRAM_SOURCE's node ids,
   update NODES to match — they're intentionally kept in sync by hand since
   the diagram source has to stay human-readable Mermaid syntax.
   ========================================================================== */

(function () {
  var STORAGE_KEY = 'bbpac-roadmap-status-v1';
  var STATUS_ORDER = ['todo', 'in-progress', 'done'];
  var STATUS_LABEL = { todo: 'Not started', 'in-progress': 'In progress', done: 'Done' };

  var TRACK_TITLES = {
    A: 'Track A — CPD Administrative Path (Gate 0)',
    B: 'Track B — Community & Political Support',
    C: 'Track C — 501(c)(3) Formation',
    P: 'Phase 1 — Ordinary CPD Formation Process (unlocked once Gate 0 is won)',
    M: 'Milestones'
  };
  var TRACK_ORDER = ['A', 'B', 'C', 'P', 'M'];

  var NODES = [
    { id: 'A1', track: 'A', label: 'Intake with Park Supervisor / Area Manager + LCA', links: [{ label: 'LCA deck', href: 'departments/lca.html' }] },
    { id: 'A2', track: 'A', label: 'Planning & Development + Law determine classification mechanism & boundary', links: [{ label: 'Planning deck', href: 'departments/planning.html' }, { label: 'Law deck', href: 'departments/law.html' }] },
    { id: 'A3', track: 'A', label: 'Submit Formal Request for Written CPD Determination (6 questions)', links: [{ label: 'Gate 0 dossier (document library)', href: '../bbpac/organization/documents/phase-00-gate.html' }] },
    { id: 'A4', track: 'A', label: 'GATE 0 DECISION — Superintendent / Board rule on Outcome A, B, or C', links: [{ label: 'Superintendent deck', href: 'decision-makers/superintendent.html' }, { label: 'Board of Commissioners deck', href: 'decision-makers/board-of-commissioners.html' }] },
    { id: 'POLICY', track: 'A', label: 'Board policy-amendment process (only if Outcome C)', links: [{ label: 'Board of Commissioners deck', href: 'decision-makers/board-of-commissioners.html' }] },

    { id: 'B1', track: 'B', label: 'Build coalition: petition, organizational endorsements, founders roster', links: [{ label: 'Community deck', href: 'community/community-presentation.html' }] },
    { id: 'B2', track: 'B', label: 'Assemble evidence: Neglect Dossier, Representation Gap Analysis, FOIA records', links: [{ label: 'Evidence & Verification Status', href: 'evidence-status.html' }] },
    { id: 'B3', track: 'B', label: "Secure Alderman Yancy's sponsorship", links: [{ label: 'Alderman deck', href: 'decision-makers/alderman-yancy.html' }] },
    { id: 'B4', track: 'B', label: 'JPAC coordination: support or neutrality', links: [{ label: 'JPAC deck', href: 'partners/jpac.html' }] },

    { id: 'C1', track: 'C', label: 'Incorporate Illinois nonprofit corporation', links: [{ label: 'Formation documents', href: '../bbpac/organization/documents/phase-01-formation.html' }] },
    { id: 'C2', track: 'C', label: 'Draft & adopt bylaws (reused as PAC bylaws in Phase 1)', links: [{ label: 'Governance & Bylaws documents', href: '../bbpac/organization/documents/phase-02-governance-bylaws.html' }] },
    { id: 'C3', track: 'C', label: 'File IRS Form 1023 / 1023-EZ', links: [{ label: 'Finance documents', href: '../bbpac/organization/documents/phase-04-finance.html' }] },
    { id: 'C4', track: 'C', label: 'Interim fiscal sponsorship (Chicago Parks Foundation) while exemption is pending', links: [{ label: 'Chicago Parks Foundation deck', href: 'partners/chicago-parks-foundation.html' }, { label: 'Finance documents', href: '../bbpac/organization/documents/phase-04-finance.html' }] },
    { id: 'C5', track: 'C', label: 'IRS Determination Letter: 501(c)(3) status granted', links: [{ label: 'Finance documents', href: '../bbpac/organization/documents/phase-04-finance.html' }] },

    { id: 'P1', track: 'P', label: 'Meet with CPD', links: [{ label: 'Formation documents', href: '../bbpac/organization/documents/phase-01-formation.html' }] },
    { id: 'P2', track: 'P', label: 'Submit Letter of Intent', links: [{ label: 'Formation documents', href: '../bbpac/organization/documents/phase-01-formation.html' }] },
    { id: 'P3', track: 'P', label: 'Convene noticed community meeting', links: [{ label: 'Formation documents', href: '../bbpac/organization/documents/phase-01-formation.html' }] },
    { id: 'P4', track: 'P', label: 'Membership applications', links: [{ label: 'Formation documents', href: '../bbpac/organization/documents/phase-01-formation.html' }] },
    { id: 'P5', track: 'P', label: 'Nominate officers', links: [{ label: 'Formation documents', href: '../bbpac/organization/documents/phase-01-formation.html' }] },
    { id: 'P6', track: 'P', label: 'Elections with CPD representation', links: [{ label: 'Formation documents', href: '../bbpac/organization/documents/phase-01-formation.html' }] },
    { id: 'P7', track: 'P', label: 'Adopt bylaws', links: [{ label: 'Governance & Bylaws documents', href: '../bbpac/organization/documents/phase-02-governance-bylaws.html' }] },
    { id: 'P8', track: 'P', label: 'Submit New PAC Registration', links: [{ label: 'Formation documents', href: '../bbpac/organization/documents/phase-01-formation.html' }] },

    { id: 'CONVERGE', track: 'M', label: 'CONVERGENCE — CPD recognition + community readiness + nonprofit entity all in place', links: [] },
    { id: 'PHASE2', track: 'M', label: 'CPD recognition confirmed — BBPAC formally seated', links: [{ label: 'BBPAC public site', href: '../bbpac/index.html' }] },
    { id: 'PHASE3', track: 'M', label: 'OPERATE — PAC binder, annual compliance, independent fundraising', links: [{ label: 'Operational & Administrative Manuals', href: '../bbpac/organization/documents/phase-06-operations.html' }] }
  ];

  var DIAGRAM_SOURCE = '%%{init: {"theme":"base","themeVariables":{"primaryColor":"#ffffff","primaryTextColor":"#1b2733","primaryBorderColor":"#14304d","lineColor":"#4a5a68","fontFamily":"Helvetica Neue, Arial, sans-serif","fontSize":"15px"}}}%%\n' +
    'flowchart TD\n' +
    '    START(["<b>START</b><br/>Organize founding committee<br/>(mission, leadership roster)"]):::startEnd\n' +
    '    START --> A1\n' +
    '    START --> B1\n' +
    '    START --> C1\n' +
    '\n' +
    '    subgraph TRACKA[" TRACK A — CPD Administrative Path (Gate 0 · the critical path) "]\n' +
    '        direction TB\n' +
    '        A1["Intake with Park Supervisor /<br/>Area Manager + LCA"]:::trackA\n' +
    '        A2["Planning & Development + Law determine<br/>classification mechanism & boundary"]:::trackA\n' +
    '        A3["Submit Formal Request for Written<br/>CPD Determination (6 questions)"]:::trackA\n' +
    '        A4{{"GATE 0 DECISION<br/>Superintendent / Board rule on<br/>Outcome A, B, or C"}}:::gate\n' +
    '        A1 --> A2 --> A3 --> A4\n' +
    '    end\n' +
    '\n' +
    '    subgraph TRACKB[" TRACK B — Community & Political Support (parallel) "]\n' +
    '        direction TB\n' +
    '        B1["Build coalition: petition,<br/>organizational endorsements, founders roster"]:::trackB\n' +
    '        B2["Assemble evidence: Neglect Dossier,<br/>Representation Gap Analysis, FOIA records"]:::trackB\n' +
    '        B3["Secure Alderman Yancy\'s<br/>sponsorship"]:::trackB\n' +
    '        B4["JPAC coordination:<br/>support or neutrality"]:::trackB\n' +
    '        B1 --> B2 --> B3 --> B4\n' +
    '    end\n' +
    '\n' +
    '    subgraph TRACKC[" TRACK C — 501(c)(3) Formation (parallel · starts Day 1, independent of CPD) "]\n' +
    '        direction TB\n' +
    '        C1["Incorporate Illinois<br/>nonprofit corporation"]:::trackC\n' +
    '        C2["Draft & adopt bylaws<br/>(reused as PAC bylaws in Phase 1)"]:::trackC\n' +
    '        C3["File IRS Form 1023 / 1023-EZ"]:::trackC\n' +
    '        C4["Interim fiscal sponsorship<br/>(Chicago Parks Foundation)<br/>while exemption is pending"]:::trackC\n' +
    '        C5(["IRS Determination Letter:<br/>501(c)(3) status granted"]):::trackC\n' +
    '        C1 --> C2 --> C3 --> C5\n' +
    '        C2 -.-> C4\n' +
    '    end\n' +
    '\n' +
    '    B4 -.evidence feeds into.-> A3\n' +
    '    A2 -.mechanism informs boundary for.-> B2\n' +
    '\n' +
    '    A4 -->|"Outcome A or B: recognized"| CONVERGE\n' +
    '    A4 -->|"Outcome C: policy amendment needed"| POLICY["Board policy-amendment<br/>process"] --> A4\n' +
    '\n' +
    '    CONVERGE{{"CONVERGENCE<br/>CPD recognition secured +<br/>community readiness +<br/>nonprofit entity in place"}}:::gate\n' +
    '    B4 --> CONVERGE\n' +
    '    C2 -.bylaws ready.-> CONVERGE\n' +
    '\n' +
    '    CONVERGE --> P1\n' +
    '\n' +
    '    subgraph PHASE1[" PHASE 1 — FORM BBPAC (ordinary CPD process, now unlocked) "]\n' +
    '        direction TB\n' +
    '        P1["Meet with CPD"] --> P2["Submit Letter of Intent"] --> P3["Convene noticed<br/>community meeting"] --> P4["Membership applications"] --> P5["Nominate officers"] --> P6["Elections with<br/>CPD representation"] --> P7["Adopt bylaws"] --> P8["Submit New PAC<br/>Registration"]\n' +
    '    end\n' +
    '\n' +
    '    P8 --> PHASE2["<b>PHASE 2</b><br/>CPD recognition confirmed —<br/>BBPAC formally seated"]\n' +
    '    C5 -.501(c)(3) status, once granted, upgrades fundraising.-> PHASE3\n' +
    '    C4 -.covers fundraising until then.-> PHASE3\n' +
    '    PHASE2 --> PHASE3["<b>PHASE 3 — OPERATE</b><br/>PAC binder, annual CPD compliance,<br/>independent fundraising as a 501(c)(3)<br/>(or via fiscal sponsor until granted)"]\n' +
    '    PHASE3 --> END(["<b>YES</b><br/>New park/administrative unit +<br/>BBPAC formed & operating<br/>as / with a 501(c)(3)"]):::startEnd\n' +
    '\n' +
    '    classDef startEnd fill:#14304d,color:#ffffff,stroke:#0c1f33,stroke-width:2px,font-weight:bold;\n' +
    '    classDef trackA fill:#dce9f2,stroke:#14304d,color:#1b2733;\n' +
    '    classDef trackB fill:#e3f6ec,stroke:#1f7a4f,color:#1b2733;\n' +
    '    classDef trackC fill:#f7ecd8,stroke:#7a4a00,color:#1b2733;\n' +
    '    classDef gate fill:#f6e3e3,stroke:#7a1f1f,color:#1b2733,font-weight:bold;\n' +
    '    classDef done stroke:#1c6b3a,stroke-width:5px;\n' +
    '    classDef inprogress stroke:#8a5a00,stroke-width:5px,stroke-dasharray:6 3;\n' +
    '    style TRACKA fill:#f7fafc,stroke:#14304d,stroke-width:1px;\n' +
    '    style TRACKB fill:#f5fbf7,stroke:#1f7a4f,stroke-width:1px;\n' +
    '    style TRACKC fill:#fdf9f0,stroke:#7a4a00,stroke-width:1px;\n' +
    '    style PHASE1 fill:#f4efe4,stroke:#14304d,stroke-width:1.5px;\n' +
    '    style POLICY fill:#fbeece,stroke:#8a5a00,color:#1b2733;\n' +
    '    style PHASE2 fill:#e7f3ea,stroke:#1c6b3a,color:#1b2733;\n' +
    '    style PHASE3 fill:#e7f3ea,stroke:#1c6b3a,color:#1b2733;\n';

  // click bindings — one per trackable node, all pointing at the same global handler
  NODES.forEach(function (n) {
    DIAGRAM_SOURCE += '    click ' + n.id + ' handleNodeClick\n';
  });

  function loadState() {
    try {
      return JSON.parse(window.localStorage.getItem(STORAGE_KEY)) || {};
    } catch (e) {
      return {};
    }
  }

  function saveState(state) {
    try {
      window.localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
    } catch (e) { /* localStorage unavailable — status just won't persist */ }
  }

  var state = loadState();

  function cycle(status) {
    var idx = STATUS_ORDER.indexOf(status);
    return STATUS_ORDER[(idx + 1) % STATUS_ORDER.length];
  }

  function buildDiagramText() {
    var src = DIAGRAM_SOURCE;
    NODES.forEach(function (n) {
      var s = state[n.id];
      if (s === 'done' || s === 'in-progress') {
        src += '    class ' + n.id + ' ' + (s === 'done' ? 'done' : 'inprogress') + '\n';
      }
    });
    return src;
  }

  var renderCounter = 0;

  function renderDiagram() {
    var container = document.getElementById('roadmap-diagram-target');
    if (!container || !window.mermaid) return;
    renderCounter++;
    var renderId = 'roadmap-svg-' + renderCounter;
    window.mermaid.render(renderId, buildDiagramText()).then(function (result) {
      container.innerHTML = result.svg;
      if (typeof result.bindFunctions === 'function') {
        result.bindFunctions(container);
      }
    }).catch(function (err) {
      container.innerHTML = '<p style="color:#8a2f2f;">Diagram failed to render: ' + String(err && err.message ? err.message : err) + '</p>';
      // eslint-disable-next-line no-console
      console.error(err);
    });
  }

  function renderSummary() {
    var el = document.getElementById('roadmap-summary');
    if (!el) return;
    var counts = { todo: 0, 'in-progress': 0, done: 0 };
    NODES.forEach(function (n) { counts[state[n.id] || 'todo']++; });
    var total = NODES.length;
    var pct = Math.round((counts.done / total) * 100);
    el.innerHTML =
      '<div class="rm-summary-bar"><div class="rm-summary-fill" style="width:' + pct + '%;"></div></div>' +
      '<div class="rm-summary-text">' +
        '<span><b>' + counts.done + '</b> / ' + total + ' steps done (' + pct + '%)</span>' +
        '<span class="rm-dot rm-dot--inprogress"></span><span>' + counts['in-progress'] + ' in progress</span>' +
        '<span class="rm-dot rm-dot--todo"></span><span>' + counts.todo + ' not started</span>' +
        '<button type="button" class="rm-reset-btn" onclick="resetRoadmap()">Reset progress</button>' +
      '</div>';
  }

  function renderPanel() {
    var el = document.getElementById('roadmap-panel');
    if (!el) return;
    var html = '';
    TRACK_ORDER.forEach(function (track) {
      var items = NODES.filter(function (n) { return n.track === track; });
      if (!items.length) return;
      html += '<div class="track-group"><h3>' + TRACK_TITLES[track] + '</h3>';
      items.forEach(function (n) {
        var s = state[n.id] || 'todo';
        var links = n.links.map(function (l) {
          return '<a href="' + l.href + '">' + l.label + ' ↗</a>';
        }).join(' ');
        html +=
          '<div class="node-row">' +
            '<button type="button" class="status-btn status-btn--' + s + '" onclick="handleNodeClick(\'' + n.id + '\')" aria-label="' + n.id + ': ' + STATUS_LABEL[s] + '. Click to advance.">' + STATUS_LABEL[s] + '</button>' +
            '<span class="node-label">' + n.label + '</span>' +
            (links ? '<span class="node-links">' + links + '</span>' : '') +
          '</div>';
      });
      html += '</div>';
    });
    el.innerHTML = html;
  }

  function renderAll() {
    renderDiagram();
    renderSummary();
    renderPanel();
  }

  window.handleNodeClick = function (id) {
    state[id] = cycle(state[id] || 'todo');
    saveState(state);
    renderAll();
  };

  window.resetRoadmap = function () {
    if (!window.confirm('Reset all step statuses on this roadmap? This cannot be undone.')) return;
    state = {};
    saveState(state);
    renderAll();
  };

  document.addEventListener('DOMContentLoaded', function () {
    if (!window.mermaid) {
      var el = document.getElementById('roadmap-diagram-target');
      if (el) el.innerHTML = '<p style="color:#8a2f2f;">Diagram library failed to load from CDN — check network access.</p>';
      return;
    }
    window.mermaid.initialize({ startOnLoad: false, securityLevel: 'loose' });
    renderAll();
  });
})();
