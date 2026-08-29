(function () {
  "use strict";

  var root = document.querySelector("[data-codex-root]");
  if (!root) return;

  var DESIGN_W = 941;
  var stage = root.querySelector("[data-codex-id='stage']");
  var screens = Array.prototype.slice.call(root.querySelectorAll("[data-screen]"));
  var compareToggle = root.querySelector("#compare-toggle");
  var opacityRange = root.querySelector("#opacity-range");
  var compares = Array.prototype.slice.call(root.querySelectorAll(".compare"));

  function setScale() {
    if (!stage) return;
    var scale = stage.clientWidth / DESIGN_W;
    stage.style.setProperty("--phone-scale", String(scale));
  }

  function showTab(tabId) {
    screens.forEach(function (screen) {
      var active = screen.getAttribute("data-screen") === tabId;
      screen.hidden = !active;
      screen.classList.toggle("is-active", active);
    });
    updateCompare();
  }

  function updateCompare() {
    var on = compareToggle && compareToggle.checked;
    var opacity = opacityRange ? Number(opacityRange.value) / 100 : 0.4;

    screens.forEach(function (screen) {
      screen.classList.toggle("is-comparing", on && !screen.hidden);
    });

    compares.forEach(function (img) {
      var parentScreen = img.closest("[data-screen]");
      var visible = on && parentScreen && !parentScreen.hidden;
      img.classList.toggle("is-visible", visible);
      img.style.opacity = String(opacity);
      img.hidden = !visible;
    });
  }

  root.addEventListener("click", function (event) {
    var tabButton = event.target.closest("[data-tab]");
    if (!tabButton || !root.contains(tabButton)) return;
    var tabId = tabButton.getAttribute("data-tab");
    if (!tabId) return;
    showTab(tabId);
  });

  if (compareToggle) compareToggle.addEventListener("change", updateCompare);
  if (opacityRange) opacityRange.addEventListener("input", updateCompare);

  window.addEventListener("resize", setScale);
  window.addEventListener("load", setScale);
  requestAnimationFrame(setScale);
  showTab("home");
})();
