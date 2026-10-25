ObjC.import('Foundation');
function run(argv) {
  var path = argv[0], script = argv[1], mode = argv[2] || 'install';
  var fm = $.NSFileManager.defaultManager;
  var cfg = {};
  if (fm.fileExistsAtPath(path)) {
    var txt = ObjC.unwrap($.NSString.stringWithContentsOfFileEncodingError(path, $.NSUTF8StringEncoding, null));
    if (txt && txt.trim()) cfg = JSON.parse(txt);
  }
  cfg.hooks = cfg.hooks || {};
  var wanted = [['UserPromptSubmit', 'start'], ['Stop', 'stop'], ['SessionEnd', 'stop']];
  wanted.forEach(function (w) {
    var ev = w[0], cmd = '"' + script + '" ' + w[1];
    var list = cfg.hooks[ev] || [];
    // remove any existing copy of our hook first (keeps installs idempotent)
    list = list.map(function (g) {
      g.hooks = (g.hooks || []).filter(function (h) { return h.command !== cmd; });
      return g;
    }).filter(function (g) { return g.hooks.length > 0; });
    if (mode === 'install') list.push({ hooks: [{ type: 'command', command: cmd }] });
    if (list.length) cfg.hooks[ev] = list; else delete cfg.hooks[ev];
  });
  if (Object.keys(cfg.hooks).length === 0) delete cfg.hooks;
  var ok = $(JSON.stringify(cfg, null, 2)).writeToFileAtomicallyEncodingError(path, true, $.NSUTF8StringEncoding, null);
  if (!ok) throw new Error('Could not write ' + path);
  return 'settings.json updated (' + mode + ')';
}
