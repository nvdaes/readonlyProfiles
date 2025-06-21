import addonHandler
import globalPluginHandler
import config
import ui
from config import pre_configSave
from globalCommands import SCRCAT_CONFIG
from scriptHandler import script
from keyboardHandler import KeyboardInputGesture


addonHandler.initTranslation()

def preConfigSaveHandler():
	config.conf._dirtyProfiles.clear()


class GlobalPlugin(globalPluginHandler.GlobalPlugin):

	def __init__(self):
		super().__init__()
		pre_configSave.register(preConfigSaveHandler)

	def terminate(self):
		pre_configSave.unregister(preConfigSaveHandler)


	@script(
		# Translators: Message presented in input help mode.
		description=_("Saves the current configuration to the most recent profile"),
		category=SCRCAT_CONFIG,
		gesture="kb:NVDA+shift+p",
	)
	def script_saveProfile(self, gesture: KeyboardInputGesture):
		profile = config.conf.profiles[-1]
		if profile.name is None:
			ui.message(_("Normal configuration cannot be saved with this command"))
			return
		config.conf._writeProfileToFile(profile.filename, profile)
		ui.message("Saved profile {profile}".format(profile=profile.name))
