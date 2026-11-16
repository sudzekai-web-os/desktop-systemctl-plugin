import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import linctrl

AppDialog {
    id: root
    preferredWidth: 680
    property bool creating: false
    property string serverError: ""
    signal submitted(string name, string content, bool creating)

    function start(unit, value) {
        creating = !unit
        title = creating ? "Создание службы" : "Редактирование службы"
        name.text = unit
        content.text = value
        open()
    }

    contentItem: ColumnLayout {
        AppText {
            Layout.fillWidth: true
            visible: root.creating
            text: "Имя должно входить в список разрешённых служб на сервере."
            wrapMode: Text.Wrap
        }
        AppField {
            id: name
            Layout.fillWidth: true
            placeholderText: "example.service"
            readOnly: !root.creating
        }
        ScrollView {
            Layout.fillWidth: true
            Layout.preferredHeight: 280
            TextArea {
                id: content
                color: Theme.palette.ink
                font.family: "monospace"
                wrapMode: TextEdit.Wrap
                background: AppCard {}
            }
        }
        AppText {
            Layout.fillWidth: true
            visible: text !== ""
            text: root.serverError
            color: Theme.palette.accent
            wrapMode: Text.Wrap
        }
        RowLayout {
            Layout.alignment: Qt.AlignRight
            DefaultButton { text: "Отмена"; enabled: !root.busy; onClicked: root.close() }
            DefaultButton {
                text: "Сохранить"
                primary: true
                enabled: !root.busy && name.text.trim().length > 0 && content.text.trim().length > 0
                onClicked: root.submitted(name.text.trim(), content.text, root.creating)
            }
        }
    }
}
