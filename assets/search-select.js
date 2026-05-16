/**
 * search-select.js — Herbruikbaar zoekbaar dropdown component voor MAMA
 *
 * Gebruik:
 *   enhanceSearchSelect('selectId', '— Zoek asset —')
 *   syncSearchSelect('selectId')   ← na programmatisch .value = '...' zetten
 */

(function() {

  const style = document.createElement('style');
  style.textContent = `
    .ss-wrap { position: relative; }
    .ss-input { width: 100%; box-sizing: border-box; }
    .ss-dropdown {
      display: none;
      position: absolute;
      top: calc(100% + 2px);
      left: 0; right: 0;
      background: var(--surface);
      border: var(--border-width, 1px) solid var(--border);
      border-radius: var(--radius, 6px);
      max-height: 220px;
      overflow-y: auto;
      z-index: 1000;
      box-shadow: 0 6px 20px rgba(0,0,0,0.12);
    }
    .ss-option {
      padding: 8px 12px;
      font-size: 13px;
      cursor: pointer;
      color: var(--text-2);
    }
    .ss-option:hover, .ss-option.ss-focused { background: var(--bg); color: var(--text); }
    .ss-option.ss-selected { font-weight: 500; color: var(--text); }
    .ss-option.ss-empty { color: var(--text-3); font-style: italic; }
    .ss-no-results { padding: 8px 12px; font-size: 12px; color: var(--text-3); }
  `;
  document.head.appendChild(style);

  window.enhanceSearchSelect = function(selectId, placeholder) {
    const select = document.getElementById(selectId);
    if (!select || select.dataset.ssEnhanced) return;
    select.dataset.ssEnhanced = '1';
    placeholder = placeholder || '— Zoek —';

    // Verberg de originele select
    select.style.display = 'none';

    // Wrapper
    const wrap = document.createElement('div');
    wrap.className = 'ss-wrap';
    select.parentNode.insertBefore(wrap, select);
    wrap.appendChild(select);

    // Zoekinput
    const input = document.createElement('input');
    input.type = 'text';
    input.className = (select.className || 'form-input') + ' ss-input';
    input.placeholder = placeholder;
    input.autocomplete = 'off';
    wrap.insertBefore(input, select);

    // Dropdown
    const dropdown = document.createElement('div');
    dropdown.className = 'ss-dropdown';
    wrap.appendChild(dropdown);

    let focusedIdx = -1;

    function getOptions(query) {
      const q = (query || '').toLowerCase();
      return Array.from(select.options).filter(o =>
        !q || o.text.toLowerCase().includes(q)
      );
    }

    function renderDropdown(query) {
      const opts = getOptions(query);
      focusedIdx = -1;
      if (!opts.length) {
        dropdown.innerHTML = '<div class="ss-no-results">Geen resultaten</div>';
      } else {
        dropdown.innerHTML = opts.map((o, i) => {
          const isEmpty = !o.value;
          const isSelected = o.value === select.value;
          return `<div class="ss-option${isEmpty ? ' ss-empty' : ''}${isSelected ? ' ss-selected' : ''}" data-value="${o.value}" data-idx="${i}">${o.text}</div>`;
        }).join('');
        dropdown.querySelectorAll('.ss-option').forEach(el => {
          el.addEventListener('mousedown', e => {
            e.preventDefault();
            selectOption(el.dataset.value, el.textContent);
          });
        });
      }
      dropdown.style.display = 'block';
    }

    function selectOption(value, label) {
      select.value = value;
      input.value = value ? label : '';
      dropdown.style.display = 'none';
      select.dispatchEvent(new Event('change', { bubbles: true }));
    }

    function syncDisplay() {
      const opt = Array.from(select.options).find(o => o.value === select.value);
      input.value = (opt && opt.value) ? opt.text : '';
    }

    input.addEventListener('focus', () => renderDropdown(input.value));
    input.addEventListener('input', () => renderDropdown(input.value));

    input.addEventListener('keydown', e => {
      const items = dropdown.querySelectorAll('.ss-option');
      if (e.key === 'ArrowDown') {
        e.preventDefault();
        focusedIdx = Math.min(focusedIdx + 1, items.length - 1);
        items.forEach((el, i) => el.classList.toggle('ss-focused', i === focusedIdx));
        items[focusedIdx]?.scrollIntoView({ block: 'nearest' });
      } else if (e.key === 'ArrowUp') {
        e.preventDefault();
        focusedIdx = Math.max(focusedIdx - 1, 0);
        items.forEach((el, i) => el.classList.toggle('ss-focused', i === focusedIdx));
        items[focusedIdx]?.scrollIntoView({ block: 'nearest' });
      } else if (e.key === 'Enter' && focusedIdx >= 0) {
        e.preventDefault();
        const el = items[focusedIdx];
        if (el) selectOption(el.dataset.value, el.textContent);
      } else if (e.key === 'Escape') {
        dropdown.style.display = 'none';
      }
    });

    input.addEventListener('blur', () => {
      setTimeout(() => {
        dropdown.style.display = 'none';
        syncDisplay(); // reset als gebruiker niks koos
      }, 150);
    });

    // Publieke sync-methode op het select element
    select._ssSync = syncDisplay;

    syncDisplay();
  };

  // Aanroepen na programmatisch select.value = '...' zetten
  window.syncSearchSelect = function(selectId) {
    const select = document.getElementById(selectId);
    if (select && select._ssSync) select._ssSync();
  };

})();
