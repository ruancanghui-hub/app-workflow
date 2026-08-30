(function () {
  "use strict";

  var prototype = document.querySelector("[data-prototype]");
  if (!prototype) return;

  var screens = Array.prototype.slice.call(prototype.querySelectorAll("[data-screen]"));
  var tabs = Array.prototype.slice.call(prototype.querySelectorAll("[data-tab]"));
  var toast = prototype.querySelector(".toast");
  var toastTimer = 0;

  function showToast(label) {
    if (!toast) return;
    window.clearTimeout(toastTimer);
    toast.textContent = label + " 已触发";
    toast.hidden = false;
    toastTimer = window.setTimeout(function () {
      toast.hidden = true;
    }, 1200);
  }

  function setActive(tabName) {
    if (!prototype.querySelector("[data-screen='" + tabName + "']")) return;

    screens.forEach(function (screen) {
      var active = screen.getAttribute("data-screen") === tabName;
      screen.hidden = !active;
      screen.classList.toggle("is-active", active);
    });

    tabs.forEach(function (tab) {
      var active = tab.getAttribute("data-tab") === tabName;
      tab.classList.toggle("is-active", active);
      if (active) {
        tab.setAttribute("aria-current", "page");
      } else {
        tab.removeAttribute("aria-current");
      }
    });

    prototype.setAttribute("data-active", tabName);
    if (window.location.hash.slice(1) !== tabName) {
      window.history.replaceState(null, "", "#" + tabName);
    }
  }

  prototype.addEventListener("click", function (event) {
    var tab = event.target.closest("[data-tab]");
    if (tab) {
      setActive(tab.getAttribute("data-tab"));
      return;
    }

    var action = event.target.closest("[data-action]");
    if (action) {
      showToast(action.getAttribute("data-action"));
    }
  });

  prototype.addEventListener("keydown", function (event) {
    var order = ["home", "sleep", "meditation", "sound"];
    var current = prototype.getAttribute("data-active") || "home";
    var index = order.indexOf(current);

    if (event.key === "ArrowRight") {
      setActive(order[(index + 1) % order.length]);
    }

    if (event.key === "ArrowLeft") {
      setActive(order[(index + order.length - 1) % order.length]);
    }
  });

  window.addEventListener("hashchange", function () {
    setActive(window.location.hash.slice(1) || "home");
  });

  setActive(window.location.hash.slice(1) || "home");
})();
