'use strict';
'require view';
'require form';
'require fs';
'require ui';
'require uci';

var CONF = '/etc/vianes/config.yaml';

function fillLog(box, text) {
	var content = (text || '').trim();

	while (box.firstChild)
		box.removeChild(box.firstChild);

	if (!content) {
		box.appendChild(E('em', {}, _('(no log entries)')));
		return;
	}

	var lines = content.split('\n');
	if (lines.length > 100)
		lines = lines.slice(-100);

	box.appendChild(E('pre', {
		'wrap': 'pre',
		'style': 'margin:0; padding:8px; font-size:12px; white-space:pre-wrap; overflow:auto; max-height:28em'
	}, [ lines.join('\n') ]));
}

return view.extend({
	fetchLog: function(box) {
		return L.resolveDefault(fs.exec('/sbin/logread', [ '-e', 'vianes(\\[|:)' ]), {})
			.then(function(res) { fillLog(box, res && res.stdout); },
			      function() { fillLog(box, _('(failed to read log)')); });
	},

	renderLogPane: function() {
		var box = E('div');

		this.fetchLog(box);

		return E('div', { 'style': 'padding: 0 0 8px 0' }, [
			E('div', { 'class': 'cbi-section-descr' },
				_('Latest daemon messages.')),
			box,
			E('button', {
				'class': 'btn cbi-button cbi-button-neutral',
				'style': 'margin-top:8px',
				'click': ui.createHandlerFn(this, 'fetchLog', box)
			}, _('Refresh'))
		]);
	},

	render: function() {
		var m, s, o;

		m = new form.Map('vianes', _('Vianes'),
			_('Steers traffic on the bind interface to named upstreams using eBPF, policy routing and nft.'));

		s = m.section(form.NamedSection, 'config', 'vianes');
		s.tab('global', _('Settings'));
		s.tab('config', _('Configuration'));
		s.tab('log', _('Log'));

		o = s.taboption('global', form.Flag, 'enabled', _('Enable'));
		o.rmempty = false;

		o = s.taboption('global', form.DummyValue, 'config_file', _('Configuration file'));
		o.default = CONF;

		o = s.taboption('config', form.TextValue, '_configuration');
		o.rows = 30;
		o.monospace = true;
		o.rmempty = true;
		o.load = function() {
			return L.resolveDefault(fs.read_direct(CONF, 'text'), '');
		};
		o.write = function(section_id, value) {
			return fs.write(CONF, (value || '').replace(/\r\n/g, '\n'))
				.catch(function(e) {
					ui.addNotification(null, E('p', e.message));
				});
		};
		o.remove = function() {
			return fs.write(CONF, '');
		};

		o = s.taboption('log', form.DummyValue, '_log');
		o.render = L.bind(this.renderLogPane, this);

		return m.render();
	},

	handleSave: function(ev) {
		uci.set('vianes', 'config', 'config_file', CONF);
		return this.super('handleSave', ev);
	},

	handleSaveApply: function(ev, mode) {
		return this.super('handleSaveApply', ev, mode).then(function() {
			return L.resolveDefault(fs.exec('/etc/init.d/vianes', ['reload']), null);
		});
	}
});
