import 'package:yaml/yaml.dart';

import '../main.dart';
import '../class/notes.dart';

void recordTemplateInit() {
  var templateNoteList = realm.query<Notes>(
      "noteType == \$0 AND noteIsDeleted != true SORT(noteCreateDate DESC)", [
    '.表单',
  ]);

  for (int i = 0; i < templateNoteList.length; i++) {
    if (templateNoteList[i].noteContext != '' &&
        templateNoteList[i].noteContext.contains('settings')) {
      if ((loadYaml(templateNoteList[i].noteContext.substring(
                      0, templateNoteList[i].noteContext.indexOf('settings')))
                  .runtimeType ==
              YamlMap) &&
          (loadYaml(templateNoteList[i].noteContext.substring(
                      templateNoteList[i].noteContext.indexOf('settings')))
                  .runtimeType ==
              YamlMap)) {
        Map template = loadYaml(templateNoteList[i]
            .noteContext
            .substring(0, templateNoteList[i].noteContext.indexOf('settings')));
        Map templateProperty = loadYaml(templateNoteList[i]
            .noteContext
            .substring(templateNoteList[i].noteContext.indexOf('settings')));
        Map<int, List> templateChecked = {};
        Map<String, List> templatePropertyChecked = {};
        template.forEach((key, value) {
          if (key.runtimeType == int) {
            templateChecked[key] = value.toString().split(',');
          }
        });
        templateProperty.forEach((key, value) {
          if (key.runtimeType == String) {
            if (key == 'color') {
              if (value.runtimeType == YamlList) {
                templatePropertyChecked[key] = [value[0], value[1], value[2]];
              }
            } else if (value.toString().contains('-')) {
              List settings = value.toString().split(',');
              List settingsChecked = [];
              for (int i = 0; i < settings.length; i++) {
                List setting = settings[i].toString().split('-');
                List settingChecked = [];
                for (int i = 0; i < setting.length; i++) {
                  int? index = int.tryParse(setting[i]);
                  settingChecked.add(index ?? setting[i]);
                }
                settingsChecked.add(settingChecked);
              }
              templatePropertyChecked[key] = settingsChecked;
            } else {
              templatePropertyChecked[key] = value.toString().split(',');
            }
          }
        });
        recordTemplates[templateNoteList[i].noteProject] = templateChecked;
        recordTemplatesSettings[templateNoteList[i].noteProject] =
            templatePropertyChecked;
      }
    }
  }
}
