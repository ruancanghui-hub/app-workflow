const root = document.querySelector('[data-codex-root]');
const screens = Array.from(root.querySelectorAll('[data-screen]'));
const tabButtons = Array.from(root.querySelectorAll('[data-tab]'));
const stateSelect = document.querySelector('#review-state');
const banner = root.querySelector('.state-banner');
const dialog = root.querySelector('dialog');
const dialogTitle = dialog.querySelector('[data-codex-id="dialog-title"]');
const dialogCopy = dialog.querySelector('[data-codex-id="dialog-copy"]');
const dialogAction = dialog.querySelector('[data-codex-id="dialog-action"]');
const dialogSecondary = dialog.querySelector('[data-codex-id="dialog-secondary"]');

const stateCopy = {
  default: '',
  loading: '正在读取本机内容，主要操作仍保持可见。',
  empty: '这里还没有记录，今晚可以完成第一次松息。',
  error: '暂时没有加载成功。可重试，已下载内容不会丢失。',
  denied: '权限已拒绝，仍可听声入睡；可稍后在系统设置中开启。',
  recovery: '检测到上次中断，可继续播放或结束并保存。'
};

const details = {
  player: ['松林细雨', '试听、暂停、倒计时，并可继续进入睡眠会话。', '开始睡眠', '返回声音库'],
  session: ['睡眠中', '会话计时与已下载声音在本机继续。来电后默认暂停声音。', '结束并查看报告', '保持会话'],
  alarm: ['轻唤醒 07:10', '通知被拒时仍可保存为应用内提醒，伴睡流程不会中断。', '保存时间', '取消'],
  report: ['昨夜 7小时24分', '达到 8 小时目标的 93%。可选记录主观感受，不展示睡眠分期。', '完成', '稍后评分'],
  breath: ['4-7-8 呼吸', '吸气 4 秒、屏息 7 秒、呼气 8 秒。减少动态时显示静态节拍。', '开始一轮', '退出'],
  downloads: ['下载管理', '3 个声音可离线使用。磁盘不足或中断时可清理与继续。', '查看已下载', '关闭'],
  paywall: ['松息会员', '免费声景可完成完整闭环；会员解锁更多原创声景。', '查看方案', '恢复购买'],
  permissions: ['权限与降级', '通知和麦克风均可拒绝。麦克风分析不在 MVP，拒绝不会阻断伴睡。', '打开系统设置', '继续使用'],
  privacy: ['隐私与设置', '睡眠记录默认保存在本机。可查看政策并删除本机数据。', '管理本机数据', '关闭']
};

function activateTab(tab) {
  screens.forEach((screen) => {
    const active = screen.dataset.screen === tab;
    screen.hidden = !active;
    screen.classList.toggle('is-active', active);
    if (active) screen.scrollTop = 0;
  });
  tabButtons.forEach((button) => {
    const active = button.dataset.tab === tab;
    button.classList.toggle('is-active', active);
    if (active) button.setAttribute('aria-current', 'page');
    else button.removeAttribute('aria-current');
  });
}

function openDetail(route) {
  const content = details[route];
  if (!content) return;
  dialogTitle.textContent = content[0];
  dialogCopy.textContent = content[1];
  dialogAction.textContent = content[2];
  dialogSecondary.textContent = content[3];
  dialog.dataset.route = route;
  dialog.showModal();
}

tabButtons.forEach((button) => button.addEventListener('click', () => activateTab(button.dataset.tab)));
root.querySelectorAll('[data-open]').forEach((button) => button.addEventListener('click', () => openDetail(button.dataset.open)));
dialog.querySelector('.dialog-close').addEventListener('click', () => dialog.close());
dialogSecondary.addEventListener('click', () => dialog.close());
dialogAction.addEventListener('click', () => {
  const route = dialog.dataset.route;
  dialog.close();
  if (route === 'player') openDetail('session');
  if (route === 'session') openDetail('report');
  if (route === 'report') activateTab('sleep');
});
stateSelect.addEventListener('change', () => {
  const copy = stateCopy[stateSelect.value];
  banner.textContent = copy;
  banner.hidden = copy.length === 0;
});

