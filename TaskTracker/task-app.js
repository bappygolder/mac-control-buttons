(function () {
  const data = window.MCCProjectData;
  const tracker = data.tracker;
  const storageKey = tracker.storageKey;

  const ACTIVE_LANES = [
    "newly-added-or-updated",
    "backlog",
    "processing-or-on-hold",
    "in-progress"
  ];
  const HIDDEN_LANES = ["completed", "archived"];
  const LANE_LABELS = {
    "newly-added-or-updated": "Newly Added or Updated",
    "backlog": "Backlog",
    "processing-or-on-hold": "Processing / On Hold",
    "in-progress": "In Progress",
    completed: "Completed",
    archived: "Archived"
  };
  const PRIORITY_TO_URGENCY = { P0: 5, P1: 4, P2: 3, P3: 2 };
  const PRIORITY_TO_VALUE = { P0: 25000, P1: 10000, P2: 5000, P3: 1000 };

  const elements = {
    heroSummary: document.getElementById("heroSummary"),
    reviewedOnPill: document.getElementById("reviewedOnPill"),
    maintainedByPill: document.getElementById("maintainedByPill"),
    seedVersionPill: document.getElementById("seedVersionPill"),
    searchInput: document.getElementById("searchInput"),
    filterSelect: document.getElementById("filterSelect"),
    workspaceTitle: document.getElementById("workspaceTitle"),
    cardsViewButton: document.getElementById("cardsViewButton"),
    boardViewButton: document.getElementById("boardViewButton"),
    cardsView: document.getElementById("cardsView"),
    boardView: document.getElementById("boardView"),
    boardColumns: document.getElementById("boardColumns"),
    openCreateButton: document.getElementById("openCreateButton"),
    toggleInfoButton: document.getElementById("toggleInfoButton"),
    infoDrawer: document.getElementById("infoDrawer"),
    storageStatus: document.getElementById("storageStatus"),
    statsGrid: document.getElementById("statsGrid"),
    exportJsonButton: document.getElementById("exportJsonButton"),
    exportMarkdownButton: document.getElementById("exportMarkdownButton"),
    resetButton: document.getElementById("resetButton"),
    seedNotice: document.getElementById("seedNotice"),
    filterSummary: document.getElementById("filterSummary"),
    hiddenListsWrap: document.getElementById("hiddenListsWrap"),
    hiddenListsToggle: document.getElementById("hiddenListsToggle"),
    hiddenListsCount: document.getElementById("hiddenListsCount"),
    hiddenLists: document.getElementById("hiddenLists"),
    completedCount: document.getElementById("completedCount"),
    archivedCount: document.getElementById("archivedCount"),
    completedList: document.getElementById("completedList"),
    archivedList: document.getElementById("archivedList"),
    taskModal: document.getElementById("taskModal"),
    modalTitle: document.getElementById("modalTitle"),
    closeModalButton: document.getElementById("closeModalButton"),
    taskForm: document.getElementById("taskForm"),
    taskTitle: document.getElementById("taskTitle"),
    taskLane: document.getElementById("taskLane"),
    taskUrgency: document.getElementById("taskUrgency"),
    taskValue: document.getElementById("taskValue"),
    taskArea: document.getElementById("taskArea"),
    taskSource: document.getElementById("taskSource"),
    taskNotes: document.getElementById("taskNotes"),
    submitButton: document.getElementById("submitButton"),
    cancelEditButton: document.getElementById("cancelEditButton")
  };

  const savedState = readState();
  let tasks = savedState.tasks;
  let editingId = null;
  let activeView = savedState.ui.view || "cards";
  let hiddenExpanded = Boolean(savedState.ui.hiddenExpanded);

  init();

  function init() {
    populateAreaSelect();
    populateLaneSelect();
    hydrateHeader();
    bindEvents();
    render();
  }

  function bindEvents() {
    elements.searchInput.addEventListener("input", render);
    elements.filterSelect.addEventListener("change", render);
    elements.cardsViewButton.addEventListener("click", function () {
      setView("cards");
    });
    elements.boardViewButton.addEventListener("click", function () {
      setView("board");
    });
    elements.openCreateButton.addEventListener("click", function () {
      openModal();
    });
    elements.toggleInfoButton.addEventListener("click", toggleInfoDrawer);
    elements.exportJsonButton.addEventListener("click", exportJson);
    elements.exportMarkdownButton.addEventListener("click", exportMarkdown);
    elements.resetButton.addEventListener("click", resetToSeed);
    elements.hiddenListsToggle.addEventListener("click", toggleHiddenLists);
    elements.closeModalButton.addEventListener("click", closeModal);
    elements.cancelEditButton.addEventListener("click", closeModal);
    elements.taskModal.addEventListener("click", function (event) {
      if (event.target === elements.taskModal) {
        closeModal();
      }
    });
    elements.taskForm.addEventListener("submit", handleSubmit);
  }

  function hydrateHeader() {
    elements.heroSummary.textContent = data.project.summary;
    elements.reviewedOnPill.textContent = "Reviewed " + data.project.reviewedOn;
    elements.maintainedByPill.textContent = "Seeded by " + data.project.maintainedBy;
    elements.seedVersionPill.textContent = "Seed " + tracker.seedVersion;
    elements.storageStatus.textContent =
      "Everything remains self-contained in repo seed data plus browser localStorage. No external database is required for this level.";

    if (savedState.seedVersion !== tracker.seedVersion) {
      elements.seedNotice.hidden = false;
      elements.seedNotice.textContent =
        "This browser still has local task state from an older seed version. Reset if you want the latest repo baseline.";
    }
  }

  function populateAreaSelect() {
    tracker.areas.forEach(function (area) {
      const option = document.createElement("option");
      option.value = area;
      option.textContent = area;
      elements.taskArea.appendChild(option);
    });
  }

  function populateLaneSelect() {
    ACTIVE_LANES.concat(HIDDEN_LANES).forEach(function (lane) {
      const option = document.createElement("option");
      option.value = lane;
      option.textContent = LANE_LABELS[lane];
      elements.taskLane.appendChild(option);
    });
  }

  function readState() {
    try {
      const raw = localStorage.getItem(storageKey);
      if (!raw) {
        return {
          seedVersion: tracker.seedVersion,
          tasks: tracker.tasks.map(normalizeTask),
          ui: { view: "cards", hiddenExpanded: false }
        };
      }

      const parsed = JSON.parse(raw);
      return {
        seedVersion: parsed.seedVersion || "unknown",
        tasks: Array.isArray(parsed.tasks) ? parsed.tasks.map(normalizeTask) : tracker.tasks.map(normalizeTask),
        ui: parsed.ui || { view: "cards", hiddenExpanded: false }
      };
    } catch (error) {
      return {
        seedVersion: tracker.seedVersion,
        tasks: tracker.tasks.map(normalizeTask),
        ui: { view: "cards", hiddenExpanded: false }
      };
    }
  }

  function writeState() {
    localStorage.setItem(
      storageKey,
      JSON.stringify({
        seedVersion: tracker.seedVersion,
        tasks: tasks,
        ui: {
          view: activeView,
          hiddenExpanded: hiddenExpanded
        },
        savedAt: new Date().toISOString()
      })
    );
  }

  function normalizeTask(task) {
    const priority = task.priority || urgencyToPriority(task.urgency || 3);
    const lane = normalizeLane(task);
    const urgency = clampNumber(task.urgency || PRIORITY_TO_URGENCY[priority] || 3, 1, 5);
    const value = Number.isFinite(Number(task.value))
      ? Number(task.value)
      : (PRIORITY_TO_VALUE[priority] || 0);

    return {
      id: task.id || createTaskId(),
      title: task.title || "Untitled Task",
      notes: task.notes || "",
      lane: lane,
      urgency: urgency,
      value: value,
      priority: priority,
      area: task.area || "project-system",
      source: task.source || "user-requested",
      recommendedBy: task.recommendedBy || "",
      references: Array.isArray(task.references) ? task.references : [],
      lastModified: task.lastModified || data.project.reviewedOn
    };
  }

  function normalizeLane(task) {
    if (task.lane && (ACTIVE_LANES.concat(HIDDEN_LANES)).indexOf(task.lane) >= 0) {
      return task.lane;
    }

    switch (task.status) {
      case "done":
        return "completed";
      case "in-progress":
        return "in-progress";
      case "blocked":
        return "processing-or-on-hold";
      default:
        return "backlog";
    }
  }

  function setView(view) {
    activeView = view;
    writeState();
    render();
  }

  function toggleInfoDrawer() {
    const nextHidden = !elements.infoDrawer.hidden;
    elements.infoDrawer.hidden = nextHidden;
    elements.toggleInfoButton.setAttribute("aria-expanded", String(!nextHidden));
  }

  function toggleHiddenLists() {
    hiddenExpanded = !hiddenExpanded;
    writeState();
    renderHiddenLists(currentFilteredTasks());
  }

  function openModal(task) {
    editingId = task ? task.id : null;
    elements.taskModal.hidden = false;
    elements.modalTitle.textContent = task ? "Edit Task" : "Add Task";
    elements.submitButton.textContent = task ? "Save Changes" : "Save Task";

    if (task) {
      elements.taskTitle.value = task.title;
      elements.taskLane.value = task.lane;
      elements.taskUrgency.value = String(task.urgency);
      elements.taskValue.value = String(task.value);
      elements.taskArea.value = task.area;
      elements.taskSource.value = task.source;
      elements.taskNotes.value = task.notes || "";
    } else {
      elements.taskForm.reset();
      elements.taskLane.value = "newly-added-or-updated";
      elements.taskUrgency.value = "3";
      elements.taskArea.value = "project-system";
      elements.taskSource.value = "user-requested";
      elements.taskValue.value = "";
    }
  }

  function closeModal() {
    elements.taskModal.hidden = true;
    editingId = null;
    elements.taskForm.reset();
  }

  function handleSubmit(event) {
    event.preventDefault();

    const title = elements.taskTitle.value.trim();
    if (!title) {
      return;
    }

    const urgency = clampNumber(elements.taskUrgency.value || 3, 1, 5);
    const priority = urgencyToPriority(urgency);
    const lane = elements.taskLane.value;
    const nowDate = formatDateISO(new Date());
    const nextTask = {
      id: editingId || createTaskId(),
      title: title,
      notes: elements.taskNotes.value.trim(),
      lane: lane,
      urgency: urgency,
      value: Number(elements.taskValue.value || 0),
      priority: priority,
      area: elements.taskArea.value,
      source: elements.taskSource.value,
      recommendedBy: elements.taskSource.value === "recommended" ? tracker.recommendedByLabel : "",
      references: editingId ? getExistingReferences(editingId) : [],
      lastModified: nowDate
    };

    if (editingId) {
      tasks = tasks.map(function (task) {
        return task.id === editingId ? nextTask : task;
      });
    } else {
      tasks.unshift(nextTask);
    }

    writeState();
    closeModal();
    render();
  }

  function getExistingReferences(taskId) {
    const existing = tasks.find(function (task) {
      return task.id === taskId;
    });
    return existing && Array.isArray(existing.references) ? existing.references : [];
  }

  function createTaskId() {
    return "LOCAL-" + String(Date.now());
  }

  function currentFilteredTasks() {
    const search = elements.searchInput.value.trim().toLowerCase();
    const filter = elements.filterSelect.value;

    return tasks.filter(function (task) {
      const matchesSearch =
        !search ||
        [task.title, task.notes, task.id, LANE_LABELS[task.lane]].join(" ").toLowerCase().includes(search);

      if (!matchesSearch) {
        return false;
      }

      switch (filter) {
        case "active":
          return ACTIVE_LANES.indexOf(task.lane) >= 0;
        case "hidden":
          return HIDDEN_LANES.indexOf(task.lane) >= 0;
        case "urgent":
          return task.urgency >= 4;
        case "recommended":
          return task.source === "recommended";
        case "requested":
          return task.source === "user-requested";
        default:
          return true;
      }
    });
  }

  function render() {
    const filteredTasks = currentFilteredTasks();
    renderStats();
    renderViewHeader(filteredTasks);
    renderCardsView(filteredTasks);
    renderBoardView(filteredTasks);
    renderHiddenLists(filteredTasks);
    syncViewMode();
  }

  function renderStats() {
    const counts = {
      total: tasks.length,
      active: tasks.filter(function (task) { return ACTIVE_LANES.indexOf(task.lane) >= 0; }).length,
      hidden: tasks.filter(function (task) { return HIDDEN_LANES.indexOf(task.lane) >= 0; }).length,
      urgent: tasks.filter(function (task) { return task.urgency >= 4; }).length
    };

    elements.statsGrid.innerHTML = "";
    [
      { label: "Total", value: counts.total },
      { label: "Active", value: counts.active },
      { label: "Hidden", value: counts.hidden },
      { label: "Urgent", value: counts.urgent }
    ].forEach(function (item) {
      const card = document.createElement("div");
      card.className = "mini-stat";
      card.innerHTML = "<strong>" + item.value + "</strong><span>" + item.label + "</span>";
      elements.statsGrid.appendChild(card);
    });
  }

  function renderViewHeader(filteredTasks) {
    elements.workspaceTitle.textContent = activeView === "cards" ? "Cards" : "Board";
    elements.filterSummary.textContent =
      filteredTasks.length + " shown · " + tasks.length + " total · " + (activeView === "cards" ? "simple card view" : "board view");
  }

  function syncViewMode() {
    const cardsActive = activeView === "cards";
    elements.cardsView.hidden = !cardsActive;
    elements.boardView.hidden = cardsActive;
    elements.cardsViewButton.classList.toggle("active", cardsActive);
    elements.boardViewButton.classList.toggle("active", !cardsActive);
  }

  function renderCardsView(filteredTasks) {
    elements.cardsView.innerHTML = "";
    const activeTasks = filteredTasks
      .filter(function (task) { return ACTIVE_LANES.indexOf(task.lane) >= 0; })
      .sort(sortTasks);

    if (!activeTasks.length) {
      elements.cardsView.innerHTML = '<div class="empty-state">No active tasks match the current filter.</div>';
      return;
    }

    const grid = document.createElement("div");
    grid.className = "task-grid";
    activeTasks.forEach(function (task) {
      grid.appendChild(buildTaskCard(task, true));
    });
    elements.cardsView.appendChild(grid);
  }

  function renderBoardView(filteredTasks) {
    elements.boardColumns.innerHTML = "";

    ACTIVE_LANES.forEach(function (lane) {
      const laneTasks = filteredTasks
        .filter(function (task) { return task.lane === lane; })
        .sort(sortTasks);

      const column = document.createElement("section");
      column.className = "board-column";

      const header = document.createElement("div");
      header.className = "board-column-header";
      header.innerHTML =
        '<div class="board-column-title">' + escapeHtml(LANE_LABELS[lane]) + '</div>' +
        '<div class="board-column-count">' + laneTasks.length + "</div>";

      const body = document.createElement("div");
      body.className = "board-column-body";

      if (!laneTasks.length) {
        body.innerHTML = '<div class="board-empty">No cards</div>';
      } else {
        laneTasks.forEach(function (task) {
          body.appendChild(buildTaskCard(task, false));
        });
      }

      column.appendChild(header);
      column.appendChild(body);
      elements.boardColumns.appendChild(column);
    });
  }

  function renderHiddenLists(filteredTasks) {
    const completedTasks = filteredTasks
      .filter(function (task) { return task.lane === "completed"; })
      .sort(sortTasks);
    const archivedTasks = filteredTasks
      .filter(function (task) { return task.lane === "archived"; })
      .sort(sortTasks);
    const hiddenTotal = completedTasks.length + archivedTasks.length;

    elements.hiddenListsWrap.hidden = hiddenTotal === 0;
    elements.hiddenListsCount.textContent = String(hiddenTotal);
    elements.completedCount.textContent = String(completedTasks.length);
    elements.archivedCount.textContent = String(archivedTasks.length);
    elements.hiddenLists.hidden = !hiddenExpanded;
    elements.hiddenListsToggle.setAttribute("aria-expanded", String(hiddenExpanded));

    elements.completedList.innerHTML = "";
    elements.archivedList.innerHTML = "";

    if (!completedTasks.length) {
      elements.completedList.innerHTML = '<div class="board-empty">No completed cards</div>';
    } else {
      completedTasks.forEach(function (task) {
        elements.completedList.appendChild(buildTaskCard(task, true));
      });
    }

    if (!archivedTasks.length) {
      elements.archivedList.innerHTML = '<div class="board-empty">No archived cards</div>';
    } else {
      archivedTasks.forEach(function (task) {
        elements.archivedList.appendChild(buildTaskCard(task, true));
      });
    }
  }

  function buildTaskCard(task, forGrid) {
    const card = document.createElement("article");
    card.className = "task-card" + (forGrid ? " task-card-grid" : " task-card-board");
    card.title = task.title + (task.notes ? " — " + task.notes : "");

    const top = document.createElement("div");
    top.className = "task-card-top";
    top.innerHTML =
      '<div class="task-card-lane">' + escapeHtml(LANE_LABELS[task.lane]) + "</div>" +
      '<div class="task-card-tools"></div>';

    const tools = top.querySelector(".task-card-tools");
    tools.appendChild(makeIconButton("Edit task", pencilIcon(), function () {
      openModal(task);
    }));
    tools.appendChild(makeIconButton("Delete task", trashIcon(), function () {
      deleteTask(task.id);
    }));

    const title = document.createElement("h3");
    title.className = "task-card-title";
    title.textContent = task.title;

    const notes = document.createElement("p");
    notes.className = "task-card-notes";
    notes.textContent = task.notes || "No notes yet.";

    const metrics = document.createElement("div");
    metrics.className = "task-card-metrics";
    metrics.innerHTML =
      '<span class="metric-chip">$' + formatCurrency(task.value) + "</span>" +
      '<span class="metric-chip">Urgency ' + task.urgency + "/5</span>";

    const meta = document.createElement("div");
    meta.className = "task-card-meta";
    meta.innerHTML =
      '<span class="mini-meta">' + escapeHtml(task.area) + "</span>" +
      '<span class="mini-meta">' + escapeHtml(humanizeSource(task.source)) + "</span>" +
      (task.recommendedBy ? '<span class="mini-meta accent-meta">AI recommended</span>' : "");

    const actions = document.createElement("div");
    actions.className = "task-card-actions";
    buildActionButtons(task).forEach(function (button) {
      actions.appendChild(button);
    });

    const modified = document.createElement("div");
    modified.className = "task-card-modified";
    modified.textContent = "Last modified: " + formatHumanDate(task.lastModified);

    card.appendChild(top);
    card.appendChild(title);
    card.appendChild(notes);
    card.appendChild(metrics);
    card.appendChild(meta);
    card.appendChild(actions);
    card.appendChild(modified);
    return card;
  }

  function buildActionButtons(task) {
    const buttons = [];

    if (task.lane === "completed") {
      buttons.push(makeActionButton("Reopen", "secondary", function () {
        moveTask(task.id, "backlog");
      }));
      buttons.push(makeActionButton("Archive", "ghost", function () {
        moveTask(task.id, "archived");
      }));
    } else if (task.lane === "archived") {
      buttons.push(makeActionButton("Restore", "secondary", function () {
        moveTask(task.id, "backlog");
      }));
    } else {
      buttons.push(makeActionButton("Done", "primary", function () {
        moveTask(task.id, "completed");
      }));
      buttons.push(makeActionButton("Archive", "ghost", function () {
        moveTask(task.id, "archived");
      }));
    }

    return buttons;
  }

  function makeActionButton(label, variant, handler) {
    const button = document.createElement("button");
    button.type = "button";
    button.className = variant === "primary" ? "primary task-action-button" : variant + " task-action-button";
    button.textContent = label;
    button.addEventListener("click", handler);
    return button;
  }

  function makeIconButton(label, iconMarkup, handler) {
    const button = document.createElement("button");
    button.className = "icon-button";
    button.type = "button";
    button.setAttribute("aria-label", label);
    button.innerHTML = iconMarkup;
    button.addEventListener("click", handler);
    return button;
  }

  function moveTask(taskId, nextLane) {
    tasks = tasks.map(function (task) {
      if (task.id !== taskId) {
        return task;
      }

      return Object.assign({}, task, {
        lane: nextLane,
        lastModified: formatDateISO(new Date())
      });
    });
    writeState();
    render();
  }

  function deleteTask(taskId) {
    const confirmed = window.confirm("Delete this task from the current browser state?");
    if (!confirmed) {
      return;
    }

    tasks = tasks.filter(function (task) {
      return task.id !== taskId;
    });
    writeState();
    render();
  }

  function sortTasks(a, b) {
    const laneOrderA = ACTIVE_LANES.concat(HIDDEN_LANES).indexOf(a.lane);
    const laneOrderB = ACTIVE_LANES.concat(HIDDEN_LANES).indexOf(b.lane);
    if (laneOrderA !== laneOrderB) {
      return laneOrderA - laneOrderB;
    }
    if (b.urgency !== a.urgency) {
      return b.urgency - a.urgency;
    }
    if (b.value !== a.value) {
      return b.value - a.value;
    }
    return String(b.lastModified).localeCompare(String(a.lastModified));
  }

  function exportJson() {
    downloadFile(
      "mac-control-center-task-tracker.json",
      JSON.stringify(
        {
          project: data.project,
          exportedAt: new Date().toISOString(),
          seedVersion: tracker.seedVersion,
          tasks: tasks
        },
        null,
        2
      ),
      "application/json"
    );
  }

  function exportMarkdown() {
    const lines = [
      "# Mac Control Center Task Tracker",
      "",
      "- Exported at: " + new Date().toISOString(),
      "- Seed version: " + tracker.seedVersion,
      "",
      "## Tasks",
      ""
    ];

    tasks.slice().sort(sortTasks).forEach(function (task) {
      lines.push(
        "- " +
          task.title +
          " | " +
          LANE_LABELS[task.lane] +
          " | $" +
          formatCurrency(task.value) +
          " | urgency " +
          task.urgency +
          " | last modified " +
          task.lastModified
      );
      if (task.notes) {
        lines.push("  Notes: " + task.notes);
      }
      lines.push("");
    });

    downloadFile(
      "mac-control-center-task-tracker.md",
      lines.join("\n"),
      "text/markdown"
    );
  }

  function resetToSeed() {
    const confirmed = window.confirm(
      "Reset this browser tracker back to the repo seed? Local-only edits will be removed."
    );
    if (!confirmed) {
      return;
    }

    tasks = tracker.tasks.map(normalizeTask);
    hiddenExpanded = false;
    writeState();
    elements.seedNotice.hidden = true;
    render();
  }

  function downloadFile(filename, contents, type) {
    const blob = new Blob([contents], { type: type });
    const url = URL.createObjectURL(blob);
    const anchor = document.createElement("a");
    anchor.href = url;
    anchor.download = filename;
    document.body.appendChild(anchor);
    anchor.click();
    anchor.remove();
    URL.revokeObjectURL(url);
  }

  function humanizeSource(source) {
    switch (source) {
      case "recommended":
        return "Recommended";
      case "local-note":
        return "Local";
      default:
        return "Requested";
    }
  }

  function urgencyToPriority(urgency) {
    if (urgency >= 5) return "P0";
    if (urgency >= 4) return "P1";
    if (urgency >= 3) return "P2";
    return "P3";
  }

  function clampNumber(value, min, max) {
    const number = Number(value);
    if (!Number.isFinite(number)) {
      return min;
    }
    return Math.max(min, Math.min(max, number));
  }

  function formatCurrency(value) {
    return Number(value || 0).toLocaleString("en-US", {
      minimumFractionDigits: 0,
      maximumFractionDigits: 0
    });
  }

  function formatDateISO(date) {
    return new Date(date).toISOString().slice(0, 10);
  }

  function formatHumanDate(raw) {
    const date = new Date(raw);
    if (Number.isNaN(date.getTime())) {
      return raw;
    }
    return date.toLocaleDateString("en-US", {
      year: "numeric",
      month: "short",
      day: "numeric"
    });
  }

  function escapeHtml(value) {
    return String(value)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#039;");
  }

  function pencilIcon() {
    return '<svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 20h9"/><path d="M16.5 3.5a2.1 2.1 0 0 1 3 3L7 19l-4 1 1-4Z"/></svg>';
  }

  function trashIcon() {
    return '<svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 6h18"/><path d="M8 6V4h8v2"/><path d="M19 6l-1 14H6L5 6"/></svg>';
  }
})();
