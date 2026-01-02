'use strict';
'require view';
'require ui';
'require form';
'require rpc';
'require uci';
'require network';

return view.extend({
	callInitList: rpc.declare({
		object: 'luci',
		method: 'getInitList',
		expect: { '': {} }
	}),

	callInitAction: rpc.declare({
		object: 'luci',
		method: 'setInitAction',
		expect: { result: false },
		params: [ 'name', 'action' ]
	}),

	callSystemExec: rpc.declare({
		object: 'file',
		method: 'exec',
		params: [ 'command' ],
		expect: { code: 0 }
	}),

	load: function() {
		return Promise.all([
			this.callInitList(),
			uci.load('cups')
		]);
	},

	render: function(data) {
		var m, s, o;
		var initList = data[0];

		m = new form.Map('cups', _('CUPS Print Server'),
			_('Configure CUPS printing service for THDN Print Server'));

		s = m.section(form.TypedSection, 'cups', _('General Settings'));
		s.anonymous = true;
		s.addremove = false;

		o = s.option(form.Flag, 'enabled', _('Enable CUPS'));
		o.default = o.enabled;
		o.rmempty = false;

		o = s.option(form.Value, 'port', _('Port'));
		o.datatype = 'port';
		o.default = '631';
		o.rmempty = false;

		o = s.option(form.Flag, 'web_interface', _('Web Interface'));
		o.default = o.enabled;
		o.rmempty = false;

		o = s.option(form.Flag, 'remote_admin', _('Remote Administration'));
		o.default = o.disabled;
		o.rmempty = false;

		s = m.section(form.TypedSection, 'printer', _('Printer Settings'));
		s.anonymous = true;
		s.addremove = true;

		o = s.option(form.Value, 'name', _('Printer Name'));
		o.rmempty = false;

		o = s.option(form.ListValue, 'type', _('Printer Type'));
		o.value('usb', _('USB Printer'));
		o.value('network', _('Network Printer'));
		o.default = 'usb';
		o.rmempty = false;

		o = s.option(form.Value, 'device', _('Device URI'));
		o.placeholder = 'usb://HP/LaserJet%201020';
		o.rmempty = false;

		o = s.option(form.Value, 'ppd', _('PPD File'));
		o.placeholder = '/usr/share/cups/model/HP-LaserJet_1020.ppd';
		o.rmempty = false;

		o = s.option(form.Flag, 'enabled', _('Enable Printer'));
		o.default = o.enabled;
		o.rmempty = false;

		// Status section
		s = m.section(form.TypedSection, 'status', _('Service Status'));
		s.anonymous = true;
		s.addremove = false;

		o = s.option(form.DummyValue, '_status', _('CUPS Status'));
		o.cfgvalue = function() {
			var status = initList.cups ? initList.cups.enabled : false;
			return status ? 
				_('<span style="color:green">Running</span>') : 
				_('<span style="color:red">Stopped</span>');
		};

		o = s.option(form.DummyValue, '_printers', _('Connected Printers'));
		o.cfgvalue = function() {
			return _('Checking...');
		};

		o = s.option(form.Button, '_restart', _('Restart CUPS'));
		o.inputstyle = 'action';
		o.inputtitle = _('Restart');
		o.onclick = function() {
			return this.callInitAction('cups', 'restart').then(function() {
				ui.addNotification(null, E('p', _('CUPS service restarted')), 'info');
			});
		};

		return m.render();
	},

	handleSaveApply: function(ev, mode) {
		return this.handleSave(ev).then(function() {
			return this.callInitAction('cups', 'restart');
		}.bind(this));
	}
});
