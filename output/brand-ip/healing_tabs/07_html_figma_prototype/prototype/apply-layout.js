(function () {
  "use strict";

  var SHARED_URL = "../04-core-tab-ui/design-system-shared.json";
  var PROFILE_URLS = {
    home: "../04-core-tab-ui/design-system-profile-home.json",
    sleep: "../04-core-tab-ui/design-system-profile-sleep.json",
    meditation: "../04-core-tab-ui/design-system-profile-meditation.json",
    sound: "../04-core-tab-ui/design-system-profile-sound.json"
  };

  function px(value) {
    return typeof value === "number" ? value + "px" : value;
  }

  function resolveTabbar(slot, shared) {
    var tb = shared.layout_tokens.tabbar;
    return {
      x: tb.x,
      y: tb.y,
      width: tb.width,
      height: tb.height,
      radius: tb.radius
    };
  }

  function applyBox(el, slot) {
    if (!el || !slot) return;
    if (slot.x != null) el.style.left = px(slot.x);
    if (slot.y != null) el.style.top = px(slot.y);
    if (slot.width != null) el.style.width = px(slot.width);
    if (slot.height != null) el.style.height = px(slot.height);
    if (slot.radius != null) el.style.borderRadius = px(slot.radius);
    if (slot.text_align) el.style.textAlign = slot.text_align;
  }

  function applyTypography(el, role, shared) {
    if (!el || !role || !shared.typography_scale[role]) return;
    var t = shared.typography_scale[role];
    if (t.size != null) el.style.fontSize = px(t.size);
    if (t.weight != null) el.style.fontWeight = String(t.weight);
    if (t.line_height != null) el.style.lineHeight = String(t.line_height);
    if (t.letter_spacing != null) el.style.letterSpacing = t.letter_spacing;
  }

  function applyScreen(screen, profile, shared) {
    var slots = profile.layout_slots;
    if (!slots) return;

    Object.keys(slots).forEach(function (slotName) {
      var slot = slots[slotName];
      if (slot.inherit === "shared.layout_tokens.tabbar") {
        slot = resolveTabbar(slot, shared);
      }

      var el = screen.querySelector('[data-layout-slot="' + slotName + '"]');
      if (!el) return;

      applyBox(el, slot);
      if (slot.role) applyTypography(el, slot.role, shared);

      if (slot.icon_size != null) {
        var icon = el.querySelector(".card-icon, .feature-icon");
        if (icon) {
          icon.style.width = px(slot.icon_size);
          icon.style.height = px(slot.icon_size);
        }
      }

      if (slot.indicator_width != null) {
        var indicator = el.querySelector(".card-indicator");
        if (indicator) indicator.style.width = px(slot.indicator_width);
      }

      if (slot.label_inset != null) {
        var label = el.querySelector(".grid-label");
        if (label) {
          label.style.left = px(slot.label_inset);
          label.style.bottom = px(slot.label_inset);
        }
      }
    });
  }

  function loadJson(url) {
    return fetch(url).then(function (res) {
      if (!res.ok) throw new Error("Failed to load " + url);
      return res.json();
    });
  }

  function init() {
    var sharedPromise = loadJson(SHARED_URL);
    var profilePromises = Object.keys(PROFILE_URLS).map(function (tab) {
      return loadJson(PROFILE_URLS[tab]).then(function (profile) {
        return { tab: tab, profile: profile };
      });
    });

    Promise.all([sharedPromise].concat(profilePromises))
      .then(function (results) {
        var shared = results[0];
        results.slice(1).forEach(function (item) {
          var screen = document.querySelector('[data-screen="' + item.tab + '"]');
          if (screen) applyScreen(screen, item.profile, shared);
        });
        document.documentElement.classList.add("layout-applied");
      })
      .catch(function (err) {
        console.warn("[apply-layout]", err.message);
      });
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
})();
