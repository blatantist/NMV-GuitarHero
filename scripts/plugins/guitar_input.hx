import funkin.input.Controls;
import funkin.input.InputSystem;
import funkin.states.options.ControlsSubState;
import flixel.util.FlxSave;
import lime.ui.Gamepad;

// raphnet GH:WT adapter (289b:0080) isnt in sdl's db, crc + version zeroed so it matches on every platform
var GUITAR_MAPPING = '030000009b2800008000000000000000,raphnet GHWT,a:b0,b:b1,x:b2,y:b3,leftshoulder:b4,rightshoulder:b5,leftstick:b6,rightstick:b7,dpup:b8,leftx:a0,lefty:a1,righttrigger:a2,';

function guitarBind(name, defKey)
{
	var keys = ClientPrefs.keyBinds.exists(name) ? ClientPrefs.keyBinds.get(name) : [defKey];
	var out = [];
	for (k in keys) if (k != 0) out.push(k);
	while (out.length < 2) out.push(-1);
	ClientPrefs.keyBinds.set(name, out);
	return out;
}

function padDefault(name, binds, fresh)
{
	ClientPrefs.defaultGamepadBinds.set(name, binds.copy());
	if (fresh || !ClientPrefs.gamepadBinds.exists(name)) ClientPrefs.gamepadBinds.set(name, binds.copy());
}

function onLoad()
{
	if (!Controls.instance.actions.exists('note_5'))
		Controls.instance.addCustomKey('note_5', guitarBind('note_5', FlxKey.G));

	if (!Controls.instance.actions.exists('note_strum'))
		Controls.instance.addCustomKey('note_strum', guitarBind('note_strum', FlxKey.SPACE));

	var save = new FlxSave();
	save.bind('controls_v2');
	var fresh = save.data.customGamepadControlsV2 == null;
	save.close();

	// ids are FlxGamepadInputID: 0-4 a/b/x/y/lb (green-orange), 5 rb (strum down), 8 ls-click (+), 11 dpad up (strum up), 34-37 left stick up/right/down/left
	padDefault('note_left', [0, -1], fresh);
	padDefault('note_down', [1, -1], fresh);
	padDefault('note_up', [2, -1], fresh);
	padDefault('note_right', [3, -1], fresh);
	padDefault('note_5', [4, -1], fresh);
	padDefault('note_strum', [11, 5], fresh);
	padDefault('accept', [0, -1], fresh);
	padDefault('back', [1, -1], fresh);
	padDefault('pause', [8, -1], fresh);
	padDefault('ui_up', [34, 11], fresh);
	padDefault('ui_down', [36, 5], fresh);
	padDefault('ui_left', [37, -1], fresh);
	padDefault('ui_right', [35, -1], fresh);

	InputSystem.ACTION_LIST = ['note_left', 'note_down', 'note_up', 'note_right', 'note_5'];

	ControlsSubState.NOTES_GROUP = [
		{label: "Green", action: "note_left"},
		{label: "Red", action: "note_down"},
		{label: "Yellow", action: "note_up"},
		{label: "Blue", action: "note_right"},
		{label: "Orange", action: "note_5"},
		{label: "Strum", action: "note_strum"},
		null,
	];

	// pads connected at startup got bound before these actions existed
	ClientPrefs.reloadControls();

	// an already plugged in guitar gets a fresh connect event once this lands
	Gamepad.addMappings([GUITAR_MAPPING]);
}
