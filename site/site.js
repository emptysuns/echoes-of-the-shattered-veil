(() => {
  const toggle = document.querySelector('.language-toggle');
  const translatable = [...document.querySelectorAll('[data-zh][data-en]')];
  const saved = localStorage.getItem('echoes-locale');
  let locale = saved === 'en' ? 'en' : 'zh';

  function applyLocale() {
    document.documentElement.lang = locale === 'zh' ? 'zh-CN' : 'en';
    translatable.forEach((element) => {
      element.textContent = element.dataset[locale];
    });
    toggle.setAttribute('aria-label', locale === 'zh' ? 'Switch to English' : '切换到中文');
    localStorage.setItem('echoes-locale', locale);
  }

  toggle.addEventListener('click', () => {
    locale = locale === 'zh' ? 'en' : 'zh';
    applyLocale();
  });

  document.querySelector('.year').textContent = new Date().getFullYear();
  applyLocale();

  const isLocalPreview = ['localhost', '127.0.0.1'].includes(location.hostname);
  if (!isLocalPreview) {
    fetch('https://api.github.com/repos/emptysuns/echoes-of-the-shattered-veil/releases/latest', {
      headers: { Accept: 'application/vnd.github+json' }
    }).then((response) => response.ok ? response.json() : Promise.reject())
      .then((release) => {
        const status = document.querySelector('.release-status');
        if (release.tag_name) status.textContent = `${release.tag_name} · MIT · Godot 4.3`;
      }).catch(() => {
        // The committed release label remains accurate when the API is unavailable.
      });
  }
})();
